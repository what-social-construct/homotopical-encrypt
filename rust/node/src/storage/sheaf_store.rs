// Sheaf-Aware Storage: Functor F: Sh(X) → RocksDB
//
// Storage does not "store sheaves" — it IS a sheaf, functorially embedded
// into RocksDB. The functor F maps mathematical objects to persistence:
//
//   F(Stalk)     = column family (stalks_private, stalks_public, stalks_zk)
//   F(Vertex v)  = key "vertex:v"
//   F(Edge e)    = key "edge:v0:v1"
//   F(Section)   = batch write over vertex keys
//   F(Projection) = query + context change
//
// THREE sheaves over the same base X (nerve of accounts), one per column family:
//
//   F_full  (Private, dim=256) — full credential, Laplacian, Hodge, restriction maps
//   F_zk    (Zk, dim=32)      — Hodge projection + quantization (ZK intermediate)
//   F_hash  (Public, dim=1)   — balance commitment (harmonic projection)
//
// Connected by two natural transformations:
//
//   η₁: F_full → F_zk    (Oracle computes this: Hodge project + quantize)
//   η₂: F_zk  → F_hash   (Node applies this: hash + compress to commitment)
//   η = η₂ ∘ η₁: F_full → F_hash  (full pipeline)
//
//   F_full (Private,256) ──η₁──→ F_zk (Zk,32) ──η₂──→ F_hash (Public,1)
//        Python wallet            Oracle               Rust Node
//
// The Oracle IS η₁ — it receives FullStalk (Private) and outputs HashStalk (Zk).
// The Node IS η₂ — it receives HashStalk (Zk) and stores the public commitment.
//
// Privacy via exact sequence: 0 → ker(η) → F_full → F_hash → 0
//   ker(η) = private data (fibration secrets, restriction maps)
//
// Functoriality:
//   F(id_X) = id_{F(X)}
//   F(g ∘ f) = F(g) ∘ F(f)


use anyhow::Result;
use rocksdb::{DB, Options, ColumnFamily};
use std::sync::Arc;
use serde::{Deserialize, Serialize};
use tracing::{debug, info};

/// Stalk context (maps to Python StalkContext)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum StalkContext {
    Private,  // dim=256, homotopical encryption (spectral structure)
    Public,   // dim=1, harmonic projection (balance/commitment)
    Zk,       // dim=32, zero-knowledge intermediate
}

impl StalkContext {
    pub fn dimension(&self) -> usize {
        match self {
            StalkContext::Private => 256,
            StalkContext::Public => 1,
            StalkContext::Zk => 32,
        }
    }
    
    pub fn column_family_name(&self) -> &'static str {
        match self {
            StalkContext::Private => "stalks_private",
            StalkContext::Public => "stalks_public",
            StalkContext::Zk => "stalks_zk",
        }
    }
}

/// A stalk: local data at a vertex
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Stalk {
    pub context: StalkContext,
    pub data: Vec<f64>,
    pub vertex_id: Option<u64>,
}

impl Stalk {
    pub fn new(context: StalkContext, data: Vec<f64>) -> Result<Self> {
        if data.len() != context.dimension() {
            anyhow::bail!(
                "Data dimension {} != context dimension {}",
                data.len(),
                context.dimension()
            );
        }
        Ok(Self {
            context,
            data,
            vertex_id: None,
        })
    }
    
    pub fn zero(context: StalkContext) -> Self {
        Self {
            context,
            data: vec![0.0; context.dimension()],
            vertex_id: None,
        }
    }
    
    pub fn from_value(value: f64) -> Self {
        Self {
            context: StalkContext::Public,
            data: vec![value],
            vertex_id: None,
        }
    }
    
    pub fn serialize(&self) -> Result<Vec<u8>> {
        Ok(bincode::serialize(self)?)
    }
    
    pub fn deserialize(bytes: &[u8]) -> Result<Self> {
        Ok(bincode::deserialize(bytes)?)
    }
}

/// Simplex key: vertex, edge, or face
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum SimplexKey {
    Vertex(u64),
    Edge(u64, u64),
    Face(u64, u64, u64),
}

impl SimplexKey {
    pub fn to_bytes(&self) -> Vec<u8> {
        bincode::serialize(self).unwrap()
    }
    
    pub fn from_bytes(bytes: &[u8]) -> Result<Self> {
        Ok(bincode::deserialize(bytes)?)
    }
}

/// Sheaf-aware storage using stalks
pub struct SheafStore {
    db: Arc<DB>,
}

impl SheafStore {
    pub fn new(db: Arc<DB>) -> Self {
        Self { db }
    }
    
    /// Store a stalk at a vertex
    pub fn set_stalk(
        &self,
        context: StalkContext,
        vertex_id: u64,
        stalk: &Stalk,
    ) -> Result<()> {
        if stalk.context != context {
            anyhow::bail!("Stalk context mismatch");
        }
        
        let cf = self.db.cf_handle(context.column_family_name())
            .ok_or_else(|| anyhow::anyhow!("Column family not found"))?;
        
        let key = SimplexKey::Vertex(vertex_id).to_bytes();
        let value = stalk.serialize()?;
        
        self.db.put_cf(cf, key, value)?;
        
        debug!(
            "Stored {} stalk at vertex {} (dim={})",
            context.column_family_name(),
            vertex_id,
            stalk.data.len()
        );
        
        Ok(())
    }
    
    /// Get a stalk at a vertex
    pub fn get_stalk(
        &self,
        context: StalkContext,
        vertex_id: u64,
    ) -> Result<Option<Stalk>> {
        let cf = self.db.cf_handle(context.column_family_name())
            .ok_or_else(|| anyhow::anyhow!("Column family not found"))?;
        
        let key = SimplexKey::Vertex(vertex_id).to_bytes();
        
        match self.db.get_cf(cf, key)? {
            Some(bytes) => {
                let mut stalk = Stalk::deserialize(&bytes)?;
                stalk.vertex_id = Some(vertex_id);
                Ok(Some(stalk))
            }
            None => Ok(None),
        }
    }
    
    /// Store a section (global state as collection of stalks)
    pub fn set_section(
        &self,
        context: StalkContext,
        stalks: &[(u64, Stalk)],
    ) -> Result<()> {
        info!(
            "Storing section with {} stalks in {}",
            stalks.len(),
            context.column_family_name()
        );
        
        for (vertex_id, stalk) in stalks {
            self.set_stalk(context, *vertex_id, stalk)?;
        }
        
        Ok(())
    }
    
    /// Get a section (all stalks in a context)
    pub fn get_section(&self, context: StalkContext) -> Result<Vec<(u64, Stalk)>> {
        let cf = self.db.cf_handle(context.column_family_name())
            .ok_or_else(|| anyhow::anyhow!("Column family not found"))?;
        
        let mut section = Vec::new();
        
        let iter = self.db.iterator_cf(cf, rocksdb::IteratorMode::Start);
        for item in iter {
            let (key_bytes, value_bytes) = item?;
            
            if let SimplexKey::Vertex(vertex_id) = SimplexKey::from_bytes(&key_bytes)? {
                let mut stalk = Stalk::deserialize(&value_bytes)?;
                stalk.vertex_id = Some(vertex_id);
                section.push((vertex_id, stalk));
            }
        }
        
        Ok(section)
    }
    
    /// Project from private to public (dim 256 → dim 1)
    ///
    /// This is η₂: F_zk → F_hash, implemented as COORDINATE EXTRACTION
    /// (data[0] = spectral gap scalar), NOT as the Hodge projection π_H.
    ///
    /// The Hodge projection π_H: C^k → ker(Δ) is computed in Python
    /// (geometry/hodge.py) and lives in the encryption/decryption path.
    /// By the time data reaches Rust storage, the heavy geometry is done.
    /// This η₂ just extracts the consensus-relevant scalar (spectral gap).
    ///
    /// See hardness_proof.lean: the Hodge→CVP reduction applies to π_H
    /// (encryption), not to this storage projection.
    pub fn project_to_public(&self, vertex_id: u64) -> Result<Option<Stalk>> {
        if let Some(private_stalk) = self.get_stalk(StalkContext::Private, vertex_id)? {
            // Simple projection: take first component (or sum, or custom logic)
            let public_value = private_stalk.data[0];
            let public_stalk = Stalk::from_value(public_value);
            
            // Store projected stalk
            self.set_stalk(StalkContext::Public, vertex_id, &public_stalk)?;
            
            Ok(Some(public_stalk))
        } else {
            Ok(None)
        }
    }
    
    /// Store data on an edge (1-simplex)
    pub fn set_edge_data(
        &self,
        context: StalkContext,
        v0: u64,
        v1: u64,
        data: &[u8],
    ) -> Result<()> {
        let cf = self.db.cf_handle(context.column_family_name())
            .ok_or_else(|| anyhow::anyhow!("Column family not found"))?;
        
        let key = SimplexKey::Edge(v0, v1).to_bytes();
        self.db.put_cf(cf, key, data)?;
        
        Ok(())
    }
    
    /// Get data on an edge
    pub fn get_edge_data(
        &self,
        context: StalkContext,
        v0: u64,
        v1: u64,
    ) -> Result<Option<Vec<u8>>> {
        let cf = self.db.cf_handle(context.column_family_name())
            .ok_or_else(|| anyhow::anyhow!("Column family not found"))?;
        
        let key = SimplexKey::Edge(v0, v1).to_bytes();
        Ok(self.db.get_cf(cf, key)?)
    }
}

/// Initialize sheaf-aware database
pub fn init_sheaf_db(path: &std::path::Path) -> Result<DB> {
    let mut opts = Options::default();
    opts.create_if_missing(true);
    opts.create_missing_column_families(true);
    
    // Column families = Stalk contexts!
    let cfs = vec![
        StalkContext::Private.column_family_name(),
        StalkContext::Public.column_family_name(),
        StalkContext::Zk.column_family_name(),
        "blocks",      // Non-sheaf data still needs storage
        "keyimages",   // Key images for double-spend
    ];
    
    let db = DB::open_cf(&opts, path, &cfs)?;
    
    info!("✅ Initialized sheaf-aware storage");
    info!("   Column families (stalks):");
    info!("   - {} (dim={})", 
          StalkContext::Private.column_family_name(),
          StalkContext::Private.dimension());
    info!("   - {} (dim={})",
          StalkContext::Public.column_family_name(),
          StalkContext::Public.dimension());
    info!("   - {} (dim={})",
          StalkContext::Zk.column_family_name(),
          StalkContext::Zk.dimension());
    
    Ok(db)
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;
    
    #[test]
    fn test_stalk_storage() {
        let dir = tempdir().unwrap();
        let db = init_sheaf_db(dir.path()).unwrap();
        let store = SheafStore::new(Arc::new(db));
        
        // Create and store a public stalk (balance)
        let balance = Stalk::from_value(1000.0);
        store.set_stalk(StalkContext::Public, 0, &balance).unwrap();
        
        // Retrieve it
        let loaded = store.get_stalk(StalkContext::Public, 0).unwrap().unwrap();
        assert_eq!(loaded.data[0], 1000.0);
        assert_eq!(loaded.vertex_id, Some(0));
    }
    
    #[test]
    fn test_section_storage() {
        let dir = tempdir().unwrap();
        let db = init_sheaf_db(dir.path()).unwrap();
        let store = SheafStore::new(Arc::new(db));
        
        // Create a section (multiple stalks)
        let stalks = vec![
            (0, Stalk::from_value(1000.0)),
            (1, Stalk::from_value(500.0)),
            (2, Stalk::from_value(750.0)),
        ];
        
        store.set_section(StalkContext::Public, &stalks).unwrap();
        
        // Retrieve section
        let section = store.get_section(StalkContext::Public).unwrap();
        assert_eq!(section.len(), 3);
        assert_eq!(section[0].1.data[0], 1000.0);
    }
    
    #[test]
    fn test_projection() {
        let dir = tempdir().unwrap();
        let db = init_sheaf_db(dir.path()).unwrap();
        let store = SheafStore::new(Arc::new(db));
        
        // Create private stalk
        let private_data = vec![42.0; 256];
        let private = Stalk::new(StalkContext::Private, private_data).unwrap();
        store.set_stalk(StalkContext::Private, 0, &private).unwrap();
        
        // Project to public
        let public = store.project_to_public(0).unwrap().unwrap();
        assert_eq!(public.data[0], 42.0);
        assert_eq!(public.data.len(), 1);
        
        // Public stalk should now be stored
        let loaded_public = store.get_stalk(StalkContext::Public, 0).unwrap().unwrap();
        assert_eq!(loaded_public.data[0], 42.0);
    }
    
    #[test]
    fn test_simplex_keys() {
        let v = SimplexKey::Vertex(42);
        let e = SimplexKey::Edge(1, 2);
        let f = SimplexKey::Face(1, 2, 3);

        // Serialize/deserialize
        assert_eq!(SimplexKey::from_bytes(&v.to_bytes()).unwrap(), v);
        assert_eq!(SimplexKey::from_bytes(&e.to_bytes()).unwrap(), e);
        assert_eq!(SimplexKey::from_bytes(&f.to_bytes()).unwrap(), f);
    }

    // ── Stalk serialize/deserialize roundtrip ───────────────────

    #[test]
    fn test_stalk_serialize_roundtrip() {
        // Public stalk (dim=1) for simple roundtrip
        let stalk = Stalk::new(StalkContext::Public, vec![42.5]).unwrap();
        let bytes = stalk.serialize().unwrap();
        let restored = Stalk::deserialize(&bytes).unwrap();
        assert_eq!(restored.data, vec![42.5]);
        assert_eq!(restored.context, StalkContext::Public);

        // Private stalk (dim=256)
        let mut data = vec![0.0; 256];
        data[0] = 1.0;
        data[255] = -0.7;
        let stalk2 = Stalk::new(StalkContext::Private, data.clone()).unwrap();
        let bytes2 = stalk2.serialize().unwrap();
        let restored2 = Stalk::deserialize(&bytes2).unwrap();
        assert_eq!(restored2.data, data);
        assert_eq!(restored2.context, StalkContext::Private);
    }

    #[test]
    fn test_stalk_context_dimensions() {
        // Private: 256-dim, Public: 1-dim, Zk: 32-dim
        assert_eq!(StalkContext::Private.dimension(), 256);
        assert_eq!(StalkContext::Public.dimension(), 1);
        assert_eq!(StalkContext::Zk.dimension(), 32);
    }

    #[test]
    fn test_stalk_dimension_validation() {
        // Private needs exactly 256
        assert!(Stalk::new(StalkContext::Private, vec![0.0; 256]).is_ok());
        assert!(Stalk::new(StalkContext::Private, vec![0.0; 10]).is_err());

        // Public needs exactly 1
        assert!(Stalk::new(StalkContext::Public, vec![42.0]).is_ok());
        assert!(Stalk::new(StalkContext::Public, vec![1.0, 2.0]).is_err());

        // Zk needs exactly 32
        assert!(Stalk::new(StalkContext::Zk, vec![0.0; 32]).is_ok());
        assert!(Stalk::new(StalkContext::Zk, vec![0.0; 16]).is_err());
    }

    #[test]
    fn test_stalk_zero() {
        let z = Stalk::zero(StalkContext::Private);
        assert_eq!(z.data.len(), 256);
        assert!(z.data.iter().all(|&x| x == 0.0));
    }

    #[test]
    fn test_stalk_from_value() {
        let s = Stalk::from_value(42.0);
        assert_eq!(s.data, vec![42.0]);
        assert_eq!(s.context, StalkContext::Public);
    }

    // ── Edge data storage ───────────────────────────────────────

    #[test]
    fn test_edge_data_storage() {
        let dir = tempdir().unwrap();
        let db = init_sheaf_db(dir.path()).unwrap();
        let store = SheafStore::new(Arc::new(db));

        // Edge data is raw bytes (restriction map / cochain on 1-simplex)
        let edge_data: Vec<u8> = vec![0xDE, 0xAD, 0xBE, 0xEF];
        store.set_edge_data(StalkContext::Public, 0, 1, &edge_data).unwrap();

        let loaded = store.get_edge_data(StalkContext::Public, 0, 1).unwrap().unwrap();
        assert_eq!(loaded, vec![0xDE, 0xAD, 0xBE, 0xEF]);

        // Non-existent edge
        assert!(store.get_edge_data(StalkContext::Public, 99, 100).unwrap().is_none());
    }

    #[test]
    fn test_edge_data_overwrite() {
        let dir = tempdir().unwrap();
        let db = init_sheaf_db(dir.path()).unwrap();
        let store = SheafStore::new(Arc::new(db));

        store.set_edge_data(StalkContext::Public, 0, 1, &[0x01]).unwrap();
        store.set_edge_data(StalkContext::Public, 0, 1, &[0xFF]).unwrap();

        let loaded = store.get_edge_data(StalkContext::Public, 0, 1).unwrap().unwrap();
        assert_eq!(loaded, vec![0xFF]);
    }

    #[test]
    fn test_edge_data_context_isolation() {
        // Edge data in different contexts (column families) are separate
        let dir = tempdir().unwrap();
        let db = init_sheaf_db(dir.path()).unwrap();
        let store = SheafStore::new(Arc::new(db));

        store.set_edge_data(StalkContext::Public, 0, 1, &[0x01]).unwrap();
        store.set_edge_data(StalkContext::Zk, 0, 1, &[0x02]).unwrap();

        let pub_data = store.get_edge_data(StalkContext::Public, 0, 1).unwrap().unwrap();
        let zk_data = store.get_edge_data(StalkContext::Zk, 0, 1).unwrap().unwrap();
        assert_eq!(pub_data, vec![0x01]);
        assert_eq!(zk_data, vec![0x02]);

        // Private CF has nothing for this edge
        assert!(store.get_edge_data(StalkContext::Private, 0, 1).unwrap().is_none());
    }

    #[test]
    fn test_stalk_overwrite() {
        let dir = tempdir().unwrap();
        let db = init_sheaf_db(dir.path()).unwrap();
        let store = SheafStore::new(Arc::new(db));

        let s1 = Stalk::from_value(100.0);
        store.set_stalk(StalkContext::Public, 0, &s1).unwrap();

        let s2 = Stalk::from_value(200.0);
        store.set_stalk(StalkContext::Public, 0, &s2).unwrap();

        let loaded = store.get_stalk(StalkContext::Public, 0).unwrap().unwrap();
        assert_eq!(loaded.data[0], 200.0);
    }

    #[test]
    fn test_column_family_names() {
        assert_eq!(StalkContext::Private.column_family_name(), "stalks_private");
        assert_eq!(StalkContext::Public.column_family_name(), "stalks_public");
        assert_eq!(StalkContext::Zk.column_family_name(), "stalks_zk");
    }
}

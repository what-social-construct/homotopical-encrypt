// Sheaf-Aware Storage: Stalks as Column Families
//
// Natural transformation between math and storage:
//
// MATHEMATICAL STRUCTURE:
// - Sheaf = collection of stalks over simplicial complex
// - Stalk = local data at a vertex (dim = 1, 32, or 256)
// - Sections = global state (coherent collection of stalks)
//
// STORAGE STRUCTURE:
// - Column families = Stalk types (PRIVATE, PUBLIC, ZK)
// - Keys = Simplices (vertices, edges, faces)
// - Values = Stalk data (serialized vectors)
//
// - Formal functor definition F: SHEAF → STORAGE
// - Source category (SHEAF) with objects and morphisms
// - Target category (STORAGE) with objects and morphisms
// - Functoriality conditions explicitly stated:
//      1. F(id_F) = id_F(Sheaf)
//      2. F(η ∘ μ) = F(η) ∘ F(μ)


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
    /// This is a natural transformation!
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
}

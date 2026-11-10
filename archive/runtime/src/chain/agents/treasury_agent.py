"""
Protocol Orchestrator — Automated Agent Coordination

NOT a treasury. Reads from Treasury + CLMMPool, decides policy.
Treasury handles money (Petri net fee flow). This handles DECISIONS.

PETRI NET MODEL (Swan Table 2):
  This orchestrator IS a Petri net transition function:
  - Pre-arcs: state observation (spectral gap, pool reserves, Treasury balances)
  - Transition: agent proposals → priority resolution → action
  - Post-arcs: execute action on CLMMPool or Treasury

  Zaitsev colored Petri nets: the "topology tag switching" is the
  agent priority resolution — different network states activate
  different agents (hedge for IL, stabilizer for peg defense).

  Cushing 2-tier net: contract-program maps to our economic-geometric
  separation — agents reason about economics, CoherenceEngine about geometry.

ORCHESTRATOR LOOP (4-phase, from revenge-banana):
  Phase 1: Observe state (read Treasury + CLMMPool + spectral gap)
  Phase 2: Generate proposals from hedge + stabilizer
  Phase 3: Resolve via priority (emergency > hedge > stabilizer)
  Phase 4: Execute action + delegate feedback to FeedbackEngine

ALL AUTOMATED — no human operators. Nodes are identified by fibration
credentials and earn rewards proportional to harmonic weight.
"""

import numpy as np
from typing import Dict, Any, List, Optional

from . import AgentProposal, verify_bonding_curve_invariant
from .hedge_agent import HedgeAgent
from .stabilizer_agent import StabilizerAgent, compute_dynamic_fee
from .feedback import FeedbackEngine, DecisionRecord

# Canonical money layer (reads only — does not own money)
from ..treasury import Treasury
from ..clmm import CLMMPool


class ProtocolOrchestrator:
    """
    Automated agent coordination. Reads state, decides policy, executes.

    Does NOT manage money — Treasury does that (Petri net accumulator).
    This is the TRANSITION FUNCTION: observe → propose → resolve → fire.
    """

    def __init__(
        self,
        stalk_dim: int = 2,
        treasury: Optional[Treasury] = None,
        clmm_pool: Optional[CLMMPool] = None,
        feedback: Optional[FeedbackEngine] = None,
    ):
        self.name = "ProtocolOrchestrator"
        self.stalk_dim = stalk_dim

        # Sub-agents (geometric reasoning)
        self.hedge = HedgeAgent(stalk_dim=stalk_dim)
        self.stabilizer = StabilizerAgent()

        # External references (reads from, executes on)
        self.treasury = treasury
        self.clmm_pool = clmm_pool
        self.feedback = feedback

    # =================================================================
    # ORCHESTRATOR LOOP (Petri net transition)
    # =================================================================

    def step(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute one Petri net transition cycle.

        Phase 1: Observe (read Treasury + CLMMPool + spectral gap)
        Phase 2: Propose (hedge + stabilizer generate proposals)
        Phase 3: Resolve (priority: emergency > hedge > stabilizer)
        Phase 4: Execute (fire action on CLMMPool/Treasury) + feedback

        Args:
            state: Must contain spectral_gap, block_height.
                   May contain current_price, validator_stakes, stalks.

        Returns:
            Decision dict with action, amount, fee_recommendation.
        """
        # =============================================
        # PHASE 1: OBSERVE (pre-arcs)
        # =============================================
        spectral_gap = state.get('spectral_gap', 1.0)
        block_height = state.get('block_height', 0)
        price = state.get('current_price')

        # Inject Treasury + CLMMPool state (read-only)
        if self.treasury:
            state['stabilization_fund'] = self.treasury.stabilization_fund
            state['emergency_reserve'] = self.treasury.stabilization_fund  # Same fund
        if self.clmm_pool:
            state['reserve_homotopical_encrypt'] = self.clmm_pool.reserve_homotopical_encrypt
            state['reserve_vhomotopical_encrypt'] = self.clmm_pool.reserve_vhomotopical_encrypt
            state['current_price'] = self.clmm_pool.price_homotopical_encrypt_per_vhomotopical_encrypt
            price = state['current_price']

        # =============================================
        # PHASE 2: PROPOSE (agent reasoning)
        # =============================================
        proposals = []

        hedge_proposal = self.hedge.propose(state)
        if hedge_proposal.action_type != 'hold':
            proposals.append(hedge_proposal)

        stab_proposal = self.stabilizer.propose(state)
        if stab_proposal.action_type != 'hold':
            proposals.append(stab_proposal)

        # =============================================
        # CHECKPOINT: invariant gate
        # =============================================
        proposals = self._invariant_gate(proposals, state)

        # =============================================
        # PHASE 3: RESOLVE (transition function)
        # =============================================
        resolved = self._resolve_proposals(proposals, state)

        # Dynamic CLMM fee recommendation
        reserve_h = state.get('reserve_homotopical_encrypt', 0)
        reserve_v = state.get('reserve_vhomotopical_encrypt', 0)
        fee = compute_dynamic_fee(spectral_gap, reserve_h, reserve_v)

        # =============================================
        # PHASE 4: EXECUTE + FEEDBACK (post-arcs)
        # =============================================
        action = resolved.get('action', 'hold')
        amount = resolved.get('amount', 0)

        # Execute action on CLMMPool / Treasury
        executed = self._execute_action(action, amount)

        # Record decision + compute feedback
        decision_hash = b''
        if self.feedback is not None:
            record = self.feedback.record_decision(
                action=action,
                amount=amount,
                block_height=block_height,
                spectral_gap=spectral_gap,
                price=price,
            )
            decision_hash = record.decision_hash

            # Hebbian feedback if ≥2 decisions
            if len(self.feedback.decision_history) >= 2:
                prev = self.feedback.decision_history[-2]
                curr = self.feedback.decision_history[-1]
                reward = self.feedback.compute_reward_direction(prev, curr)
                lr = self.feedback.get_modulated_lr(spectral_gap)
                self.hedge.update_from_feedback(reward, lr)
                self.stabilizer.update_from_feedback(reward, lr)

        return {
            'action': action,
            'amount': amount,
            'executed': executed,
            'source_agent': resolved.get('source', self.name),
            'fee_recommendation': fee,
            'proposals_count': len(proposals),
            'decision_hash': decision_hash.hex()[:16] if decision_hash else '',
            'stabilization_fund': self.treasury.stabilization_fund if self.treasury else 0,
        }

    # =================================================================
    # ACTION EXECUTION (Petri net post-arcs)
    # =================================================================

    def _execute_action(self, action: str, amount: int) -> bool:
        """
        Fire action on CLMMPool or Treasury.

        Returns True if action was executed.
        """
        if amount <= 0 or action == 'hold':
            return False

        if action == 'buyback' and self.clmm_pool and self.treasury:
            # Spend from stabilization fund → buy HOMOTOPICAL_ENCRYPT on pool
            if self.treasury.spend_stabilization(amount):
                ok, received = self.clmm_pool.swap_homotopical_encrypt_for_vhomotopical_encrypt(amount)
                return ok
            return False

        elif action == 'sell_at_resistance' and self.clmm_pool:
            # Sell vHOMOTOPICAL_ENCRYPT → HOMOTOPICAL_ENCRYPT on pool (strengthens HOMOTOPICAL_ENCRYPT)
            ok, received = self.clmm_pool.swap_vhomotopical_encrypt_for_homotopical_encrypt(amount)
            return ok

        elif action == 'burn' and self.treasury:
            # Burn from stabilization fund
            if self.treasury.spend_stabilization(amount):
                self.treasury.total_burned += amount
                return True
            return False

        elif action == 'inject_liquidity' and self.clmm_pool and self.treasury:
            # Add liquidity to pool from stabilization fund
            if self.treasury.spend_stabilization(amount):
                half = amount // 2
                self.clmm_pool.reserve_homotopical_encrypt += half
                self.clmm_pool.reserve_vhomotopical_encrypt += (amount - half)
                return True
            return False

        return False

    # =================================================================
    # PROPOSAL RESOLUTION (Zaitsev topology tag switching)
    # =================================================================

    def _resolve_proposals(
        self, proposals: List[AgentProposal], state: Dict
    ) -> Dict[str, Any]:
        """
        Priority-based resolution (topology tag switching).

        Different network states activate different agents:
        - Crisis (spectral gap far from 1.0) → stabilizer wins
        - IL detected → hedge wins
        - Normal → hold
        """
        if not proposals:
            return {'action': 'hold', 'amount': 0, 'source': self.name}

        # Emergency always wins
        emergencies = [p for p in proposals if 'emergency' in p.action_type]
        if emergencies:
            p = max(emergencies, key=lambda x: x.confidence)
            return {'action': p.action_type, 'amount': p.rationale.get('amount', 0), 'source': p.agent_id}

        # Hedge gets priority boost (IL is time-sensitive)
        hedge_proposals = [p for p in proposals if p.agent_id == 'HedgeAgent']
        for hp in hedge_proposals:
            hp.confidence = min(0.95, hp.confidence * 1.2)

        # Concentration warnings are high priority
        concentrations = [p for p in proposals if p.action_type == 'concentration_warning']
        if concentrations:
            p = concentrations[0]
            return {'action': p.action_type, 'amount': 0, 'source': p.agent_id}

        # Highest confidence wins
        best = max(proposals, key=lambda x: x.confidence)
        return {'action': best.action_type, 'amount': best.rationale.get('amount', 0), 'source': best.agent_id}

    # =================================================================
    # INVARIANT GATE (metaspecification check)
    # =================================================================

    def _invariant_gate(
        self, proposals: List[AgentProposal], state: Dict
    ) -> List[AgentProposal]:
        """Filter proposals that would violate bonding curve invariant."""
        valid = []
        for p in proposals:
            if p.action_type in ('buyback', 'sell_at_resistance', 'inject_liquidity'):
                amount = p.rationale.get('amount', 0)
                pool_reserve = state.get('reserve_homotopical_encrypt', 0) + state.get('reserve_vhomotopical_encrypt', 0)
                if pool_reserve > 0 and amount > 0:
                    ok, reason = self.stabilizer.check_swap_limit(
                        b'orchestrator', amount, pool_reserve
                    )
                    if not ok:
                        continue

            if p.action_type in ('buyback', 'sell_at_resistance'):
                k_before = state.get('reserve_homotopical_encrypt', 0) * state.get('reserve_vhomotopical_encrypt', 0)
                if k_before > 0:
                    ok, reason = verify_bonding_curve_invariant(
                        k_before=k_before,
                        k_after=k_before,
                        reserve_homotopical_encrypt=state.get('reserve_homotopical_encrypt', 0),
                        reserve_vhomotopical_encrypt=state.get('reserve_vhomotopical_encrypt', 0),
                        swap_amount=p.rationale.get('amount', 0),
                    )
                    if not ok:
                        continue

            valid.append(p)
        return valid

    # =================================================================
    # EPOCH MANAGEMENT
    # =================================================================

    def reset_epoch(self):
        """Reset per-epoch tracking."""
        self.stabilizer.reset_epoch()

    def diagnostics(self) -> Dict[str, Any]:
        """Full orchestrator state for debugging."""
        history = self.feedback.decision_history if self.feedback else []
        return {
            'stabilization_fund': self.treasury.stabilization_fund if self.treasury else 0,
            'protocol_fund': self.treasury.protocol_fund if self.treasury else 0,
            'pool_reserves': {
                'homotopical_encrypt': self.clmm_pool.reserve_homotopical_encrypt if self.clmm_pool else 0,
                'vhomotopical_encrypt': self.clmm_pool.reserve_vhomotopical_encrypt if self.clmm_pool else 0,
            },
            'decisions': len(history),
            'last_action': history[-1].resolved_action if history else 'none',
            'hedge_thresholds': {
                'theta_1': self.hedge.theta_1,
                'theta_2': self.hedge.theta_2,
                'theta_3': self.hedge.theta_3,
            },
            'stabilizer_layers': {
                'layer_1_dev': self.stabilizer.layer_1_dev,
                'layer_2_dev': self.stabilizer.layer_2_dev,
                'layer_3_dev': self.stabilizer.layer_3_dev,
            },
            'support': self.stabilizer.support_price,
            'resistance': self.stabilizer.resistance_price,
        }

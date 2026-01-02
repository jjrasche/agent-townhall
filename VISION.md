# Agent Townhall - Vision

**Agent Townhall is a generic multi-agent coordination platform built on Everything Stack. This document describes the template validation use case (CSA Golden Twin), but the platform itself is domain-agnostic.**

## Template Validation Use Case: CSA Golden Twin

Policymakers and CSA organizers lack tools to understand **how policy changes affect farmer behavior in realistic, measurable ways**.

- A subsidy on organic transition might encourage adoption OR create market distortions
- Labor cost increases might push farms toward automation OR consolidation
- Crop rotation requirements might improve soil health BUT reduce short-term yield
- Trust in institutions affects whether farmers try new practices

Without simulation, they guess. Guessing leads to policies that backfire.

---

## The Solution

**CSA Golden Twin**: A digital farm simulation where:

1. **NPCs (farmer personas) behave realistically** - They respond to incentives, peer influence, risk, and emotion like real farmers do
2. **Policy parameters can be adjusted** - Subsidies, regulations, market prices, climate patterns
3. **Outcomes are measurable** - Yield, soil health, farmer satisfaction, adoption rates
4. **AI tells the story** - Why did this policy work? What unintended consequences happened?
5. **System learns from feedback** - Run simulation, get outcomes, adjust policy, run again → convergence on better policies

The system bridges the gap between abstract policy and human reality.

---

## Core Insight

Most policy simulation is either:
- **Pure math models** (accurate but disconnected from human behavior)
- **Agent-based models** (realistic but computationally expensive)
- **Interactive visualizations** (engaging but don't predict outcomes)

CSA Golden Twin combines all three:
- **Personas with emotional state** (realistic behavior, from Educator Builder patterns)
- **Simulation engine** (fast enough to run 100+ variations)
- **AI narrative generation** (explains what happened and why)
- **Learnable mechanics** (system improves predictions over time)

---

## Success Criteria

In 6 months, CSA Golden Twin succeeds when:

1. **Policymakers can ask: "What if we raised the organic subsidy to $100/acre?"**
   - System runs simulation with 10 farmer personas
   - Shows: adoption rate 70% (up from 40%), yield -5%, soil health +12%, farmer satisfaction +8%
   - AI narrates: "Higher subsidies encouraged adoption, but some farmers prioritized volume over techniques"

2. **Users can run 100 policy variations in parallel**
   - Multiple Claude agents work simultaneously on different simulations
   - Results compared to find optimal policy combination
   - Convergence: "These 3 policies together maximize satisfaction without yield loss"

3. **Farmers recognize themselves in the personas**
   - "That's exactly how my neighbor reacts to price changes"
   - Personas feel realistic because they're trained on real data + feedback

4. **Policymakers trust the results**
   - Outcomes match historical data when policy parameters match real history
   - System is transparent: "Farmer adopted because satisfaction > 0.7 and peer adoption > 40%"
   - Users provide feedback: "This actually happened in our region" → system learns

---

## Primary Users

**Policymakers and CSA coordinators** who need to:
- Understand farmer decision-making
- Test policies before implementation
- Communicate impact to stakeholders
- Identify unintended consequences early

**Not** for: Individual farmers, general audience (too specialized)

---

## Non-Goals for v1

- Real-time multiplayer gameplay (v2)
- Mobile app (web first, mobile v2)
- Weather simulation (static weather patterns v1)
- Multi-farm supply chains (single farm v1)
- Real integration with policy databases (manual input v1)
- Compliance with specific regulations (general framework v1)

---

## Key Constraints

- **Tech Stack**: Flutter + Dart (cross-platform requirement)
- **Timeline**: Parallel tracks - Phase 1 (visuals) + Phase 2 (multi-agent logic) in parallel
- **Team**: 4 agents (Ideation, Architect, Coder, Researcher) working asynchronously
- **Data**: Use public agricultural data (USDA, university research), not proprietary
- **Quality**: E2E tests on all platforms (iOS, Android, macOS, Windows, Linux, Web)

---

## Why Now?

1. **AI can generate realistic NPC behavior** - LLMs understand decision-making
2. **Semantic search enables agent coordination** - Multiple AIs can collaborate without human relay
3. **Interactive policy simulation is urgent** - Climate/food policy decisions are happening now
4. **CSA movement is growing** - Data and interest exist

---

## Measures of Success

| Metric | Target | Validation |
|--------|--------|------------|
| Personas feel realistic | 80%+ user agreement | User feedback on personas |
| Simulation outcomes match historical data | R² > 0.8 | Compare simulated yields to USDA data |
| Agent collaboration is efficient | No manual relay | Agents coordinate via whiteboard |
| System learns from feedback | Improvement over 10 runs | Measure prediction accuracy growth |
| Platform coverage | All 6 platforms working | Integration tests pass |

---

## Phase Breakdown

### Phase 1: Visual Foundation (Weeks 1-4)
- 3D CSA scene with worker NPCs
- Policy parameter sliders
- Real-time visualization of farm activity

### Phase 2: Multi-Agent Coordination (Weeks 2-6, parallel)
- Semantic whiteboard for agent communication
- Simulation engine with realistic persona behavior
- Outcome tracking and narrative generation

### Phase 3: Learning Loop (Weeks 7-8)
- Feedback collection on personas and policies
- Adaptation based on user feedback
- Historical outcome comparison

### Phase 4: Polish and Launch (Weeks 9-12)
- E2E tests on all platforms
- Documentation and tutorials
- Beta testing with real CSA groups

---

## What Makes This Different

| Aspect | Traditional Policy Model | CSA Golden Twin |
|--------|---------|------------|
| **Behavior Model** | Equations/heuristics | Realistic personas with emotions |
| **Interaction** | Text input/output | 3D visualization + narrative |
| **Feedback Loop** | Manual recalculation | Automatic system learning |
| **Team Collaboration** | Sequential handoff | Parallel semantic coordination |
| **Transparency** | Black box equations | Decision logs, reasoning visible |

---

## Long-term Vision (Years 2-3)

- Multi-farm supply chain simulation
- Weather/climate variation
- Integration with real policy databases
- Community of CSA groups sharing simulation results
- Policy recommendation engine: "Policies used successfully in similar regions"

---

**Document Created**: January 2, 2026
**Status**: Active Development
**Lead**: Ideation Partner (Claude)

# CSA Golden Twin: Multi-Agent Coordination Design

**Status**: Draft for Architect/Coder/Researcher Review
**Last Updated**: January 2, 2026

---

## Overview

The CSA Golden Twin is a digital simulation system where:
- **Multiple AI agents collaborate asynchronously** (Ideation Partner, Coder, Architect, Researcher)
- **Agents communicate via a shared semantic whiteboard** (HNSW-indexed event log)
- **Simulation runs show realistic NPC behavior** informed by policy parameters
- **System learns from feedback** and adapts recommendations over time

This design leverages Everything Stack's Invocation/Event model, Trainable patterns, and Embeddable mixins to create a self-coordinating multi-agent system.

---

## Core Problem Statement

**Status Quo**: Multiple Claude instances work on CSA simulation:
- Ideation Partner generates ideas
- Coder implements features
- Architect reviews design
- Researcher provides data

**Pain**: Manual relay between agents → context switching → delays → redundant work

**Solution**: Shared semantic whiteboard where agents:
1. Propose work items (events)
2. Discover related context via HNSW search
3. Coordinate asynchronously without relay
4. Learn from feedback on previous proposals

---

## System Architecture

### Layer 1: Shared Semantic Whiteboard

**Concept**: Single HNSW-indexed event log accessible to all agents

```
Events Published by Agents:
├── IdeationProposal("Add crop rotation mechanics")
│   ├── embedding: [0.123, 0.456, ...]  [HNSW indexed]
│   ├── topic: 'crop-rotation'
│   ├── context: { persona: 'farmer', goal: 'soil-health' }
│   └── status: 'proposed'
│
├── ArchitectQuestion("How do crop rotations affect yield?")
│   ├── respondingTo: <IdeationProposal.id>
│   ├── status: 'needs-answer'
│   └── priority: 'high'
│
└── ResearcherAnswer("Crop rotation increases yield 12-15%...")
    ├── respondingTo: <ArchitectQuestion.id>
    ├── dataSource: 'USDA FarmBureauData'
    └── confidence: 0.92
```

**Discovery**: Agents search by meaning, not keywords:
- Coder searches: "How do mechanics work with farmer personas?"
- System returns: [IdeationProposal, ArchitectQuestion, ResearcherAnswer] ranked by semantic similarity
- Coder sees the conversation history, context, and data

### Layer 2: Agent Roles & Responsibilities

#### Ideation Partner
- **Input**: CSA project context, policy parameters
- **Output**: Feature proposals, mechanic ideas, narrative suggestions
- **Tools**: Proposes AgentEvent → Publishes to whiteboard
- **Learning**: Feedback on "this feature is too complex" → simpler proposals next time

#### Architect
- **Input**: Ideation proposals, implementation constraints
- **Output**: Design reviews, architecture decisions, entity schemas
- **Tools**: Asks questions → Reviews proposals → Approves or suggests changes
- **Learning**: Feedback on "this design led to bugs" → stricter reviews next time

#### Coder
- **Input**: Approved designs, entity schemas, test cases
- **Output**: Implementation code, tests, performance notes
- **Tools**: Implements → Requests clarification → Reports blockers
- **Learning**: Feedback on "this code had N bugs" → adds tests

#### Researcher
- **Input**: Research queries from team, data requirements
- **Output**: Data analysis, citations, confidence scores
- **Tools**: Queries data → Publishes findings → Provides context
- **Learning**: Feedback on "this analysis was useful/not useful" → adjusts depth

### Layer 3: Entity Model

#### Core Entities

```dart
/// AgentEvent - Base event type for agent communication
class AgentEvent extends BaseEntity with Embeddable, Trainable {
  final String agentId;              // 'ideation', 'architect', 'coder', 'researcher'
  final String eventType;            // 'proposal' | 'question' | 'answer' | 'decision' | 'blocker'
  final String topic;                // 'crop-rotation', 'farmer-persona', 'policy-mechanic'
  final String content;              // Full event content (proposal text, question, etc.)
  final String? respondingTo;        // Parent event ID (creates conversation threads)
  final List<String> linkedEventIds; // Related event IDs (context)
  final Map<String, dynamic> metadata; // topic-specific data

  final String? approvalStatus;      // null | 'approved' | 'changes-requested' | 'rejected'
  final String? approvedBy;          // Architect agent ID (who approved)
  final int priority;                // 1-5 (high to low)

  final bool resolved;               // Has this been acted on?
  final DateTime timestamp;
  final DateTime? resolvedAt;

  // Embeddable requirement
  @override
  Future<List<double>> generateEmbedding(EmbeddingService embedder) async {
    // Combine content + topic for semantic search
    final text = '$topic: $content';
    return await embedder.embed(text);
  }

  // Trainable requirement
  @override
  Future<void> trainFromFeedback(String correlationId) async {
    // Learn from feedback on this event
    // Example: if proposal was rejected, learn not to propose similar ideas
  }
}

/// AgentState - Track what each agent is working on
class AgentState extends BaseEntity {
  final String agentId;
  final String phase;                // 'discovering', 'proposing', 'implementing', 'reviewing'
  final String currentTopic;         // What the agent is focused on
  final List<String> workingEventIds; // Events this agent is currently processing
  final DateTime lastActivity;

  // Historical proposals this agent made (for learning)
  final List<String> proposalHistory; // AgentEvent IDs
  final Map<String, double> topicInterest; // How interested in each topic
}

/// SimulationContext - Shared project context
class SimulationContext extends BaseEntity with Embeddable {
  final String projectName;          // "CSA Golden Twin v2"
  final String phase;                // 'design' | 'implementation' | 'testing'
  final Map<String, dynamic> policies; // { 'crop-subsidy': 0.8, 'labor-cost': 25 }

  // NPC/Persona configuration
  final List<FarmerPersona> personas;
  final List<String> npcsInScene;

  // Simulation parameters
  final int simulationMonths;
  final List<String> measuredOutcomes; // ['yield', 'farmer-satisfaction', 'soil-health']

  // This enables agents to search for "CSA projects with crop rotation"
  @override
  Future<List<double>> generateEmbedding(EmbeddingService embedder) async {
    final text = '$projectName $phase policies: ${policies.keys.join(",")}';
    return await embedder.embed(text);
  }
}

/// FarmerPersona - Simulation agent (NPC)
class FarmerPersona extends BaseEntity with Trainable {
  final String personaId;            // 'farmer-1', 'farmer-2'
  final String archetype;            // 'maximizer', 'satisficer', 'traditionalist'

  // Emotional state (from Educator Builder pattern)
  final Map<String, double> emotionalState; // {
  //   'goalProgress': 0.6,
  //   'frustration': 0.2,
  //   'engagement': 0.8,
  //   'trust': 0.5,
  //   'connection': 0.4,
  //   'novelty': 0.7
  // }

  // Decision thresholds
  final Map<String, double> decisionThresholds; // {
  //   'willAdoptNewCrop': 0.7,  // if goalProgress > 0.7, try new crop
  //   'wilSwitchToOrganic': 0.6
  // }

  // History of interactions
  final List<String> interactionEventIds; // Events where this persona was involved

  @override
  Future<void> trainFromFeedback(String correlationId) async {
    // Update thresholds based on outcomes
    // Example: "This policy made farmer quit" → adjust willingness-to-stay threshold
  }
}

/// SimulationResult - What happened in a run
class SimulationResult extends BaseEntity with Embeddable {
  final String simulationId;
  final String contextId;            // Reference to SimulationContext
  final int runNumber;

  // Outcome metrics
  final Map<String, double> outcomes; // {
  //   'averageYield': 4.2,
  //   'farmerSatisfaction': 0.72,
  //   'soilHealth': 0.85
  // }

  // Narrative: AI-generated story of what happened
  final String narrative;            // "Farmers adopted crop rotation..."

  // Which personas succeeded/failed
  final Map<String, dynamic> personaOutcomes; // {
  //   'farmer-1': { 'adopted': true, 'satisfaction': 0.8 },
  //   'farmer-2': { 'adopted': false, 'reason': 'cost' }
  // }

  // Events that happened during simulation
  final List<String> simulationEventIds;

  @override
  Future<List<double>> generateEmbedding(EmbeddingService embedder) async {
    // Narrative makes this searchable by outcome
    final text = '$narrative outcomes: ${outcomes.values.join(",")}';
    return await embedder.embed(text);
  }
}
```

### Layer 4: Coordination Protocol

#### Propose → Review → Approve → Implement Workflow

**Step 1: Proposal (Ideation or Coder)**

```
Ideation publishes:
{
  agentId: 'ideation',
  eventType: 'proposal',
  topic: 'crop-rotation',
  content: 'Add crop rotation mechanic that rotates legume/grain/fallow...',
  metadata: {
    affectsPersonas: ['farmer-1', 'farmer-2'],
    requiresData: ['soilNitrogen', 'pestPressure'],
    estimatedComplexity: 'medium'
  },
  priority: 4
}
```

**Step 2: Question → Answer (Architect/Researcher)**

```
Architect searches whiteboard:
"What data is needed for crop rotation?"
→ Returns [IdeationProposal, ResearcherAnswer about legume nitrogen fixation]

Architect publishes question:
{
  agentId: 'architect',
  eventType: 'question',
  respondingTo: <IdeationProposal.id>,
  content: 'How do we model nitrogen replenishment from legumes?',
  priority: 5  // Blocking
}

Researcher publishes answer:
{
  agentId: 'researcher',
  eventType: 'answer',
  respondingTo: <ArchitectQuestion.id>,
  content: 'Legumes fix 50-200 kg N/hectare/year depending on species...',
  metadata: {
    source: 'USDA',
    confidence: 0.95,
    citations: ['https://...']
  }
}
```

**Step 3: Decision (Architect)**

```
Architect publishes decision:
{
  agentId: 'architect',
  eventType: 'decision',
  respondingTo: <IdeationProposal.id>,
  approvalStatus: 'approved',
  content: 'Approve crop rotation mechanic. Coder: implement with schema...',
  linkedEventIds: [
    <IdeationProposal.id>,
    <ArchitectQuestion.id>,
    <ResearcherAnswer.id>
  ]
}
```

**Step 4: Implementation (Coder)**

```
Coder searches whiteboard for decision:
"What needs implementation?"
→ Returns approved proposals with architect decision

Coder publishes:
{
  agentId: 'coder',
  eventType: 'proposal',  // Propose implementation approach
  respondingTo: <ArchitectDecision.id>,
  topic: 'crop-rotation-implementation',
  content: 'I will add CropRotationMechanic entity with fields: currentCrop, rotation, nitrogen level',
  metadata: {
    schema: { ... },
    testCases: [ ... ],
    estimatedHours: 3
  }
}

// After coding:
Coder publishes:
{
  agentId: 'coder',
  eventType: 'answer',
  respondingTo: <CoderImplementationProposal.id>,
  content: 'Implementation complete. Tests pass on all platforms.',
  metadata: {
    pullRequest: 'https://...',
    testCoverage: 0.92
  }
}
```

#### Error/Blocker Handling

```
If Coder hits blocker:
{
  agentId: 'coder',
  eventType: 'blocker',
  topic: 'crop-rotation-implementation',
  content: 'ObjectBox schema doesnt support computed fields. Need to store nitrogen level as field?',
  respondingTo: <IdeationProposal.id>,
  priority: 5
}

// Whiteboard propagates to Architect
// Architect searches semantically: "ObjectBox schema problems"
// Architect sees blocker → publishes answer with pattern
```

---

## Integration with Everything Stack

### Patterns Used

| Pattern | Purpose | Implementation |
|---------|---------|---|
| **Embeddable** | Agents search by meaning, not keywords | AgentEvent, SimulationContext, SimulationResult embed full content |
| **Trainable** | System learns from feedback | FarmerPersona, AgentEvent learn from outcomes, user feedback |
| **Temporal** | Track when events happen | All events have timestamp, resolved/resolvedAt |
| **Ownable** | Track which agent created event | agentId field on all events |
| **Event** | Immutable record of what happened | AgentEvent is the core entity type |
| **Invocation** | Log every tool call agents make | When an agent proposes/approves/implements, create Invocation log |

### Services

```dart
// New services for multi-agent coordination

class WhiteboardService {
  final AgentEventRepository eventRepository;
  final EmbeddingService embeddingService;

  // Publish event (creates + embeds + indexes in HNSW)
  Future<AgentEvent> publishEvent(AgentEvent event) async {
    final embedded = await embeddingService.embed(...);
    return await eventRepository.save(event.copyWith(embedding: embedded));
  }

  // Search by meaning
  Future<List<AgentEvent>> searchByTopic(String query, {int limit = 10}) async {
    final queryEmbedding = await embeddingService.embed(query);
    return await eventRepository.semanticSearch(queryEmbedding, limit: limit);
  }

  // Get conversation thread
  Future<List<AgentEvent>> getThread(String eventId) async {
    // Event + all responses + all linked events
  }
}

class CoordinationService {
  final WhiteboardService whiteboard;
  final AgentStateRepository stateRepository;

  // Agent discovers work
  Future<List<AgentEvent>> discoverWork(String agentId) async {
    final state = await stateRepository.findByAgentId(agentId);
    // Search for:
    // - Unapproved proposals (for Architect)
    // - Blockers (for Researcher)
    // - Approved items (for Coder)
  }

  // Mark event as resolved
  Future<AgentEvent> resolveEvent(String eventId) async {
    // Mark as resolved, trigger learning on this event
  }
}

class SimulationService {
  // Run simulation with current policy + personas
  Future<SimulationResult> runSimulation(String contextId) async {
    // Load context
    // Run personas through mechanics
    // Generate narrative
    // Log outcomes
    // Publish to whiteboard as SimulationResult
  }
}
```

### MCP Tools for Agent Communication

```dart
// Tools agents can call

class WhiteboardTools {
  static ToolDefinition publishEventTool = ToolDefinition(
    name: 'whiteboard.publish',
    description: 'Publish event to shared whiteboard',
    parameters: {
      'agentId': 'The agent publishing (coder, architect, etc.)',
      'eventType': 'proposal | question | answer | decision | blocker',
      'topic': 'What this is about',
      'content': 'Full event text',
      'respondingTo': 'Parent event ID (optional)',
      'metadata': 'Topic-specific data'
    }
  );

  static ToolDefinition searchWhiteboardTool = ToolDefinition(
    name: 'whiteboard.search',
    description: 'Search whiteboard by meaning',
    parameters: {
      'query': 'What are you looking for?',
      'limit': '(optional, default 10)'
    }
  );

  static ToolDefinition discoverWorkTool = ToolDefinition(
    name: 'whiteboard.discover-work',
    description: 'Find work items for your agent role',
    parameters: {
      'agentId': 'Your agent ID'
    }
  );
}

class SimulationTools {
  static ToolDefinition runSimulationTool = ToolDefinition(
    name: 'simulation.run',
    description: 'Run CSA simulation with current policies',
    parameters: {
      'contextId': 'SimulationContext ID',
      'months': 'How many months to simulate',
      'personas': 'Which personas to include'
    }
  );

  static ToolDefinition queryDataTool = ToolDefinition(
    name: 'research.query',
    description: 'Query research data/sources',
    parameters: {
      'query': 'What do you want to know?',
      'topic': 'crop-rotation, farmer-archetypes, etc.'
    }
  );
}
```

---

## Learning System

### How Feedback Trains the System

#### Agent Learning

```
1. Ideation proposes feature X
   → Creates AgentEvent with metadata: { complexity: 'high' }

2. Three months later, Coder spent 40 hours implementing X
   → Much longer than expected

3. Team provides feedback: "Too ambitious, broke multiple things"
   → AdaptationState updated: proposals with complexity > 'medium' get lower confidence

4. Ideation makes next proposal
   → Lower confidence when complexity > 'medium'
   → Suggests simpler approach
```

#### Persona Learning

```
1. Simulation shows farmer persona rejects crop rotation
   → Decision threshold was: willAdoptNewCrop = 0.8

2. User provides feedback: "Farmers would adopt if price incentive > $50/acre"
   → Update decision threshold: add 'priceIncentive' factor

3. Next simulation: lower price point, higher adoption
   → System learns the incentive structure
```

#### Simulation Learning

```
1. Run simulation with policy A: outcomes = [yield: 3.5, satisfaction: 0.6]

2. Run simulation with policy B: outcomes = [yield: 3.8, satisfaction: 0.7]

3. Ideation uses this history to propose better policies
   → Suggests variations on policy B
   → Search shows similar contexts where policy B worked
```

---

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
- [ ] Create AgentEvent, AgentState, SimulationContext, FarmerPersona entities
- [ ] Implement WhiteboardService with semantic search
- [ ] Wire up Embeddable/Trainable mixins
- [ ] Create MCP tools for publish/search/discover-work

### Phase 2: Coordination (Weeks 3-4)
- [ ] Implement proposal → approval workflow
- [ ] Create SimulationService (run simulations, log results)
- [ ] Add Invocation logging to all agent actions
- [ ] Create UI for whiteboard viewing

### Phase 3: Learning (Weeks 5-6)
- [ ] Implement feedback collection on proposals
- [ ] Train AgentState from historical feedback
- [ ] Train FarmerPersona emotional state from simulation results
- [ ] Create adaptation rules (complexity → proposals, outcome → policies)

### Phase 4: Integration (Weeks 7+)
- [ ] Wire agents via MCP (Claude Code hooks)
- [ ] Run parallel tracks: Phase 1 visuals + Phase 2 multi-agent
- [ ] Test end-to-end agent collaboration
- [ ] Iterate based on feedback

---

## Critical Design Decisions

### Why AgentEvent, not Task?

**Alternative**: Use generic Task entity for all agent work

**Rejected because**:
- Tasks don't naturally support conversation (responding to each other)
- Tasks don't show context (linked events, thread history)
- Task feedback is isolated; agent feedback is systemic

**AgentEvent chosen because**:
- Natural conversation threading (respondingTo)
- Embeddable: semantic search finds context
- Trainable: each event learns from feedback
- Metadata: topic-specific data for each domain

### Why Whiteboard, not Direct API?

**Alternative**: Each agent calls Coder's API, Architect's API, etc.

**Rejected because**:
- Agents need to see each other's work asynchronously
- Context is scattered across agent systems
- Discovery requires explicit queries

**Whiteboard chosen because**:
- Single source of truth (event log)
- Semantic search finds relevant context
- Agents discover work without being asked
- Conversation history preserved

### Why HNSW for Search?

**Alternative**: Keyword search or BM25

**Rejected because**:
- "How do mechanics work with farmers?" doesn't match keyword "mechanic"
- Agents need to find semantic context, not keyword matches
- HNSW on Everything Stack is proven (8-12ms queries)

**HNSW chosen because**:
- Semantic similarity surfaces context naturally
- Fast queries (< 50ms for discovery)
- Native support in ObjectBox
- IndexedDB support via cosine similarity

---

## Success Criteria for Implementation

v1 is complete when:

1. **Agents can communicate asynchronously**
   - Ideation publishes proposal
   - Architect reviews, publishes decision
   - Coder implements, publishes result
   - All visible on whiteboard in conversation thread

2. **Semantic search works**
   - Search "crop rotation" finds proposals, questions, answers, simulation results
   - Agents discover context without explicit relay

3. **Simulation produces outcomes**
   - Run with farmer personas
   - Outcomes match expectations (yield, satisfaction, etc.)
   - Narrative generated by AI

4. **System learns**
   - Simulation results influence future proposals
   - Feedback on proposals affects agent behavior
   - Historical context improves decisions

5. **Cross-platform**
   - All code runs on iOS, Android, Web, macOS, Windows, Linux
   - Tests pass on all 6 platforms

---

## Open Questions for Review

1. **Approval gates**: Should Architect approve all proposals, or only some? How do we prevent bottlenecks?

2. **Conflict resolution**: If two agents disagree, who decides? (Currently: Architect has final say)

3. **Async latency**: Agents work asynchronously. How long before decision is expected? (Currently: no SLA)

4. **Learning speed**: How much feedback before system adapts? (Currently: any feedback triggers update)

5. **Narrative generation**: How detailed should simulation narratives be? (Currently: TBD)

---

## Next Steps

1. **Architect review**: Does this design work? Any missing pieces?
2. **Coder prep**: Can you implement the entity layer + repositories?
3. **Researcher prep**: What data format do you need for queries?
4. **Parallel tracks**:
   - Phase 1 (visuals): Continue with 3D CSA scene
   - Phase 2 (multi-agent): Start with entity + whiteboard service

---

**Design by**: Ideation Partner (Claude)
**For review by**: Architect, Coder, Researcher
**Status**: Ready for feedback


# Agent Townhall Architecture

**Multi-agent coordination platform built on Everything Stack.**

---

## Core Vision

Agent Townhall enables multiple AI agents to collaborate asynchronously within a shared room. Agents publish observations, discover work via semantic search, and coordinately solve complex problems. A human manager orchestrates the workspace: defines scope, edits summaries, assigns work, and decides when scope is complete. Everything is logged for continuous learning.

---

## Fundamental Design

### Execution Fungibility (Everything Stack Core)
Humans and agents use identical infrastructure:

- **Human path**: Voice → Coordinator → LLM reasoning → tool execution → response
- **Agent path**: Event trigger → AgentOrchestrator → deterministic logic → tool execution → observation

Both paths:
- Use ToolExecutor identically
- Log Invocations identically
- Train from same feedback loop
- Persist results identically

Swap human for agent, LLM for rules, local for remote—infrastructure doesn't care.

### Separation of Concerns
- **Role** = Functional responsibility (Architect, Coder, Analyst—what they do)
- **Persona** = Individual style (pragmatist, perfectionist, methodical—who they are)
- **Agent** = Role + Persona in a Room (concrete instance)

An agent has both. A role can have multiple personas. A persona can be assigned to different roles.

---

## Core Entities

### Room
Collaboration scope container.

**Fields:**
- `id: String` (UUID)
- `name: String`
- `description: String` (what scope is being solved)
- `agentIds: List<String>` (current roster)
- `status: String` ('active', 'completed', 'archived')
- `createdAt: DateTime`
- `completedAt: DateTime?`

**Why:** Rooms partition data and define scope. All entities scoped by roomId. Manager decides when scope is complete and room transitions to completed/archived.

### Agent
Concrete instance of role + persona in a room.

**Fields:**
- `id: String` (UUID)
- `roomId: String` (which room)
- `roleId: String` (link to Role)
- `personaId: String` (link to Persona)
- `personaAdaptationId: String` (learned behavior specific to this agent instance)
- `createdAt: DateTime`

**Why:** Agents have state (PersonaAdaptation per agent instance). No autonomous joining/leaving—all orchestrated by manager.

### Role
Shared archetype defining function and system prompt base.

**Fields:**
- `id: String` (UUID)
- `name: String` ('Architect', 'Coder', 'Analyst')
- `systemPrompt: String` (how this role thinks)
- `description: String`
- `createdAt: DateTime`

**Why:** Multiple agents can share a role. Immutable (doesn't change mid-room).

### Persona
Shared style/characteristic pattern.

**Fields:**
- `id: String` (UUID)
- `name: String` ('pragmatist', 'perfectionist', 'methodical')
- `description: String` (behaviors, preferences)
- `createdAt: DateTime`

**Why:** Decoupled from role. Manager can create new personas on-the-fly. Agents can swap personas mid-room.

### PersonaAdaptation
What an agent learned specific to their persona.

**Fields:**
- `id: String` (UUID)
- `agentId: String` (which agent)
- `personaId: String` (which persona—for tracking persona-specific learning)
- `roomId: String` (which room context)
- `learnedThresholds: Map<String, double>` (confidence adjustments, strategy weights)
- `observationCounts: Map<String, int>` (how many times each observation type used)
- `version: int` (for optimistic locking on multi-device)

**Patterns:** Trainable — learns from feedback on agent performance

**Why:** If agent swaps personas mid-room, learning doesn't transfer. Each (agent, persona) pair has separate adaptation. Enables: "Agent learned X as analyst, but as architect they learn Y differently."

### Turn
Temporal boundary and metadata holder for entire room state.

**Fields:**
- `id: String` (UUID)
- `roomId: String`
- `turnNumber: int` (sequence in room)
- `startedAt: DateTime`
- `endedAt: DateTime?`
- `narrativeId: String?` (reference to generated narrative)
- `eventCount: int` (how many ObservationEvents published)
- `agentStates: Map<String, dynamic>` (snapshot of agent state at turn end)

**Why:** Structural boundary. Holds metadata to contextualize entire turn. Agents work concurrently during turn. Turn ends when manager decides or system heuristic triggers (e.g., "10+ events published").

### ObservationEvent
Agent publishes observation to room.

**Fields:**
- `id: String` (UUID)
- `agentId: String` (which agent)
- `roomId: String` (which room)
- `turnNumber: int` (which turn)
- `eventType: String` ('question', 'blocker', 'solution', 'agreement', 'disagreement', 'observation', 'decision', 'analysis', 'concern', 'clarification')
- `content: String` (human-readable statement)
- `respondingToEventId: String?` (parent event—threading)
- `confidence: double?` (agent's confidence 0.0-1.0)
- `timestamp: DateTime`
- `embedding: List<double>?` (vector for semantic search)

**Patterns:** Embeddable (agents search "find blockers", "find unanswered questions")

**Why:** Agent content, immutable. Separate from Invocations (which log tool execution). Agents query ObservationEvents to discover work.

### Narrative
Summarization of turn's work.

**Fields:**
- `id: String` (UUID)
- `roomId: String`
- `turnNumber: int`
- `generatedContent: String` (AI-generated summary)
- `editedContent: String?` (manager-edited version if changed)
- `editedAt: DateTime?` (when manager edited)
- `editedBy: String?` (who edited)
- `keyDecisions: List<String>` (extracted decisions)
- `unresolvedBlockers: List<String>` (ObservationEvent IDs of blockers)
- `nextSteps: List<String>` (what should happen next)
- `embedding: List<double>?` (for semantic search)

**Patterns:** Embeddable, Trainable — feedback on narrative quality trains NarrativeTool

**Why:** Summaries agent content for manager review. Manager can edit directly (training signal). Separate from Turn (Turn is timing, Narrative is semantic summary).

**Manager Edit as Invocation:** When manager edits narrative, logs `component: 'manager_edit_narrative'` with before/after content. Training signal for NarrativeTool.

### TaskAssignment
Work unit assigned to agent.

**Fields:**
- `id: String` (UUID)
- `roomId: String`
- `agentId: String` (assigned to)
- `description: String` (what to do)
- `priority: int` (1-5, 5=urgent)
- `status: String` ('pending', 'claimed', 'in_progress', 'completed')
- `claimedBy: String?` (which agent claimed it, if not assigned)
- `claimedAt: DateTime?`
- `completedAt: DateTime?`
- `createdAt: DateTime`

**Why:** Manager assigns work. Agents can claim tasks themselves (claim = start). All agents see all tasks (transparency). Logged as Invocations when claimed/completed (training signal).

### Invocation
(From Everything Stack) Record of component execution.

**Fields:**
- `id: String` (UUID)
- `userId: String` (which agent/human triggered it)
- `componentType: String` ('agent_orchestrator', 'publish_observation_tool', 'discovery_tool', 'narrative_tool', 'task_tool', 'manager_edit_narrative', 'manager_edit_task', etc.)
- `input: String` (what was requested)
- `output: String` (what was produced)
- `success: bool`
- `confidence: double`
- `metadata: Map<String, dynamic>` (component-specific: embedding model used, search results returned, etc.)
- `correlationId: String` (links invocation chain)
- `roomId: String` (scoped to room)
- `timestamp: DateTime`

**Patterns:** Trainable (feedback trains tool selection, agent behavior)

**Why:** Everything logged for learning. No distinction between "manager action" and "agent action"—all treated as invocations. System learns what works.

---

## Core Tools (Explicitly Invocable)

Tools are called by agents or manager via Coordinator/AgentOrchestrator and logged as Invocations.

### PublishObservationTool
Agents publish observations to room.

**Invocation:**
```
Input: { agentId, content, eventType, respondingToEventId?, confidence? }
Output: ObservationEvent created
Logged: component='publish_observation_tool', success=true
```

### DiscoveryTool
Agents search for work (queries ObservationEvents + Tasks).

**Invocation:**
```
Input: { agentId, query: "find blockers", semanticQuery: embedding }
Output: List<ObservationEvent>, List<TaskAssignment>
Logged: component='discovery_tool', success=true, resultCount=N
```

### NarrativeTool
Generates summary of turn's observations.

**Invocation:**
```
Input: { roomId, turnId }
Output: Narrative entity created (or updated if edited)
Logged: component='narrative_tool', success=true
```

If manager edits narrative afterward:
```
Input: { narrativeId, newContent }
Output: Narrative.editedContent updated
Logged: component='manager_edit_narrative', success=true
```

### TaskTool
CRUD for task assignments.

**Invocations:**
```
createTask(roomId, agentId, description, priority) → TaskAssignment
claimTask(taskId, agentId) → TaskAssignment with status='claimed'
updateTask(taskId, updates) → TaskAssignment
completeTask(taskId) → TaskAssignment with status='completed'
```

All logged as Invocations for learning.

### TurnManagementTool
Manages turn lifecycle.

**Invocations:**
```
startTurn(roomId) → Turn created, agents notified
endTurn(roomId) → Turn marked ended, triggers NarrativeTool
getRoomState(roomId) → Room + current agents + active tasks + recent narratives
```

---

## Core Services (Infrastructure)

### AgentOrchestrator
Orchestrates agent logic execution.

**Responsibilities:**
1. Trigger on turn start
2. Agent runs deterministic logic (conditional rules, not LLM)
3. Agent calls tools via ToolExecutor (same as humans use)
4. Invocations logged identically

**Does NOT:**
- Call LLM for reasoning (that's Coordinator)
- Ask NamespaceSelector (agents don't categorize tools)

### Coordinator (From Everything Stack)
Orchestrates LLM-based reasoning (humans + agents when LLM needed).

**Only used when:**
- NarrativeTool needs LLM to summarize observations
- Manager needs LLM to evaluate something
- Agent needs LLM to reason (optional, not primary agent path)

### ContextInjector
Aggregates context for agents running in room.

**Returns:**
- Agent's Role + Persona + PersonaAdaptation
- Room state (agents, recent narratives, blockers)
- Discovered ObservationEvents (from DiscoveryTool)
- Task assignments for this agent

---

## Turn Lifecycle

**Turn N: Active**
1. TurnManagementTool.startTurn(roomId) called
2. Agents run concurrently, publish ObservationEvents
3. AgentOrchestrator processes agent logic
4. DiscoveryTool queries ObservationEvents + Tasks
5. All agents see all new events (full transparency)
6. Everything logged as Invocations

**Turn N → N+1: Transition**
1. TurnManagementTool.endTurn(roomId) called (manager decides, or system heuristic: "10+ events, 5 min elapsed")
2. NarrativeTool generates Narrative from all ObservationEvents in turn
3. Narrative stored, linked to Turn.narrativeId
4. Manager reviews Narrative (can edit directly—logs as Invocation)
5. Manager can create TaskAssignments for turn N+1

**Turn N+1: Active**
1. TurnManagementTool.startTurn(roomId) returns updated context
2. ContextInjector includes:
   - Narrative from turn N
   - New TaskAssignments
   - All prior ObservationEvents (queryable)
   - Updated PersonaAdaptations
3. Agents resume work with full context

---

## Room Lifecycle

**Room Created:**
- Manager defines scope, adds agents (with roles + personas)
- TurnManagementTool.startTurn() begins turn 1
- Agents start work

**Room Active:**
- Agents collaborate across multiple turns
- Manager edits narratives, tasks, optionally swaps agent personas/roles
- System learns: PersonaAdaptation updates per turn feedback

**Room Completed:**
- Manager decides scope is resolved: "end room" or "mark complete"
- Room status → 'completed', completedAt timestamp
- Narratives + Invocations persist (historical record)
- Room can be archived (moved to read-only storage)

---

## Learning Loop

Everything is logged for continuous learning:

1. **Agent publishes** → Invocation logged (component='publish_observation_tool')
2. **Agent discovers** → Invocation logged (component='discovery_tool')
3. **NarrativeTool summarizes** → Invocation logged (component='narrative_tool')
4. **Manager edits narrative** → Invocation logged (component='manager_edit_narrative') — training signal
5. **Feedback collected** → PersonaAdaptation updated
6. **Next turn** → Agent uses learned adaptations

PersonaAdaptation.learnedThresholds and discoveryStrategy evolve per turn. No separate training pipeline—learning is continuous via Trainable.recordInvocation() and trainFromFeedback().

---

## Architecture Constraints

- **All entities extend BaseEntity** (from Everything Stack)
- **All repositories extend EntityRepository<T>** (generic CRUD + semantic search)
- **Entities are pure Dart** (no ORM decorators in domain)
- **Dual persistence:** ObjectBox (native), IndexedDB (web)
- **Sync:** Supabase (offline-first)
- **All platforms first-class:** iOS, Android, macOS, Windows, Linux, Web
- **Everything logged:** Invocations are atomic unit of learning

---

## Phase 1 Deliverables

- [ ] Domain entities: Room, Agent, Role, Persona, PersonaAdaptation, Turn, ObservationEvent, Narrative, TaskAssignment
- [ ] Repositories with dual persistence (ObjectBox native, IndexedDB web)
- [ ] AgentOrchestrator with deterministic logic
- [ ] Tools: PublishObservationTool, DiscoveryTool, NarrativeTool, TaskTool, TurnManagementTool
- [ ] E2E test: One complete turn
  - Manager creates room with 3 agents
  - Agents publish 6 ObservationEvents (mix of questions, blockers, solutions)
  - NarrativeTool generates Narrative
  - Manager edits Narrative (logs Invocation)
  - Turn ends, Turn 2 begins
  - Verify all Invocations logged, room state consistent
- [ ] Invocation logging throughout all paths (agent + manager actions)

---

## What's Inherited vs Created

**Inherited from Everything Stack:**
- Coordinator (LLM orchestration)
- Trainable + Embeddable patterns
- Event/Invocation/Turn/Feedback entities
- Persistence adapters (ObjectBox + IndexedDB)
- EmbeddingService (vector generation)
- ToolRegistry + ToolExecutor
- ContextInjector base
- SyncService (Supabase)

**Created for Agent Townhall:**
- AgentOrchestrator (agent execution logic)
- Room, Agent, Role, Persona, PersonaAdaptation, ObservationEvent, Narrative, TaskAssignment
- PublishObservationTool, DiscoveryTool, NarrativeTool, TaskTool, TurnManagementTool
- Manager control surface (edit narratives, tasks, agents, scope)

**Deferred:**
- Edge graph (defer until relationship queries are complex)
- Multi-device sync (future phase)
- Advanced scheduling (future phase)

---

## Why This Architecture Works

1. **Unified infrastructure** — Agents and manager use same tools, same logging, same feedback
2. **Semantic discovery** — Agents find work via ObservationEvent search, not explicit instructions
3. **Asynchronous coordination** — Narratives enable turn-based decision-making without constant back-and-forth
4. **Learning from real execution** — Every invocation logged, feedback trains adaptations continuously
5. **Manager control** — Scope-driven, manager orchestrates everything (no agent autonomy)
6. **Cross-platform** — Built on Everything Stack, works on all 6 platforms

---

**Last Updated:** January 2, 2026
**Status:** Phase 1 architecture locked, ready for implementation


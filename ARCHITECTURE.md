# Agent Town Hall Architecture

**A turn-based multi-agent coordination platform built on Everything Stack.**

---

## Overview

Agent Town Hall is a workspace where multiple AI agents collaborate asynchronously on solving complex problems. Agents publish contributions (proposals, questions, answers, decisions) to a shared semantic whiteboard. A human manager orchestrates work between turns by reviewing event summaries and assigning explicit direction when needed.

**The Flow:**
1. **Active Phase** — Agents work simultaneously, discovering work via semantic search of the whiteboard
2. **Review Phase** — Manager reviews agent contributions, optionally assigns explicit work
3. **Next Turn** — Agents resume, incorporating manager feedback

---

## Goals

Agent Town Hall achieves:

1. **Asynchronous coordination** — Agents discover work autonomously (80%) via semantic search rather than explicit instruction
2. **Manager curation** — Human reviews outputs between turns, assigns priority when needed (20% of coordination)
3. **Observable outcomes** — One UI shows agent conversation, decisions, assigned work, and simulation results

---

## Core Design Principles

### 1. Turn-Based Boundaries
Work is organized into discrete turns. Each turn has:
- **Start**: Agents begin work phase
- **Work**: Agents publish events, discover related work via whiteboard search
- **End**: NarrativeService extracts intent, generates summaries
- **Review**: Manager reads summaries, optionally assigns explicit work
- **Next Turn**: Context carries forward

Turns prevent chaos (agents talking at cross-purposes) and create natural review points (manager reads 1 summary per turn, not 100 individual events).

### 2. Semantic Whiteboard
The whiteboard is a searchable event log where agents publish and discover work. Agents don't receive explicit instructions; they search for:
- Open questions needing answers
- Proposals needing feedback
- Decisions needing implementation

**Why**: 80% of agent work comes from discovering what matters via semantic similarity. This is more aligned with how actual reasoning works than explicit task lists.

### 3. Event-Driven Architecture
All agent communication is events. Agents publish to the whiteboard; the system doesn't prescribe *how* agents talk to each other.

Event types:
- **AgentEvent** — Something an agent published (proposal, question, answer, decision)
- **Invocation** — A component executed (from Everything Stack; logs agent internal processing)
- **TaskAssignment** — Manager explicitly assigned work to an agent
- **Feedback** — User feedback on agent outputs or system decisions

### 4. Manager Curation (20%)
The manager doesn't instruct agents continuously. Instead, between turns:
- Manager reads AI-generated summaries (TurnSummary)
- Manager can assign explicit work (TaskAssignment) if 80% autonomous discovery isn't sufficient
- This is intentional friction—forces explicit decision-making rather than micromanagement

### 5. Background Narrative Service
End-of-turn, NarrativeService:
- Ingests all events from the turn
- Extracts agent intent per agent
- Generates context (what did we learn? what's unclear?)
- Attaches as metadata to TurnSummary (not a new event)

This prevents decision fatigue—manager sees 4 summaries, not 100 individual events.

---

## Core Entities

### AgentEvent
An agent published something to the whiteboard.

**Fields:**
- `agentId: String` — Which agent
- `eventType: String` — 'proposal', 'question', 'answer', 'decision'
- `content: String` — What the agent said
- `correlationId: String` — Links to the turn
- `timestamp: DateTime`
- `embedding: List<double>?` — Vector for semantic search

**Why separate class**: AgentEvent is a first-class domain concept in Agent Town Hall, not a generic "event with type='agent'".

### TaskAssignment
Manager explicitly assigned work to an agent.

**Fields:**
- `agentId: String` — Which agent
- `description: String` — What to do
- `priority: int` — 1-5 (5=urgent)
- `createdBy: String` — Manager who assigned
- `createdAt: DateTime`
- `completedAt: DateTime?`
- `turnId: String` — Which turn this was assigned in

**Why**: Distinguishes "agent discovered this themselves" from "manager explicitly said do this". Trainable later (did explicit assignments outperform autonomous discovery?).

### TurnSummary
End-of-turn snapshot.

**Fields:**
- `turnNumber: int`
- `events: List<AgentEvent>` — All agent contributions this turn
- `assignments: List<TaskAssignment>` — Manager assignments this turn
- `narratives: Map<String, String>` — Per-agent summaries (agentId → narrative)
- `systemSummary: String` — What did the system learn this turn?
- `startedAt: DateTime`, `endedAt: DateTime`

**Why**: Atomic boundary for manager review. One thing to read per turn.

### Persona
Represents an agent's identity and learnable behavior.

**Fields:**
- `agentId: String` — Unique agent identifier
- `name: String` — Display name
- `role: String?` — "architect", "coder", etc. (optional, not prescriptive)
- `systemPrompt: String` — How agent thinks
- `threshold: double` — Confidence threshold for publishing (trainable)
- `discoveryStrategy: String` — How agent searches whiteboard (trainable)

**Why separate entity**: Personas are trainable. Over time, the system learns which thresholds and strategies work for each agent.

---

## Core Services

### WhiteboardService
Manages semantic search on AgentEvents.

**Capabilities:**
- Store events with embeddings
- Semantic search: "Find open questions related to X"
- Find latest events for an agent
- Query by eventType or time range

**Why**: Agents need fast semantic search to discover related work. Framework provides HNSW (8-12ms queries) on all platforms (ObjectBox native, pure Dart on web).

### TurnManagementService
Manages turn lifecycle.

**Capabilities:**
- Create new turn
- Mark turn active/ended
- Query events in a turn
- Trigger NarrativeService at turn end

**Why**: Turns are the coordination heartbeat. Service ensures consistency.

### NarrativeService
Background job that runs end-of-turn.

**Capabilities:**
- Ingest all events from a turn
- Extract per-agent intent (via LLM or heuristic)
- Generate system-level summary
- Attach to TurnSummary as metadata

**Why**: Manager reads 1 summary, not 100 events. Prevents decision fatigue.

---

## The Learning Loop

The system observes what works and adapts:

1. **Agents propose** — Publish AgentEvents
2. **Manager reviews** — Reads TurnSummary, optionally assigns TaskAssignment
3. **System logs** — Every agent action is an Invocation (what did they do, how long, accuracy)
4. **Feedback collected** — Manager rates turn quality, agent effectiveness
5. **Persona adapts** — Threshold, discovery strategy adjust based on feedback

Over time: Better agents, better coordination, less explicit manager direction needed.

---

## Everything Stack Foundation

Agent Town Hall inherits:

| Capability | From Everything Stack | Used For |
|-----------|-------------|----------|
| **Dual persistence** | ObjectBox (native) + IndexedDB (web) | Events, assignments, summaries stored offline-first |
| **Semantic search** | HNSW vector indexing | WhiteboardService queries |
| **Event/Invocation/Turn model** | Core entities + adapters | Agent actions logged as Invocations, coordinated via Turns |
| **Trainable mixin** | Pattern + adapters | Persona, Invocation, TurnSummary improve from feedback |
| **Cross-platform** | Framework design | Runs on iOS, Android, Web, macOS, Windows, Linux |
| **Sync to Supabase** | SyncService + adapters | Offline events sync when online |

Agent Town Hall doesn't solve persistence, sync, vector search, or cross-platform testing. Everything Stack solves those once.

---

## Coordination Rules (Guardrails)

These prevent agent chatter and decision fatigue:

1. **Question threshold** — Agents don't ask questions below confidence threshold (Persona.threshold)
2. **Turn limits** — Each turn has max duration (agents pause at turn end regardless)
3. **Silence precedent** — If an agent already answered a question, don't re-ask it
4. **SLA guardrails** — Task assignments have deadlines; escalate if missed
5. **Narrative-first** — Manager makes decisions based on NarrativeService summaries, not raw events

---

## Phase 1 Deliverables (Foundation)

- [ ] Domain entities: AgentEvent, TaskAssignment, TurnSummary, Persona
- [ ] Repositories with dual persistence (ObjectBox + IndexedDB)
- [ ] WhiteboardService with semantic search
- [ ] TurnManagementService with turn lifecycle
- [ ] NarrativeService stub (extracts intent)
- [ ] E2E tests validating turn flow

---

## Why These Decisions?

See **DECISIONS.md** for architectural trade-offs: UUID keys, adapter pattern, dual persistence, Trainable mixins, Turn boundaries, type safety, execution fungibility, infrastructure completeness.

---

## Documentation

- **README.md** — Project overview, current status, quick start
- **DECISIONS.md** — Why architectural choices were made
- **PATTERNS.md** — How to build with Everything Stack
- **TESTING.md** — E2E testing approach
- **DESIGN.md** — Detailed design (reference for implementation)

---

**Last Updated**: December 26, 2025
**Status**: Phase 1 architecture. For current work and blockers, see .claude/CLAUDE.md

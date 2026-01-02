# Agent Town Hall

**Multi-agent coordination platform. One workspace. All agents. All outcomes.**

Agent Town Hall is where multiple AI agents collaborate on solving complex problems:
- **Shared workspace** — Agents publish proposals, questions, answers, decisions on a semantic whiteboard
- **Asynchronous coordination** — Agents discover work by meaning, not manual relay
- **Simulation execution** — Digital twin runs in the same workspace, everyone sees outcomes
- **Real-time monitoring** — One UI shows agent conversation + simulation state + results
- **Learning from feedback** — System improves agent proposals and persona thresholds over time

Built on Everything Stack — runs on all 6 platforms (iOS, Android, Web, macOS, Windows, Linux).

## Current Status

### 🔄 Phase 1: Foundation (IN PROGRESS)
- Entity model: AgentEvent, AgentState, SimulationContext, FarmerPersona, SimulationResult
- Repositories with dual persistence (ObjectBox native, IndexedDB web)
- WhiteboardService with semantic search (HNSW)
- MCP tools for agent communication
- CI/CD workflows (test on all platforms)

### ⏳ Phase 2: Coordination Workflow
- Proposal → approval → implementation flow
- SimulationService for digital twin execution
- Invocation logging throughout
- Workspace UI

### ⏳ Phase 3+: Learning & Integration
- Feedback collection and adaptation
- Cross-platform testing
- Production deployment

---

## Quick Start

```bash
# 1. Clone
git clone <repo>

# 2. Create environment
cp .env.example .env
# Edit .env with your Groq API key, etc.

# 3. Run on any platform
flutter run -d android    # Android emulator
flutter run -d ios        # iOS simulator
flutter run -d chrome     # Web browser
flutter run -d macos      # macOS desktop
flutter run -d windows    # Windows desktop
flutter run -d linux      # Linux desktop

# 4. Run tests
flutter test              # All tests (uses mocks)
flutter test integration_test/ -d chrome  # E2E on web
```

---

## How It Works

### For AI Models
When a small model builds an app on Everything Stack:
1. Define entities (lib/domain/)
2. Write E2E tests (integration_test/)
3. Implement features until tests pass
4. Never choose databases, design sync, or solve platform problems
5. Application works on all platforms

### For the System
Every execution creates an Invocation:
- Component that ran (service name)
- Input/output (what it did)
- Execution context (local vs remote)
- User feedback (what they thought)
- Next time: AdaptationState guides decisions

See ARCHITECTURE.md for complete entity model.

---

## Stack

| Layer | Choice |
|-------|--------|
| Language | Dart |
| Framework | Flutter (mobile, web, desktop) |
| Native DB | ObjectBox |
| Web DB | IndexedDB |
| Sync | Supabase |
| Vector Search | HNSW (semantic) |
| AI Services | Groq (LLM), Deepgram (speech), Jina (embeddings) |
| Testing | Flutter (unit/integration/E2E) |
| CI | GitHub Actions |

---

## Documentation

**Project Documents:**
- **VISION.md** - Why CSA Golden Twin exists, success criteria, user personas
- **DESIGN.md** - Multi-agent coordination architecture, entity model, workflow (READY FOR REVIEW)
- **README.md** (you are here) - Current status, quick start

**Everything Stack Foundation:**
- **ARCHITECTURE.md** - Core entity model (Event, Invocation, Turn, Feedback, AdaptationState)
- **PATTERNS.md** - How to build: entities, services, testing, Trainable/Embeddable patterns
- **TESTING.md** - E2E testing approach, cross-platform testing
- **DECISIONS.md** - Why architectural choices were made
- **.claude/CLAUDE.md** - Project initialization, build commands, permissions

---

## Testing

Test your code through real E2E execution. No mocks. What you test is what ships.

E2E tests generate real Invocation logs that feed the learning system. Mocks generate fake signals.

**All Platforms:**
```bash
flutter test integration_test/ -d android   # Android emulator
flutter test integration_test/ -d ios       # iOS simulator
flutter test integration_test/ -d chrome    # Web browser
flutter test integration_test/ -d macos     # macOS desktop
flutter test integration_test/ -d windows   # Windows desktop
flutter test integration_test/ -d linux     # Linux desktop
```

See TESTING.md for complete E2E testing patterns.

---

## Core Philosophy

**Infrastructure completeness over simplicity.** Dual persistence, multi-platform abstractions, vector search, offline sync - complexity is paid ONCE in this template. Every application built on it inherits that infrastructure.

**All platforms are first-class.** Android, iOS, macOS, Windows, Linux, Web. Not native-first with web later. Complete or don't build it.

**Domain logic only.** When a small model builds an app, it defines entities and writes business logic. It never chooses databases, designs sync, or solves platform problems. Those are already solved.

---

## Why This Matters

Traditional architectures are static. You design once. It stays that way.

Everything Stack makes architecture a first-class learnable thing. The system observes its own performance, gets feedback, reshapes itself. Not randomly. Empirically.

The power isn't in any single layer. It's in the loop:
**execute → log → learn → adapt → execute (better next time)**

---

## Recent Changes

**Phase 6: Trainable Components** - Migrating from interface-based to mixin-based pattern
- Services now support pluggable implementations (local vs remote)
- Feedback collection automatic
- Next: Train plugin selection based on performance

**Consolidated Documentation** - Reduced from 41 files to 6 core docs
- Removed 4-layer testing pyramid (E2E only)
- Made execution fungibility explicit
- Added learning architecture overview

---

## Getting Started

1. Read ARCHITECTURE.md (understand how it works)
2. Read PATTERNS.md (learn how to build with it)
3. Read TESTING.md (understand E2E approach)
4. Run a test: `flutter test integration_test/ -d chrome`
5. Clone this as a new project: `git clone <repo> my-app`
6. Replace this README with project-specific content
7. Delete lib/example/ and test/scenarios/example_scenarios.dart
8. Add your entities to lib/domain/
9. Add your E2E tests to integration_test/
10. Implement until tests pass

See .claude/CLAUDE.md for project initialization checklist.

---

## License

MIT - Use as template for your own applications.

---

## Questions?

See ARCHITECTURE.md for how execution fungibility works.
See PATTERNS.md for service and entity patterns.
See TESTING.md for testing approach.
See .claude/CLAUDE.md for initialization and build commands.

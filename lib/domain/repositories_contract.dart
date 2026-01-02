/// Phase 1 Repository Contracts
/// Define all repository interfaces needed for Phase 1 implementation

import 'package:agent_town_hall/core/entity_repository.dart';
import 'observation_event_type.dart';

/// Room repository - manage collaboration scopes
abstract class RoomRepository extends EntityRepository<Room> {
  /// Find all active rooms
  Future<List<Room>> findActive();

  /// Find by manager (user who created it)
  Future<List<Room>> findByManager(String managerId);

  /// Find by status
  Future<List<Room>> findByStatus(String status);
}

/// Agent repository - manage agent instances
abstract class AgentRepository extends EntityRepository<Agent> {
  /// Find all agents in a room
  Future<List<Agent>> findByRoom(String roomId);

  /// Find agent by role
  Future<List<Agent>> findByRole(String roleId);

  /// Find agent by persona
  Future<List<Agent>> findByPersona(String personaId);
}

/// ObservationEvent repository - agent-published content with semantic search
abstract class ObservationEventRepository extends EntityRepository<ObservationEvent> {
  /// Find all events in a room during a turn
  Future<List<ObservationEvent>> findByRoomAndTurn(String roomId, int turnNumber);

  /// Find all events by agent
  Future<List<ObservationEvent>> findByAgent(String agentId);

  /// Find by event type
  Future<List<ObservationEvent>> findByType(ObservationEventType type);

  /// Find blocker events in room
  Future<List<ObservationEvent>> findBlockers(String roomId);

  /// Semantic search by embedding similarity
  /// Returns top K results with score > threshold
  Future<List<ObservationEvent>> semanticSearch(
    String roomId,
    String query,
    int topK = 5,
    double scoreThreshold = 0.6,
  );

  /// Find events replying to a specific event (threading)
  Future<List<ObservationEvent>> findReplies(String eventId);

  /// Update embedding for event (called by EmbeddingService)
  Future<void> updateEmbedding(String eventId, List<double> embedding);
}

/// Turn repository - turn boundaries and metadata
abstract class TurnRepository extends EntityRepository<Turn> {
  /// Find current active turn in room
  Future<Turn?> findActiveInRoom(String roomId);

  /// Find all turns in a room
  Future<List<Turn>> findByRoom(String roomId);

  /// Find by turn number
  Future<Turn?> findByRoomAndTurnNumber(String roomId, int turnNumber);
}

/// Narrative repository - AI-generated summaries (editable by manager)
abstract class NarrativeRepository extends EntityRepository<Narrative> {
  /// Find by turn
  Future<Narrative?> findByTurn(String roomId, int turnNumber);

  /// Find all narratives in room
  Future<List<Narrative>> findByRoom(String roomId);

  /// Semantic search across narratives
  Future<List<Narrative>> semanticSearch(
    String roomId,
    String query,
    int topK = 5,
  );
}

/// TaskAssignment repository - work units assigned to agents
abstract class TaskAssignmentRepository extends EntityRepository<TaskAssignment> {
  /// Find all tasks in a room
  Future<List<TaskAssignment>> findByRoom(String roomId);

  /// Find tasks assigned to agent
  Future<List<TaskAssignment>> findByAgent(String agentId);

  /// Find by status
  Future<List<TaskAssignment>> findByStatus(String status);

  /// Find pending tasks
  Future<List<TaskAssignment>> findPending(String roomId);

  /// Find completed tasks
  Future<List<TaskAssignment>> findCompleted(String roomId);
}

/// Role repository - shared archetypes (immutable)
abstract class RoleRepository extends EntityRepository<Role> {
  /// Find by name
  Future<Role?> findByName(String name);

  /// Find all roles
  Future<List<Role>> findAll();
}

/// Persona repository - shared styles (dynamic, swappable)
abstract class PersonaRepository extends EntityRepository<Persona> {
  /// Find by name
  Future<Persona?> findByName(String name);

  /// Find all personas
  Future<List<Persona>> findAll();
}

/// PersonaAdaptation repository - learned behavior per (agent, persona) tuple
abstract class PersonaAdaptationRepository extends EntityRepository<PersonaAdaptation> {
  /// Find adaptation for specific agent+persona in room
  Future<PersonaAdaptation?> findByAgentAndPersona(
    String agentId,
    String personaId,
    String roomId,
  );

  /// Find all adaptations for an agent
  Future<List<PersonaAdaptation>> findByAgent(String agentId);

  /// Find all adaptations in a room
  Future<List<PersonaAdaptation>> findByRoom(String roomId);

  /// Update learned thresholds based on feedback
  Future<void> updateLearning(
    String adaptationId,
    Map<String, double> learnedThresholds,
  );
}

// ============================================================================
// Placeholder entity classes (coder will implement full entities)
// ============================================================================

/// Placeholder - will be implemented fully
class Room {
  String id;
  String name;
  String description;
  List<String> agentIds;
  String status; // 'active', 'completed', 'archived'
  DateTime createdAt;
  DateTime? completedAt;

  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.agentIds,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });
}

/// Placeholder - will be implemented fully
class Agent {
  String id;
  String roomId;
  String roleId;
  String personaId;
  String personaAdaptationId;
  DateTime createdAt;

  Agent({
    required this.id,
    required this.roomId,
    required this.roleId,
    required this.personaId,
    required this.personaAdaptationId,
    required this.createdAt,
  });
}

/// Placeholder - will be implemented fully
class ObservationEvent {
  String id;
  String agentId;
  String roomId;
  int turnNumber;
  ObservationEventType eventType;
  String content;
  String? respondingToEventId;
  double? confidence;
  List<double>? embedding;
  DateTime timestamp;

  ObservationEvent({
    required this.id,
    required this.agentId,
    required this.roomId,
    required this.turnNumber,
    required this.eventType,
    required this.content,
    this.respondingToEventId,
    this.confidence,
    this.embedding,
    required this.timestamp,
  });
}

/// Placeholder - will be implemented fully
class Turn {
  String id;
  String roomId;
  int turnNumber;
  DateTime startedAt;
  DateTime? endedAt;
  String? narrativeId;
  int eventCount;
  Map<String, dynamic> agentStates;

  Turn({
    required this.id,
    required this.roomId,
    required this.turnNumber,
    required this.startedAt,
    this.endedAt,
    this.narrativeId,
    required this.eventCount,
    required this.agentStates,
  });
}

/// Placeholder - will be implemented fully
class Narrative {
  String id;
  String roomId;
  int turnNumber;
  String generatedContent;
  String? editedContent;
  DateTime? editedAt;
  String? editedBy;
  List<String> keyDecisions;
  List<String> unresolvedBlockers;
  List<String> nextSteps;
  List<double>? embedding;

  Narrative({
    required this.id,
    required this.roomId,
    required this.turnNumber,
    required this.generatedContent,
    this.editedContent,
    this.editedAt,
    this.editedBy,
    required this.keyDecisions,
    required this.unresolvedBlockers,
    required this.nextSteps,
    this.embedding,
  });
}

/// Placeholder - will be implemented fully
class TaskAssignment {
  String id;
  String roomId;
  String agentId;
  String description;
  int priority;
  String status;
  String? claimedBy;
  DateTime? claimedAt;
  DateTime? completedAt;
  DateTime createdAt;

  TaskAssignment({
    required this.id,
    required this.roomId,
    required this.agentId,
    required this.description,
    required this.priority,
    required this.status,
    this.claimedBy,
    this.claimedAt,
    this.completedAt,
    required this.createdAt,
  });
}

/// Placeholder - will be implemented fully
class Role {
  String id;
  String name;
  String systemPrompt;
  String description;
  DateTime createdAt;

  Role({
    required this.id,
    required this.name,
    required this.systemPrompt,
    required this.description,
    required this.createdAt,
  });
}

/// Placeholder - will be implemented fully
class Persona {
  String id;
  String name;
  String description;
  DateTime createdAt;

  Persona({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });
}

/// Placeholder - will be implemented fully
class PersonaAdaptation {
  String id;
  String agentId;
  String personaId;
  String roomId;
  Map<String, double> learnedThresholds;
  Map<String, int> observationCounts;
  int version;

  PersonaAdaptation({
    required this.id,
    required this.agentId,
    required this.personaId,
    required this.roomId,
    required this.learnedThresholds,
    required this.observationCounts,
    required this.version,
  });
}

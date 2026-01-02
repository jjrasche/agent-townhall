/// Tool invocation contracts (Phase 1)
/// These define exact payloads for all tools mentioned in ARCHITECTURE.md

import 'package:json_annotation/json_annotation.dart';
import 'observation_event_type.dart';

part 'tool_contracts.g.dart';

// ============================================================================
// PublishObservationTool Contract
// ============================================================================

/// Input to PublishObservationTool
/// Agent calls this to publish an observation to the room
@JsonSerializable()
class PublishObservationInput {
  /// Which agent is publishing
  final String agentId;

  /// Human-readable content (1-5000 chars)
  final String content;

  /// Type of observation (must be valid enum)
  final ObservationEventType eventType;

  /// If replying to another event (optional)
  final String? respondingToEventId;

  /// Agent's confidence in this observation (0.0-1.0, optional)
  final double? confidence;

  PublishObservationInput({
    required this.agentId,
    required this.content,
    required this.eventType,
    this.respondingToEventId,
    this.confidence,
  });

  factory PublishObservationInput.fromJson(Map<String, dynamic> json) =>
      _$PublishObservationInputFromJson(json);

  Map<String, dynamic> toJson() => _$PublishObservationInputToJson(this);
}

/// Output from PublishObservationTool
@JsonSerializable()
class PublishObservationOutput {
  /// The created ObservationEvent ID
  final String eventId;

  /// Timestamp of creation
  final DateTime timestamp;

  /// Turn number this was published in
  final int turnNumber;

  PublishObservationOutput({
    required this.eventId,
    required this.timestamp,
    required this.turnNumber,
  });

  factory PublishObservationOutput.fromJson(Map<String, dynamic> json) =>
      _$PublishObservationOutputFromJson(json);

  Map<String, dynamic> toJson() => _$PublishObservationOutputToJson(this);
}

// ============================================================================
// DiscoveryTool Contract
// ============================================================================

/// Input to DiscoveryTool
/// Agent searches for work: blockers, questions, tasks, etc.
@JsonSerializable()
class DiscoveryInput {
  /// Which agent is searching
  final String agentId;

  /// Query text: "find blockers", "find unanswered questions", etc.
  final String query;

  /// How many results to return (default: 5)
  final int topK;

  /// Minimum relevance score (0.0-1.0, default: 0.6)
  final double scoreThreshold;

  DiscoveryInput({
    required this.agentId,
    required this.query,
    this.topK = 5,
    this.scoreThreshold = 0.6,
  });

  factory DiscoveryInput.fromJson(Map<String, dynamic> json) =>
      _$DiscoveryInputFromJson(json);

  Map<String, dynamic> toJson() => _$DiscoveryInputToJson(this);
}

/// Result item from semantic search
@JsonSerializable()
class DiscoveryResult {
  /// Type: 'observation_event' or 'task'
  final String resultType;

  /// ID of the result
  final String resultId;

  /// Content or description
  final String content;

  /// Relevance score (0.0-1.0)
  final double score;

  DiscoveryResult({
    required this.resultType,
    required this.resultId,
    required this.content,
    required this.score,
  });

  factory DiscoveryResult.fromJson(Map<String, dynamic> json) =>
      _$DiscoveryResultFromJson(json);

  Map<String, dynamic> toJson() => _$DiscoveryResultToJson(this);
}

/// Output from DiscoveryTool
@JsonSerializable()
class DiscoveryOutput {
  /// Query that was searched
  final String query;

  /// Results (up to topK)
  final List<DiscoveryResult> results;

  /// Total results found
  final int totalCount;

  DiscoveryOutput({
    required this.query,
    required this.results,
    required this.totalCount,
  });

  factory DiscoveryOutput.fromJson(Map<String, dynamic> json) =>
      _$DiscoveryOutputFromJson(json);

  Map<String, dynamic> toJson() => _$DiscoveryOutputToJson(this);
}

// ============================================================================
// NarrativeTool Contract
// ============================================================================

/// Input to NarrativeTool
/// Generates narrative summary of a turn's observations
@JsonSerializable()
class NarrativeInput {
  /// Which room
  final String roomId;

  /// Which turn (narrative covers all events in this turn)
  final int turnNumber;

  /// Optional: max tokens to generate (default: 1000)
  final int? maxTokens;

  NarrativeInput({
    required this.roomId,
    required this.turnNumber,
    this.maxTokens,
  });

  factory NarrativeInput.fromJson(Map<String, dynamic> json) =>
      _$NarrativeInputFromJson(json);

  Map<String, dynamic> toJson() => _$NarrativeInputToJson(this);
}

/// Output from NarrativeTool
@JsonSerializable()
class NarrativeOutput {
  /// AI-generated summary
  final String generatedContent;

  /// Extracted key decisions
  final List<String> keyDecisions;

  /// Unresolved blockers (event IDs)
  final List<String> unresolvedBlockers;

  /// Recommended next steps
  final List<String> nextSteps;

  /// Number of events summarized
  final int eventCount;

  NarrativeOutput({
    required this.generatedContent,
    required this.keyDecisions,
    required this.unresolvedBlockers,
    required this.nextSteps,
    required this.eventCount,
  });

  factory NarrativeOutput.fromJson(Map<String, dynamic> json) =>
      _$NarrativeOutputFromJson(json);

  Map<String, dynamic> toJson() => _$NarrativeOutputToJson(this);
}

// ============================================================================
// TaskTool Contract
// ============================================================================

/// Task assignment status
enum TaskStatus {
  pending,     // Created, not yet claimed
  claimed,     // Agent claimed, in progress
  completed,   // Agent completed
  cancelled    // Cancelled by manager
}

/// Input to TaskTool - create/update/complete operations
@JsonSerializable()
class TaskToolInput {
  /// Operation: 'create', 'claim', 'complete', 'cancel'
  final String operation;

  /// Task ID (required for claim/complete/cancel)
  final String? taskId;

  /// Room ID (required for create)
  final String? roomId;

  /// Description (required for create)
  final String? description;

  /// Priority 1-5 (required for create, 5=urgent)
  final int? priority;

  /// Agent claiming/completing (required for claim/complete)
  final String? agentId;

  TaskToolInput({
    required this.operation,
    this.taskId,
    this.roomId,
    this.description,
    this.priority,
    this.agentId,
  });

  factory TaskToolInput.fromJson(Map<String, dynamic> json) =>
      _$TaskToolInputFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToolInputToJson(this);
}

/// Output from TaskTool
@JsonSerializable()
class TaskToolOutput {
  /// Task ID
  final String taskId;

  /// Current status
  final String status;

  /// When created/updated
  final DateTime timestamp;

  TaskToolOutput({
    required this.taskId,
    required this.status,
    required this.timestamp,
  });

  factory TaskToolOutput.fromJson(Map<String, dynamic> json) =>
      _$TaskToolOutputFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToolOutputToJson(this);
}

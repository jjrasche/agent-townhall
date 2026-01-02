import 'package:json_annotation/json_annotation.dart';
import 'package:agent_town_hall/core/base_entity.dart';
import 'package:agent_town_hall/patterns/embeddable.dart';
import 'observation_event_type.dart';

part 'observation_event.g.dart';

/// Agent-published observation in a room.
/// Immutable. Logged for semantic search and learning.
@JsonSerializable()
class ObservationEvent extends BaseEntity with Embeddable {
  /// Which agent published this
  final String agentId;

  /// Which room this belongs to
  final String roomId;

  /// Which turn this was published in
  final int turnNumber;

  /// Type of observation (enumerated)
  final ObservationEventType eventType;

  /// Human-readable content
  final String content;

  /// Reference to parent event (for threading)
  final String? respondingToEventId;

  /// Agent's confidence (0.0-1.0)
  final double? confidence;

  /// Vector embedding (auto-generated)
  final List<double>? embedding;

  /// When published
  final DateTime timestamp;

  @override
  List<double>? get embeddingVector => embedding;

  @override
  String get embeddingText => content;

  ObservationEvent({
    required String id,
    required this.agentId,
    required this.roomId,
    required this.turnNumber,
    required this.eventType,
    required this.content,
    this.respondingToEventId,
    this.confidence,
    this.embedding,
    required this.timestamp,
  }) : super(id: id);

  factory ObservationEvent.fromJson(Map<String, dynamic> json) =>
      _$ObservationEventFromJson(json);

  Map<String, dynamic> toJson() => _$ObservationEventToJson(this);
}

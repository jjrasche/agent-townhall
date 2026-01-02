/// ObservationEventType enum - all event types agents can publish
enum ObservationEventType {
  question,
  blocker,
  solution,
  agreement,
  disagreement,
  observation,
  decision,
  analysis,
  concern,
  clarification
}

extension ObservationEventTypeString on ObservationEventType {
  String toShortString() {
    return toString().split('.').last;
  }

  static ObservationEventType fromString(String value) {
    return ObservationEventType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => throw ArgumentError('Invalid event type: $value'),
    );
  }
}

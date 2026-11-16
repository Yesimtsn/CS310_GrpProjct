/// Reasons offered in the "Report event" bottom sheet.
enum ReportReason {
  spam('Spam'),
  inappropriate('Inappropriate content'),
  fake('Fake event'),
  other('Other');

  final String label;
  const ReportReason(this.label);
}

class EventReport {
  final String eventId;
  final String reporterId;
  final ReportReason reason;
  final DateTime createdAt;

  const EventReport({
    required this.eventId,
    required this.reporterId,
    required this.reason,
    required this.createdAt,
  });
}

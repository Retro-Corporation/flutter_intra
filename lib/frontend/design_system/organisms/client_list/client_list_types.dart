import '../../design_system.dart';

/// Data for a card in the "Current clients" section.
class CurrentClientData {
  final String clientId;
  final String clientName;
  final String lastSessionText;
  final double score;
  final ReviewStatus status;

  const CurrentClientData({
    required this.clientId,
    required this.clientName,
    required this.lastSessionText,
    required this.score,
    required this.status,
  });
}

/// Data for a card in the "All clients" section.
/// [AllClientCardState] is NOT included — the organism derives it from cross-list logic.
class AllClientData {
  final String clientId;
  final String clientName;
  final String email;

  const AllClientData({
    required this.clientId,
    required this.clientName,
    required this.email,
  });
}

/// Reported upward when the user taps the add/remove zone on an [AllClientCard].
class AllClientActionEvent {
  final String clientId;
  final AllClientCardState action; // only add or remove — never rosterFull

  const AllClientActionEvent({
    required this.clientId,
    required this.action,
  });
}

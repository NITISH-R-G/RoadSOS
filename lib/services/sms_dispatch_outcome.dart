/// Honest outcome of attempting emergency SMS (no fake "help is coming" without proof).
class SmsDispatchOutcome {
  /// True when a server relay returned 2xx or Android reports direct send API success.
  final bool pathConfirmedSent;

  /// User-visible status line for dispatch UI.
  final String detail;

  const SmsDispatchOutcome({
    required this.pathConfirmedSent,
    required this.detail,
  });
}

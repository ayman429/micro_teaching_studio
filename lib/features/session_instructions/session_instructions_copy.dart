class SessionInstructionsCopy {
  const SessionInstructionsCopy({
    required this.objectivesLead,
    required this.objectivePoints,
    required this.howToApply,
  });

  final String objectivesLead;
  final List<String> objectivePoints;
  final String howToApply;
}

SessionInstructionsCopy parseSessionInstructions(String raw) {
  final text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
  final howToApply = RegExp(
    'how to apply\\s*[:.]?',
    caseSensitive: false,
  ).firstMatch(text);

  var objectives = text;
  var application = '';
  if (howToApply != null) {
    objectives = text.substring(0, howToApply.start).trim();
    application = text.substring(howToApply.end).trim();
  }

  objectives = objectives
      .replaceFirst(
        RegExp('^objectives?\\s*[:.]?\\s*', caseSensitive: false),
        '',
      )
      .trim();

  final lead = <String>[];
  final points = <String>[];
  for (final line in objectives.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    final bullet = RegExp(
      r'^[-•·∙●▪‣*\u00B7\u2022\uF0B7]\s*',
    ).firstMatch(trimmed);
    if (bullet != null) {
      final point = trimmed.substring(bullet.end).trim();
      if (point.isNotEmpty) points.add(point);
      continue;
    }
    if (points.isEmpty) {
      lead.add(trimmed);
    } else {
      points[points.length - 1] = '${points.last} $trimmed';
    }
  }

  return SessionInstructionsCopy(
    objectivesLead: lead.join(' '),
    objectivePoints: points,
    howToApply: application,
  );
}

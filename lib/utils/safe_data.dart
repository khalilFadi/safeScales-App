import 'dart:convert';

/// Coerce JSON/Supabase values that are often typed differently on iOS
/// (int vs double vs string) without throwing during quiz completion.
int asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) {
    if (value.isNaN || value.isInfinite) return fallback;
    return value.round();
  }
  if (value is num) return value.round();
  if (value is String) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null) return parsed;
    final asDouble = double.tryParse(value.trim());
    if (asDouble != null && asDouble.isFinite) return asDouble.round();
  }
  return fallback;
}

String asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

DateTime parseDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  if (value is int) {
    if (value > 100000000000) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }
  return DateTime.now();
}

/// Parse quiz `question_responses` from List, JSON string, or mixed number types.
List<List<int>> parseQuestionResponses(dynamic answers) {
  dynamic decoded = answers;
  if (decoded == null) return [];

  if (decoded is String) {
    final trimmed = decoded.trim();
    if (trimmed.isEmpty) return [];
    try {
      decoded = jsonDecode(trimmed);
    } catch (_) {
      return [];
    }
  }

  if (decoded is! List) return [];

  final responses = <List<int>>[];
  for (final answer in decoded) {
    if (answer is List) {
      responses.add(
        answer
            .map((item) => asInt(item, fallback: -1))
            .where((i) => i >= 0)
            .toList(),
      );
    } else if (answer is num) {
      responses.add([asInt(answer)]);
    } else {
      responses.add([]);
    }
  }
  return responses;
}

String optionTextAt(List<String> options, int index) {
  if (index < 0 || index >= options.length) {
    return 'Unknown option';
  }
  return options[index];
}

String joinSelectedOptions(List<String> options, List<int> indices) {
  if (indices.isEmpty) return 'Not answered';
  return indices.map((index) => optionTextAt(options, index)).join(', ');
}

/// Normalize user-dragon records that may be a legacy phases list or a map.
Map<String, dynamic> normalizeUserDragonRecord(dynamic record) {
  if (record is Map) {
    final map = Map<String, dynamic>.from(record);
    map['phases'] = stringList(map['phases']);
    final name = asString(map['name'], fallback: 'no name');
    map['name'] = name.isEmpty ? 'no name' : name;
    return map;
  }

  if (record is List) {
    return {
      'name': 'no name',
      'phases': stringList(record),
    };
  }

  return {
    'name': 'no name',
    'phases': ['egg'],
  };
}

List<String> stringList(dynamic value) {
  if (value is! List) return ['egg'];
  final phases =
      value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  return phases.isEmpty ? ['egg'] : phases;
}

double safeScorePercent(int correctAnswers, int totalQuestions) {
  if (totalQuestions <= 0) return 0;
  return ((correctAnswers / totalQuestions) * 100).round().toDouble();
}

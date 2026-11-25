/// Pass number formats (stored without spaces, printed as "S 921"):
///   Student / Parent-guardian pass   S + 3 digits   S921
///   Faculty / Staff pass             E + 3 digits   E456
///   Yellow pass (no parking)         3 digits       789
class PassNumberValidator {
  PassNumberValidator._();

  /// A letter S or E, then 3 digits (a space, dash or dot may sit between).
  static final RegExp _lettered =
      RegExp(r'(?<![A-Za-z0-9])([SsEe])[\s\-.:]*(\d{3})(?!\d)');

  /// Exactly 3 digits on their own.
  static final RegExp _bare = RegExp(r'(?<!\d)\d{3}(?!\d)');

  static final RegExp _format = RegExp(r'^(?:[SE]\d{3}|\d{3})$');

  /// "s 921", " S921 " -> "S921". Returns null when the format is wrong.
  static String? normalize(String input) {
    final cleaned = input.replaceAll(RegExp(r'[\s\-.:]'), '').toUpperCase();
    return _format.hasMatch(cleaned) ? cleaned : null;
  }

  static bool isValid(String value) => normalize(value) != null;

  /// "S921" -> "S 921" (how it is printed on the pass).
  static String display(String passNumber) {
    if (passNumber.length == 4 && RegExp(r'^[SE]').hasMatch(passNumber)) {
      return '${passNumber[0]} ${passNumber.substring(1)}';
    }
    return passNumber;
  }

  /// Every pass number found in the OCR text, best guesses first.
  /// 1. Letter + 3 digits ("S 921", "E456")
  /// 2. A first digit 5 read instead of the letter S ("5921" -> "S921")
  /// 3. Three digits on their own (Yellow pass), ignoring the digits that
  ///    already belong to a lettered number.
  static List<String> extractCandidates(String ocrText) {
    final seen = <String>{};
    final result = <String>[];

    void add(String value) {
      if (seen.add(value)) result.add(value);
    }

    for (final m in _lettered.allMatches(ocrText)) {
      add('${m.group(1)!.toUpperCase()}${m.group(2)!}');
    }

    for (final m in RegExp(r'(?<!\d)5(\d{3})(?!\d)').allMatches(ocrText)) {
      add('S${m.group(1)!}');
    }

    final withoutLettered = ocrText.replaceAll(_lettered, ' ');
    for (final m in _bare.allMatches(withoutLettered)) {
      add(m.group(0)!);
    }

    return result;
  }
}
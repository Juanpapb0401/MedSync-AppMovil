class LinkingCodeGenerator {
  static String generate(String profileId) {
    final digits = profileId.replaceAll(RegExp(r'\D'), '');
    final codeDigits = digits.isEmpty
        ? '0000'
        : digits.length >= 4
            ? digits.substring(0, 4)
            : digits.padLeft(4, '0');
    return 'MED-$codeDigits';
  }

  static String resolve(String profileId, String? storedCode) {
    final cleanedStoredCode = storedCode?.trim();
    if (cleanedStoredCode != null && cleanedStoredCode.isNotEmpty) {
      return cleanedStoredCode;
    }
    return generate(profileId);
  }
}
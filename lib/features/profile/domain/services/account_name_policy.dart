abstract final class AccountNamePolicy {
  static String normalizeForDisplay(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String normalizeForComparison(String value) {
    return normalizeForDisplay(value).toLowerCase();
  }

  static bool meaningfullyDiffers(String currentName, String proposedName) {
    return normalizeForComparison(currentName) !=
        normalizeForComparison(proposedName);
  }
}

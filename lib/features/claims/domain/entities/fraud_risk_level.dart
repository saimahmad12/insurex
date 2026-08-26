enum FraudRiskLevel { pending, low, medium, high }

double clampFraudRiskScore(num score) {
  return score.clamp(0, 100).toDouble();
}

FraudRiskLevel fraudRiskLevelForScore(num? score) {
  if (score == null) {
    return FraudRiskLevel.pending;
  }

  final double clampedScore = clampFraudRiskScore(score);
  if (clampedScore <= 30) {
    return FraudRiskLevel.low;
  }
  if (clampedScore <= 60) {
    return FraudRiskLevel.medium;
  }
  return FraudRiskLevel.high;
}

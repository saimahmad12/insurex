import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/claims/domain/entities/fraud_risk_level.dart';

void main() {
  test('maps fraud-risk boundaries', () {
    expect(fraudRiskLevelForScore(0), FraudRiskLevel.low);
    expect(fraudRiskLevelForScore(30), FraudRiskLevel.low);
    expect(fraudRiskLevelForScore(31), FraudRiskLevel.medium);
    expect(fraudRiskLevelForScore(60), FraudRiskLevel.medium);
    expect(fraudRiskLevelForScore(61), FraudRiskLevel.high);
    expect(fraudRiskLevelForScore(100), FraudRiskLevel.high);
    expect(fraudRiskLevelForScore(null), FraudRiskLevel.pending);
  });

  test('clamps scores below zero and above one hundred', () {
    expect(clampFraudRiskScore(-12), 0);
    expect(clampFraudRiskScore(145), 100);
  });
}

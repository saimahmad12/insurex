import '../../domain/entities/insurance_policy.dart';
import '../../domain/repositories/policies_repository.dart';

class MockPoliciesRepository implements PoliciesRepository {
  MockPoliciesRepository({
    this.delay = const Duration(milliseconds: 700),
    List<InsurancePolicy>? initialPolicies,
  }) : _policies = initialPolicies ?? _defaultPolicies;

  final Duration delay;
  final List<InsurancePolicy> _policies;
  int getPoliciesCallCount = 0;

  static final List<InsurancePolicy> _defaultPolicies = <InsurancePolicy>[
    InsurancePolicy(
      id: '1',
      policyNumber: 'INS-2026-001',
      title: 'Vehicle Insurance',
      type: PolicyType.vehicle,
      validTill: DateTime(2027, 8, 14),
      premium: 25000,
      status: PolicyStatus.active,
    ),
    InsurancePolicy(
      id: '2',
      policyNumber: 'INS-2026-002',
      title: 'Health Insurance',
      type: PolicyType.health,
      validTill: DateTime(2026, 12, 20),
      premium: 18000,
      status: PolicyStatus.active,
    ),
    InsurancePolicy(
      id: '3',
      policyNumber: 'INS-2026-003',
      title: 'Travel Insurance',
      type: PolicyType.travel,
      validTill: DateTime(2027, 3, 10),
      premium: 12000,
      status: PolicyStatus.active,
    ),
    InsurancePolicy(
      id: '4',
      policyNumber: 'INS-2025-004',
      title: 'Travel Insurance',
      type: PolicyType.travel,
      validTill: DateTime(2025, 12, 12),
      premium: 10000,
      status: PolicyStatus.expired,
    ),
  ];

  @override
  Future<List<InsurancePolicy>> getPolicies() async {
    getPoliciesCallCount++;
    await _wait();
    return List<InsurancePolicy>.unmodifiable(_policies);
  }

  @override
  Future<void> addIssuedPolicy(InsurancePolicy policy) async {
    await _wait();
    final int existingIndex = _policies.indexWhere(
      (InsurancePolicy item) =>
          item.id == policy.id || item.policyNumber == policy.policyNumber,
    );
    if (existingIndex >= 0) {
      _policies[existingIndex] = policy;
      return;
    }
    _policies.insert(0, policy);
  }

  Future<void> _wait() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }
}

import '../../domain/entities/insurance_policy.dart';
import '../../domain/entities/policy_details.dart';
import '../../domain/repositories/policy_details_repository.dart';

class MockPolicyDetailsRepository implements PolicyDetailsRepository {
  const MockPolicyDetailsRepository();

  @override
  Future<PolicyDetails> getPolicyDetails(InsurancePolicy policy) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    switch (policy.type) {
      case PolicyType.vehicle:
        return PolicyDetails(
          policy: policy,
          coverage: 'Comprehensive Vehicle Coverage',
          primaryLabel: 'Insured Vehicle',
          primaryValue: 'Toyota Corolla 2022',
          secondaryLabel: 'Registration No.',
          secondaryValue: 'ABC-123',
          tertiaryLabel: 'Chassis No.',
          tertiaryValue: 'JTDBR32E9N1234567',
          isStoredOnBlockchain: true,
          transactionHash: '0xA23F91BC83A4D72918F126C84591BC',
        );

      case PolicyType.health:
        return PolicyDetails(
          policy: policy,
          coverage: 'Comprehensive Health Coverage',
          primaryLabel: 'Plan Type',
          primaryValue: 'Family Health Plan',
          secondaryLabel: 'Member ID',
          secondaryValue: 'HLT-2026-002',
          tertiaryLabel: 'Hospital Network',
          tertiaryValue: 'Premium Network',
          isStoredOnBlockchain: true,
          transactionHash: '0xB841CA7629D472165FC2308712A09D',
        );

      case PolicyType.travel:
        return PolicyDetails(
          policy: policy,
          coverage: 'International Travel Coverage',
          primaryLabel: 'Destination',
          primaryValue: 'United Arab Emirates',
          secondaryLabel: 'Trip Duration',
          secondaryValue: '10 Mar - 20 Mar 2027',
          tertiaryLabel: 'Coverage Type',
          tertiaryValue: 'International',
          isStoredOnBlockchain: true,
          transactionHash: '0xC728DE126E932816AF2719246DD123',
        );

      case PolicyType.life:
        return PolicyDetails(
          policy: policy,
          coverage: 'Life Protection Coverage',
          primaryLabel: 'Provider',
          primaryValue: policy.providerName ?? 'Insurance Provider',
          secondaryLabel: 'Coverage Amount',
          secondaryValue: _coverageValue(policy),
          tertiaryLabel: 'Document Reference',
          tertiaryValue: policy.documentReference ?? 'Pending',
          isStoredOnBlockchain: policy.blockchainRecordStatus == 'Recorded',
          transactionHash: policy.blockchainRecordStatus ?? 'Pending',
        );

      case PolicyType.property:
        return PolicyDetails(
          policy: policy,
          coverage: 'Property Protection Coverage',
          primaryLabel: 'Provider',
          primaryValue: policy.providerName ?? 'Insurance Provider',
          secondaryLabel: 'Coverage Amount',
          secondaryValue: _coverageValue(policy),
          tertiaryLabel: 'Document Reference',
          tertiaryValue: policy.documentReference ?? 'Pending',
          isStoredOnBlockchain: policy.blockchainRecordStatus == 'Recorded',
          transactionHash: policy.blockchainRecordStatus ?? 'Pending',
        );
    }
  }

  static String _coverageValue(InsurancePolicy policy) {
    final String value = (policy.coverageAmount ?? 0).toStringAsFixed(0);
    return 'PKR ${value.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}';
  }
}

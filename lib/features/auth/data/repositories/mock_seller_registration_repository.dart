import '../../domain/entities/seller_registration.dart';
import '../../domain/repositories/seller_registration_repository.dart';

class MockSellerRegistrationRepository implements SellerRegistrationRepository {
  MockSellerRegistrationRepository({
    this.resultStatus = SellerRegistrationStatus.pendingApproval,
    this.delay = const Duration(milliseconds: 900),
    this.throwTechnicalFailure = false,
  });

  final SellerRegistrationStatus resultStatus;
  final Duration delay;
  final bool throwTechnicalFailure;

  int submitCallCount = 0;
  SellerRegistrationRequest? lastRequest;

  @override
  Future<SellerRegistrationResult> submitRegistration(
    SellerRegistrationRequest request,
  ) async {
    submitCallCount++;
    lastRequest = request;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (throwTechnicalFailure) {
      throw StateError('Synthetic seller-registration failure.');
    }
    return SellerRegistrationResult(
      status: resultStatus,
      referenceNumber: resultStatus == SellerRegistrationStatus.pendingApproval
          ? 'IX-SLR-2026-00124'
          : null,
    );
  }
}

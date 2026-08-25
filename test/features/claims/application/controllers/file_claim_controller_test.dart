import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/claims/application/controllers/file_claim_controller.dart';
import 'package:insurancex/features/claims/domain/entities/ai_verification_result.dart';
import 'package:insurancex/features/claims/domain/entities/claim_image.dart';
import 'package:insurancex/features/claims/domain/entities/claim_policy.dart';
import 'package:insurancex/features/claims/domain/entities/claim_request.dart';
import 'package:insurancex/features/claims/domain/entities/claim_submission_result.dart';
import 'package:insurancex/features/claims/domain/entities/incident_details.dart';
import 'package:insurancex/features/claims/domain/repositories/claim_image_repository.dart';
import 'package:insurancex/features/claims/domain/repositories/claim_image_source.dart';
import 'package:insurancex/features/claims/domain/repositories/claim_verification_repository.dart';
import 'package:insurancex/features/claims/domain/repositories/file_claim_repository.dart';

void main() {
  group('FileClaimController', () {
    test('preselects an eligible policy and enforces the image step', () async {
      final FileClaimController controller = _controller(
        initialPolicyId: 'policy-1',
      );

      await controller.loadPolicies();

      expect(controller.selectedPolicy?.id, 'policy-1');
      expect(controller.nextStep(), isTrue);
      expect(controller.currentStep, FileClaimStep.incidentDetails);

      controller.updateIncidentDetails(_validIncident());
      expect(controller.nextStep(), isTrue);
      expect(controller.currentStep, FileClaimStep.images);

      expect(controller.nextStep(), isFalse);
      expect(controller.stepErrorMessage, contains('at least one'));
    });

    test(
      'loads policies once unless an explicit refresh is requested',
      () async {
        final _FakeFileClaimRepository repository = _FakeFileClaimRepository();
        final FileClaimController controller = _controller(
          repository: repository,
        );

        await controller.loadPolicies();
        controller.selectPolicy(controller.eligiblePolicies.first);
        await controller.loadPolicies();

        expect(repository.loadCalls, 1);
        expect(controller.selectedPolicy?.id, 'policy-1');

        await controller.refreshPolicies();

        expect(repository.loadCalls, 2);
        expect(controller.selectedPolicy?.id, 'policy-1');
      },
    );

    test(
      'reports AI progress and invalidates verification after image changes',
      () async {
        final FileClaimController controller = _controller();
        await _advanceToImages(controller);
        await controller.addImages(ClaimImageSourceType.gallery);
        expect(controller.nextStep(), isTrue);

        final List<AiVerificationState> states = <AiVerificationState>[];
        controller.addListener(() {
          states.add(controller.verificationState);
        });

        expect(await controller.verifyImages(), isTrue);
        expect(states, contains(AiVerificationState.uploading));
        expect(states, contains(AiVerificationState.analysing));
        expect(controller.verificationState, AiVerificationState.verified);
        expect(controller.verificationResult, isNotNull);

        controller.removeImage(controller.images.first.id);

        expect(controller.verificationState, AiVerificationState.idle);
        expect(controller.verificationResult, isNull);
      },
    );

    test(
      'prevents duplicate submission while the first request is pending',
      () async {
        final _FakeFileClaimRepository repository = _FakeFileClaimRepository(
          submissionCompleter: Completer<ClaimSubmissionResult>(),
        );
        final FileClaimController controller = _controller(
          repository: repository,
        );
        await _advanceToReview(controller);
        controller
          ..setDeclarationAccepted(true)
          ..setAiConsentAccepted(true);

        final Future<ClaimSubmissionResult?> firstSubmission = controller
            .submitClaim();
        final ClaimSubmissionResult? duplicate = await controller.submitClaim();

        expect(duplicate, isNull);
        expect(repository.submissionCalls, 1);
        expect(controller.submissionState, ClaimSubmissionState.submitting);

        repository.submissionCompleter!.complete(_submissionResult());
        final ClaimSubmissionResult? result = await firstSubmission;

        expect(result?.claimId, 'CLM-2026-00124');
        expect(controller.submissionState, ClaimSubmissionState.success);
      },
    );
  });
}

FileClaimController _controller({
  String? initialPolicyId,
  _FakeFileClaimRepository? repository,
}) {
  return FileClaimController(
    fileClaimRepository: repository ?? _FakeFileClaimRepository(),
    verificationRepository: _FakeVerificationRepository(),
    imageSource: _FakeImageSource(),
    imageRepository: _FakeImageRepository(),
    initialPolicyId: initialPolicyId,
    now: () => DateTime(2026, 8, 26, 12),
    verificationStageDelay: Duration.zero,
  );
}

Future<void> _advanceToImages(FileClaimController controller) async {
  await controller.loadPolicies();
  controller.selectPolicy(controller.eligiblePolicies.first);
  expect(controller.nextStep(), isTrue);
  controller.updateIncidentDetails(_validIncident());
  expect(controller.nextStep(), isTrue);
}

Future<void> _advanceToReview(FileClaimController controller) async {
  await _advanceToImages(controller);
  await controller.addImages(ClaimImageSourceType.gallery);
  expect(controller.nextStep(), isTrue);
  expect(await controller.verifyImages(), isTrue);
  expect(controller.nextStep(), isTrue);
  expect(controller.currentStep, FileClaimStep.review);
}

IncidentDetails _validIncident() {
  return IncidentDetails(
    incidentType: IncidentType.collision,
    occurredAt: DateTime(2026, 8, 25, 16, 30),
    location: 'Main Boulevard, Lahore',
    title: 'Front bumper collision',
    description: 'Another vehicle struck the front bumper while it was parked.',
    estimatedLoss: 85000,
  );
}

ClaimPolicy _policy() {
  return ClaimPolicy(
    id: 'policy-1',
    name: 'Vehicle Insurance',
    policyNumber: 'INS-2026-001',
    type: ClaimPolicyType.vehicle,
    coverageType: 'Comprehensive Vehicle Coverage',
    expiresAt: DateTime(2027, 8, 14),
    coverageLimit: 2500000,
    status: ClaimPolicyStatus.active,
  );
}

AiVerificationResult _verificationResult() {
  return AiVerificationResult(
    classification: EvidenceClassification.authentic,
    fraudRiskScore: 12,
    confidenceScore: 95,
    detectedIssues: const <String>[],
    requiresManualReview: false,
    modelVersion: 'test-model',
    analysisTimestamp: DateTime(2026, 8, 26),
  );
}

ClaimSubmissionResult _submissionResult() {
  return ClaimSubmissionResult(
    claimId: 'CLM-2026-00124',
    submittedAt: DateTime(2026, 8, 26, 12),
    status: ClaimStatus.pendingReview,
    aiVerificationCompleted: true,
    blockchainRecordStatus: 'Pending Integration',
  );
}

class _FakeFileClaimRepository implements FileClaimRepository {
  _FakeFileClaimRepository({this.submissionCompleter});

  final Completer<ClaimSubmissionResult>? submissionCompleter;
  int loadCalls = 0;
  int submissionCalls = 0;

  @override
  Future<List<ClaimPolicy>> loadPolicies() async {
    loadCalls++;
    return <ClaimPolicy>[_policy()];
  }

  @override
  Future<ClaimSubmissionResult> submitClaim(ClaimRequest request) {
    submissionCalls++;
    return submissionCompleter?.future ??
        Future<ClaimSubmissionResult>.value(_submissionResult());
  }
}

class _FakeVerificationRepository implements ClaimVerificationRepository {
  @override
  Future<AiVerificationResult> verifyImages(List<ClaimImage> images) async {
    return _verificationResult();
  }
}

class _FakeImageSource implements ClaimImageSource {
  int _sequence = 0;

  @override
  Future<List<ClaimImage>> selectImages({
    required ClaimImageSourceType source,
    required bool allowMultiple,
  }) async {
    _sequence++;
    return <ClaimImage>[
      ClaimImage(
        id: 'image-$_sequence',
        fileName: 'incident_$_sequence.jpg',
        localPath: '/mock/incident_$_sequence.jpg',
        fileSizeBytes: 1024,
        captureTimestamp: DateTime(2026, 8, 26),
        source: source,
      ),
    ];
  }
}

class _FakeImageRepository implements ClaimImageRepository {
  @override
  Stream<double> uploadImage(ClaimImage image) async* {
    yield 1;
  }
}

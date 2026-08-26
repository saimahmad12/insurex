import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/app.dart';
import 'package:insurancex/core/navigation/app_routes.dart';
import 'package:insurancex/core/theme/app_theme.dart';
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
import 'package:insurancex/features/claims/presentation/pages/claim_submitted_page.dart';
import 'package:insurancex/features/claims/presentation/pages/file_claim_page.dart';

void main() {
  testWidgets('named route rebuild preserves incident state and controller', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InsureXApp());
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator),
    );

    unawaited(navigator.pushNamed(AppRoutes.fileClaim));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('claim_policy_1')));
    await tester.tap(find.byKey(const Key('file_claim_continue')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('incident_type_field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vehicle collision').last);
    await tester.enterText(
      find.byKey(const Key('incident_location_field')),
      'Preserved incident location',
    );
    await tester.pump();

    final ModalRoute<dynamic> route = ModalRoute.of(
      tester.element(find.byType(FileClaimPage)),
    )!;
    route.changedExternalState();
    await tester.pump();

    expect(find.text('Incident Details'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    final TextFormField locationField = tester.widget<TextFormField>(
      find.byKey(const Key('incident_location_field')),
    );
    expect(locationField.controller?.text, 'Preserved incident location');
  });

  testWidgets('navigates steps and blocks an image-free claim', (
    WidgetTester tester,
  ) async {
    final FileClaimController controller = _controller();
    await _pumpClaimPage(tester, controller);

    await tester.tap(find.byKey(const Key('claim_policy_policy-1')));
    await tester.tap(find.byKey(const Key('file_claim_continue')));
    await tester.pumpAndSettle();

    expect(find.text('Incident Details'), findsOneWidget);

    await tester.tap(find.byKey(const Key('incident_type_field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vehicle collision').last);
    await tester.pumpAndSettle();

    controller.updateIncidentDetails(
      controller.incidentDetails.copyWith(
        occurredAt: DateTime(2026, 8, 25, 16, 30),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('incident_location_field')),
      'Main Boulevard, Lahore',
    );
    await tester.enterText(
      find.byKey(const Key('incident_title_field')),
      'Front bumper collision',
    );
    await tester.enterText(
      find.byKey(const Key('incident_description_field')),
      'Another vehicle struck the front bumper while it was parked.',
    );
    await tester.enterText(
      find.byKey(const Key('estimated_loss_field')),
      '85000',
    );
    await tester.tap(find.byKey(const Key('file_claim_continue')));
    await tester.pumpAndSettle();

    expect(find.text('Upload Incident Images'), findsOneWidget);

    await tester.tap(find.byKey(const Key('file_claim_continue')));
    await tester.pump();

    expect(find.byKey(const Key('claim_step_error')), findsOneWidget);
    expect(find.textContaining('at least one incident image'), findsOneWidget);
  });

  testWidgets('shows the empty-policy state', (WidgetTester tester) async {
    final FileClaimController controller = _controller(
      repository: _FakeFileClaimRepository(policies: <ClaimPolicy>[]),
    );

    await _pumpClaimPage(tester, controller);

    expect(find.text('No eligible policies'), findsOneWidget);
    expect(
      find.text('An active, unexpired policy is required to file a claim.'),
      findsOneWidget,
    );
  });

  testWidgets('shows AI progress and clears the result after image changes', (
    WidgetTester tester,
  ) async {
    final Completer<AiVerificationResult> verificationCompleter =
        Completer<AiVerificationResult>();
    final FileClaimController controller = _controller(
      verificationRepository: _FakeVerificationRepository(
        completer: verificationCompleter,
      ),
    );
    await _advanceToVerification(controller);
    await _pumpClaimPage(tester, controller);

    final Future<bool> verification = controller.verifyImages();
    await tester.pump();

    expect(find.byKey(const Key('verification_progress')), findsOneWidget);
    expect(find.text('Analysing incident evidence'), findsOneWidget);

    verificationCompleter.complete(_verificationResult());
    expect(await verification, isTrue);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('verification_result')), findsOneWidget);
    expect(find.text('Verification completed'), findsOneWidget);

    controller.removeImage(controller.images.first.id);
    await tester.pump();

    expect(find.byKey(const Key('verification_result')), findsNothing);
    expect(find.byKey(const Key('verify_images_button')), findsOneWidget);
  });

  testWidgets('guards duplicate submission and displays successful result', (
    WidgetTester tester,
  ) async {
    final Completer<ClaimSubmissionResult> submissionCompleter =
        Completer<ClaimSubmissionResult>();
    final _FakeFileClaimRepository repository = _FakeFileClaimRepository(
      submissionCompleter: submissionCompleter,
    );
    final FileClaimController controller = _controller(repository: repository);
    await _advanceToReview(controller);

    ClaimSubmissionResult? submittedResult;
    await _pumpClaimPage(
      tester,
      controller,
      onSubmitted: (ClaimSubmissionResult result) {
        submittedResult = result;
      },
    );

    await tester.ensureVisible(
      find.byKey(const Key('claim_declaration_checkbox')),
    );
    await tester.tap(find.byKey(const Key('claim_declaration_checkbox')));
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const Key('claim_ai_consent_checkbox')),
    );
    await tester.tap(find.byKey(const Key('claim_ai_consent_checkbox')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('file_claim_continue')));

    await tester.tap(find.byKey(const Key('file_claim_continue')));
    await tester.tap(find.byKey(const Key('file_claim_continue')));
    await tester.pump();

    expect(repository.submissionCalls, 1);
    expect(controller.submissionState, ClaimSubmissionState.submitting);

    submissionCompleter.complete(_submissionResult());
    await tester.pumpAndSettle();

    expect(submittedResult?.claimId, 'CLM-2026-00124');
    expect(controller.submissionState, ClaimSubmissionState.success);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: ClaimSubmittedPage(
          result: submittedResult!,
          onTrackClaim: () {},
          onReturnToDashboard: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('claim_submitted_title')), findsOneWidget);
    expect(find.text('CLM-2026-00124'), findsOneWidget);
    expect(find.text('Under Review'), findsOneWidget);
    expect(find.text('Track Claim'), findsOneWidget);
    expect(find.text('Return to Dashboard'), findsOneWidget);
  });
}

Future<void> _pumpClaimPage(
  WidgetTester tester,
  FileClaimController controller, {
  ValueChanged<ClaimSubmissionResult>? onSubmitted,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: FileClaimPage(
        controller: controller,
        onBack: () {},
        onSubmitted: onSubmitted ?? (ClaimSubmissionResult result) {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

FileClaimController _controller({
  _FakeFileClaimRepository? repository,
  _FakeVerificationRepository? verificationRepository,
}) {
  return FileClaimController(
    fileClaimRepository: repository ?? _FakeFileClaimRepository(),
    verificationRepository:
        verificationRepository ?? _FakeVerificationRepository(),
    imageSource: _FakeImageSource(),
    imageRepository: _FakeImageRepository(),
    now: () => DateTime(2026, 8, 26, 12),
    verificationStageDelay: Duration.zero,
  );
}

Future<void> _advanceToVerification(FileClaimController controller) async {
  await controller.loadPolicies();
  controller.selectPolicy(controller.eligiblePolicies.first);
  controller.nextStep();
  controller.updateIncidentDetails(_validIncident());
  controller.nextStep();
  await controller.addImages(ClaimImageSourceType.gallery);
  controller.nextStep();
}

Future<void> _advanceToReview(FileClaimController controller) async {
  await _advanceToVerification(controller);
  await controller.verifyImages();
  controller.nextStep();
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
    status: ClaimStatus.underReview,
    aiVerificationCompleted: true,
    blockchainRecordStatus: 'Pending Integration',
  );
}

class _FakeFileClaimRepository implements FileClaimRepository {
  _FakeFileClaimRepository({
    List<ClaimPolicy>? policies,
    this.submissionCompleter,
  }) : policies = policies ?? <ClaimPolicy>[_policy()];

  final List<ClaimPolicy> policies;
  final Completer<ClaimSubmissionResult>? submissionCompleter;
  int submissionCalls = 0;

  @override
  Future<List<ClaimPolicy>> loadPolicies() async => policies;

  @override
  Future<ClaimSubmissionResult> submitClaim(ClaimRequest request) {
    submissionCalls++;
    return submissionCompleter?.future ??
        Future<ClaimSubmissionResult>.value(_submissionResult());
  }
}

class _FakeVerificationRepository implements ClaimVerificationRepository {
  _FakeVerificationRepository({this.completer});

  final Completer<AiVerificationResult>? completer;

  @override
  Future<AiVerificationResult> verifyImages(List<ClaimImage> images) {
    return completer?.future ??
        Future<AiVerificationResult>.value(_verificationResult());
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

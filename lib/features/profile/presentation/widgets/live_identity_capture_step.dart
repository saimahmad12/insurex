import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/identity_verification_draft.dart';

typedef IdentityCaptureOverride =
    Future<IdentityCaptureInput> Function(IdentityCaptureSide side);

class LiveIdentityCaptureStep extends StatefulWidget {
  const LiveIdentityCaptureStep({
    required this.side,
    required this.title,
    required this.instructions,
    required this.hasRegisteredCapture,
    required this.isRegistering,
    required this.onRegister,
    required this.onRetake,
    required this.onContinue,
    this.captureOverride,
    super.key,
  });

  final IdentityCaptureSide side;
  final String title;
  final String instructions;
  final bool hasRegisteredCapture;
  final bool isRegistering;
  final Future<bool> Function(IdentityCaptureInput input) onRegister;
  final Future<void> Function() onRetake;
  final VoidCallback onContinue;
  final IdentityCaptureOverride? captureOverride;

  @override
  State<LiveIdentityCaptureStep> createState() =>
      _LiveIdentityCaptureStepState();
}

class _LiveIdentityCaptureStepState extends State<LiveIdentityCaptureStep>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  XFile? _preview;
  bool _initializing = true;
  bool _takingPicture = false;
  String? _cameraError;
  int _cameraGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.captureOverride == null) {
      _initializeCamera();
    } else {
      _initializing = false;
    }
  }

  @override
  void didUpdateWidget(covariant LiveIdentityCaptureStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.side != widget.side && widget.captureOverride == null) {
      _disposeCamera().then((_) => _initializeCamera());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.captureOverride != null) return;
    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (!mounted) return;
    final int generation = ++_cameraGeneration;
    final CameraController? previous = _cameraController;
    _cameraController = null;
    CameraController? pending;
    setState(() => _initializing = true);
    try {
      await previous?.dispose();
      final List<CameraDescription> cameras = await availableCameras();
      if (!mounted || generation != _cameraGeneration) return;
      final CameraLensDirection direction =
          widget.side == IdentityCaptureSide.selfie
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      final CameraDescription selected = cameras.firstWhere(
        (CameraDescription item) => item.lensDirection == direction,
        orElse: () => cameras.first,
      );
      final CameraController controller = CameraController(
        selected,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      pending = controller;
      await controller.initialize();
      if (!mounted || generation != _cameraGeneration) return;
      _cameraController = controller;
      pending = null;
      setState(() {
        _initializing = false;
        _cameraError = null;
      });
    } catch (_) {
      if (mounted && generation == _cameraGeneration) {
        setState(() {
          _initializing = false;
          _cameraError =
              'Camera access is required for secure live identity capture.';
        });
      }
    } finally {
      await pending?.dispose();
    }
  }

  Future<void> _capture() async {
    if (_takingPicture || widget.isRegistering) return;
    setState(() => _takingPicture = true);
    try {
      final IdentityCaptureInput input;
      final IdentityCaptureOverride? override = widget.captureOverride;
      if (override != null) {
        input = await override(widget.side);
      } else {
        final CameraController controller = _cameraController!;
        final XFile file = await controller.takePicture();
        _preview = file;
        final List<int> bytes = await file.readAsBytes();
        final Size previewSize = controller.value.previewSize ?? Size.zero;
        final int width = math.max(
          previewSize.width.round(),
          previewSize.height.round(),
        );
        final int height = math.min(
          previewSize.width.round(),
          previewSize.height.round(),
        );
        final int sampleLength = math.min(bytes.length, 2048);
        input = IdentityCaptureInput(
          side: widget.side,
          temporaryPath: file.path,
          fingerprint: Object.hashAll(<Object>[
            bytes.length,
            ...bytes.take(sampleLength),
          ]).toUnsigned(32).toRadixString(16),
          quality: IdentityCaptureQuality(
            width: width,
            height: height,
            fileSizeBytes: bytes.length,
            averageLuminance: 0,
            sharpnessScore: 0,
          ),
        );
      }
      if (!mounted) return;
      final bool accepted = await widget.onRegister(input);
      if (!accepted && mounted && _preview != null) {
        try {
          await File(_preview!.path).delete();
        } catch (_) {
          // The repository may already have removed the temporary capture.
        }
        _preview = null;
      }
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        setState(
          () => _cameraError = 'The live capture could not be completed.',
        );
      }
    } finally {
      if (mounted) setState(() => _takingPicture = false);
    }
  }

  Future<void> _retake() async {
    await widget.onRetake();
    _preview = null;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelfie = widget.side == IdentityCaptureSide.selfie;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
      children: <Widget>[
        Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.instructions,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 18),
        AspectRatio(
          aspectRatio: isSelfie ? 3 / 4 : 1.58,
          child: GlassContainer(
            padding: const EdgeInsets.all(5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (_preview != null)
                    Image.file(File(_preview!.path), fit: BoxFit.cover)
                  else if (_cameraController?.value.isInitialized == true)
                    CameraPreview(_cameraController!)
                  else
                    ColoredBox(
                      color: Colors.black.withValues(alpha: 0.38),
                      child: Center(
                        child: _initializing
                            ? const CircularProgressIndicator()
                            : Icon(
                                isSelfie
                                    ? Icons.face_retouching_natural_rounded
                                    : Icons.badge_outlined,
                                size: 54,
                                color: Colors.white70,
                              ),
                      ),
                    ),
                  IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.all(17),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.blue, width: 2),
                          borderRadius: BorderRadius.circular(
                            isSelfie ? 90 : 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.hasRegisteredCapture)
                    const Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF49E6A4),
                          size: 32,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (_cameraError != null)
          Text(
            _cameraError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFB3261E)),
          ),
        if (!isSelfie)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Keep all four corners visible. Avoid blur, glare, shadows, cropping, and unreadable text. Frontend checks assist image quality only and do not prove authenticity.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        const SizedBox(height: 10),
        if (!widget.hasRegisteredCapture)
          GlassActionButton(
            key: Key('capture_${widget.side.name}_button'),
            label: isSelfie ? 'Complete Live Selfie' : 'Capture Now',
            icon: Icons.camera_alt_outlined,
            isLoading: _takingPicture || widget.isRegistering,
            onPressed:
                _cameraError != null ||
                    (_cameraController?.value.isInitialized != true &&
                        widget.captureOverride == null)
                ? null
                : _capture,
          )
        else ...<Widget>[
          GlassActionButton(
            key: Key('continue_${widget.side.name}_button'),
            label: 'Use This Capture',
            icon: Icons.arrow_forward_rounded,
            onPressed: widget.onContinue,
          ),
          TextButton(
            key: Key('retake_${widget.side.name}_button'),
            onPressed: _retake,
            child: const Text('Retake'),
          ),
        ],
      ],
    );
  }

  Future<void> _disposeCamera() async {
    _cameraGeneration++;
    final CameraController? controller = _cameraController;
    _cameraController = null;
    await controller?.dispose();
  }
}

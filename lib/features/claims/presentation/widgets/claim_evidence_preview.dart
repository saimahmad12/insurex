import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/claim_image.dart';

class ClaimEvidencePreview extends StatelessWidget {
  const ClaimEvidencePreview({
    required this.images,
    required this.analysedImageCount,
    required this.onImagePressed,
    super.key,
  });

  final List<ClaimImage> images;
  final int analysedImageCount;
  final ValueChanged<int> onImagePressed;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      key: const Key('claim_evidence_preview'),
      padding: const EdgeInsets.all(16),
      child: images.isEmpty
          ? const _UnavailableImage(message: 'No submitted images available')
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.05,
              ),
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index) {
                final ClaimImage image = images[index];
                final bool analysed = index < analysedImageCount;
                return InkWell(
                  key: ValueKey<String>('claim_evidence_${image.id}'),
                  onTap: () {
                    onImagePressed(index);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.045),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          _EvidenceImage(image: image),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(9, 18, 9, 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.76),
                                  ],
                                ),
                              ),
                              child: Text(
                                image.fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (analysed
                                            ? const Color(0xFF49E6A4)
                                            : AppColors.textSecondary)
                                        .withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                analysed ? 'Analysed' : 'Pending',
                                style: const TextStyle(
                                  color: Color(0xFF061027),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ClaimEvidencePreviewDialog extends StatefulWidget {
  const ClaimEvidencePreviewDialog({
    required this.images,
    required this.initialIndex,
    super.key,
  });

  final List<ClaimImage> images;
  final int initialIndex;

  @override
  State<ClaimEvidencePreviewDialog> createState() =>
      _ClaimEvidencePreviewDialogState();
}

class _ClaimEvidencePreviewDialogState
    extends State<ClaimEvidencePreviewDialog> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('claim_evidence_dialog'),
      backgroundColor: const Color(0xFF101936),
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 430,
        height: 520,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.images[_currentIndex].fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close image preview',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _EvidenceImage(image: widget.images[index]),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 5, 14, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    tooltip: 'Previous image',
                    onPressed: _currentIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Text(
                    '${_currentIndex + 1} of ${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next image',
                    onPressed: _currentIndex < widget.images.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EvidenceImage extends StatelessWidget {
  const _EvidenceImage({required this.image});

  final ClaimImage image;

  @override
  Widget build(BuildContext context) {
    if (image.localPath.startsWith('assets/')) {
      return Image.asset(
        image.localPath,
        fit: BoxFit.cover,
        errorBuilder: _errorBuilder,
      );
    }
    if (image.localPath.startsWith('http://') ||
        image.localPath.startsWith('https://')) {
      return Image.network(
        image.localPath,
        fit: BoxFit.cover,
        errorBuilder: _errorBuilder,
      );
    }
    return const _UnavailableImage(message: 'Image preview unavailable');
  }

  Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const _UnavailableImage(message: 'Image preview unavailable');
  }
}

class _UnavailableImage extends StatelessWidget {
  const _UnavailableImage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white.withValues(alpha: 0.045),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.image_not_supported_outlined,
                color: Colors.white70,
                size: 30,
              ),
              const SizedBox(height: 7),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.58),
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

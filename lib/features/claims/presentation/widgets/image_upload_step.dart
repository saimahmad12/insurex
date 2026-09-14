import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/claim_image.dart';
import 'claim_formatters.dart';

class ImageUploadStep extends StatelessWidget {
  const ImageUploadStep({
    required this.images,
    required this.onCamera,
    required this.onGallery,
    required this.onRemove,
    required this.onReplace,
    required this.onRetry,
    super.key,
    this.errorMessage,
  });

  final List<ClaimImage> images;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onReplace;
  final ValueChanged<String> onRetry;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('image_upload_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Add clear incident evidence. At least one image is required.',
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.75),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: _SourceAction(
                key: const Key('camera_image_action'),
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: onCamera,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SourceAction(
                key: const Key('gallery_image_action'),
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: onGallery,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Mock image selection is active until a real picker is connected. JPG, JPEG, or PNG · max 10 MB each.',
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.55),
            fontSize: 11.5,
          ),
        ),
        if (errorMessage != null) ...<Widget>[
          const SizedBox(height: 12),
          _InlineError(message: errorMessage!),
        ],
        const SizedBox(height: 18),
        if (images.isEmpty)
          GlassContainer(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppColors.textSecondary.withValues(alpha: 0.65),
                  size: 42,
                ),
                const SizedBox(height: 11),
                const Text(
                  'No incident images added',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          for (final ClaimImage image in images) ...<Widget>[
            _ImagePreviewCard(
              image: image,
              onRemove: () => onRemove(image.id),
              onReplace: () => onReplace(image.id),
              onRetry: () => onRetry(image.id),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _SourceAction extends StatelessWidget {
  const _SourceAction({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 17),
          child: Column(
            children: <Widget>[
              Icon(icon, color: AppColors.blue, size: 27),
              const SizedBox(height: 7),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreviewCard extends StatelessWidget {
  const _ImagePreviewCard({
    required this.image,
    required this.onRemove,
    required this.onReplace,
    required this.onRetry,
  });

  final ClaimImage image;
  final VoidCallback onRemove;
  final VoidCallback onReplace;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final bool failed = image.uploadStatus == ClaimImageUploadStatus.failed;
    final bool uploaded = image.uploadStatus == ClaimImageUploadStatus.uploaded;

    return GlassContainer(
      key: Key('claim_image_${image.id}'),
      padding: const EdgeInsets.all(13),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[AppColors.blue, AppColors.blue],
                  ),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: AppColors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      image.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${ClaimFormatters.fileSize(image.fileSizeBytes)} · ${image.source.name}',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      failed
                          ? 'Upload failed'
                          : uploaded
                          ? 'Uploaded'
                          : 'Uploading ${(image.uploadProgress * 100).round()}%',
                      style: TextStyle(
                        color: failed
                            ? const Color(0xFFFF8A9B)
                            : uploaded
                            ? const Color(0xFF49E6A4)
                            : AppColors.blue,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: const Color(0xFF151E42),
                iconColor: Colors.white70,
                onSelected: (String value) {
                  if (value == 'replace') {
                    onReplace();
                  } else {
                    onRemove();
                  }
                },
                itemBuilder: (BuildContext context) =>
                    const <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'replace',
                        child: Text(
                          'Replace image',
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'remove',
                        child: Text(
                          'Remove image',
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    ],
              ),
            ],
          ),
          if (!uploaded && !failed) ...<Widget>[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: image.uploadProgress,
              minHeight: 4,
              backgroundColor: AppColors.white.withValues(alpha: 0.08),
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
          if (failed) ...<Widget>[
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry upload'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6680).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFFF8A9B).withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFFB3261E), fontSize: 12),
      ),
    );
  }
}

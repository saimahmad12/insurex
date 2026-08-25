enum ClaimImageSourceType { camera, gallery }

enum ClaimImageUploadStatus { pending, uploading, uploaded, failed }

class ClaimImage {
  const ClaimImage({
    required this.id,
    required this.fileName,
    required this.localPath,
    required this.fileSizeBytes,
    required this.captureTimestamp,
    required this.source,
    this.latitude,
    this.longitude,
    this.uploadStatus = ClaimImageUploadStatus.pending,
    this.uploadProgress = 0,
  });

  final String id;
  final String fileName;
  final String localPath;
  final int fileSizeBytes;
  final DateTime captureTimestamp;
  final double? latitude;
  final double? longitude;
  final ClaimImageSourceType source;
  final ClaimImageUploadStatus uploadStatus;
  final double uploadProgress;

  ClaimImage copyWith({
    ClaimImageUploadStatus? uploadStatus,
    double? uploadProgress,
  }) {
    return ClaimImage(
      id: id,
      fileName: fileName,
      localPath: localPath,
      fileSizeBytes: fileSizeBytes,
      captureTimestamp: captureTimestamp,
      latitude: latitude,
      longitude: longitude,
      source: source,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

import 'package:flutter/material.dart';

/// Loads a remote or bundled image without throwing when the path is empty
/// or the asset is missing (a common iOS release crash).
class SafeNetworkOrAssetImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final String fallbackAsset;

  const SafeNetworkOrAssetImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.fallbackAsset = 'assets/images/other/QuestionMark.png',
  });

  bool get _isRemote {
    final url = imageUrl.trim();
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => SizedBox(width: width, height: height),
    );

    final url = imageUrl.trim();
    if (url.isEmpty) {
      return fallback;
    }

    if (_isRemote) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return Image.asset(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

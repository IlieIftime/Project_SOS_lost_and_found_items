import 'package:flutter/material.dart';
import '../utils/assets.dart';

Widget buildAssetImageIfExists(String? assetPath, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (assetPath == null || assetPath.isEmpty) return const SizedBox.shrink();
  if (!assetImages.contains(assetPath)) return const SizedBox.shrink();
  try {
    return Image.asset(assetPath, width: width, height: height, fit: fit);
  } catch (_) {
    return const SizedBox.shrink();
  }
}

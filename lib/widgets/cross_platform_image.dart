import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class CrossPlatformImage extends StatelessWidget {
  final dynamic imageSource;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  const CrossPlatformImage({
    Key? key,
    required this.imageSource,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageSource == null) {
      return errorWidget ?? const SizedBox();
    }

    if (kIsWeb) {
      // For web, use Image.network for URLs or handle File differently
      if (imageSource is String) {
        return Image.network(
          imageSource,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? const Icon(Icons.error);
          },
        );
      } else if (imageSource is File) {
        // For web, we need to use bytes instead of File
        return FutureBuilder<Uint8List>(
          future: imageSource.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.memory(
                snapshot.data!,
                width: width,
                height: height,
                fit: fit,
              );
            } else if (snapshot.hasError) {
              return errorWidget ?? const Icon(Icons.error);
            }
            return const CircularProgressIndicator();
          },
        );
      }
    } else {
      // For mobile platforms
      if (imageSource is String) {
        if (imageSource.startsWith('http')) {
          return Image.network(
            imageSource,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return errorWidget ?? const Icon(Icons.error);
            },
          );
        } else {
          return Image.file(
            File(imageSource),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return errorWidget ?? const Icon(Icons.error);
            },
          );
        }
      } else if (imageSource is File) {
        return Image.file(
          imageSource,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? const Icon(Icons.error);
          },
        );
      }
    }

    return errorWidget ?? const Icon(Icons.error);
  }
}
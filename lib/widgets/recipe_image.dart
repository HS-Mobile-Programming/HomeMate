// lib/widgets/recipe_image.dart
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RecipeImage extends StatelessWidget {
  final String imageName;
  final double width;
  final double height;

  const RecipeImage({
    super.key,
    required this.imageName,
    this.width = 120,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (imageName.isEmpty) {
      // imageName이 비어 있으면 기본 아이콘 표시
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported),
      );
    }

    final ref =
    FirebaseStorage.instance.ref().child('recipes/$imageName'); // Storage 경로

    return FutureBuilder<String>(
      future: ref.getDownloadURL(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.error),
          );
        }

        final url = snapshot.data!;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: width,
            height: height,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

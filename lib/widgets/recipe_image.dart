// 레시피 이미지 위젯: Firebase Storage에서 레시피 이미지 비동기 로드 및 표시
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RecipeImage extends StatelessWidget {
  // Firebase Storage 이미지 파일명
  final String imageName;
  // 이미지 가로 크기
  final double width;
  // 이미지 세로 크기
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
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported),
      );
    }

    final _storageRef = FirebaseStorage.instance.ref().child(
      'recipes/$imageName',
    );

    return FutureBuilder<String>(
      future: _storageRef.getDownloadURL(),
      builder: (context, _snapshot) {
        final _imageUrl = _snapshot.data!;

        if (_snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (_snapshot.hasError || !_snapshot.hasData) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.error),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            _imageUrl,
            width: width,
            height: height,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
/// 레시피 목록 화면에서 사용되는 개별 레시피 카드 위젯
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  /// 표시할 레시피 데이터
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 영역
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: _RecipeImage(imageName: recipe.imageName),
            ),
          ),

          // 텍스트 영역
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),

                Text(
                  recipe.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 14, color: Colors.grey),
                    Text(
                      " ${recipe.cookTimeMinutes}분  ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Icon(Icons.restaurant, size: 14, color: Colors.grey),
                    Text(
                      " ${recipe.difficulty}",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Firebase Storage에서 레시피 이미지를 비동기로 로드하는 위젯
class _RecipeImage extends StatelessWidget {
  /// Firebase Storage 이미지 파일명
  final String imageName;

  const _RecipeImage({required this.imageName});

  @override
  Widget build(BuildContext context) {
    if (imageName.isEmpty) {
      return Container(
        color: Colors.grey,
        child: const Center(
          child: Icon(Icons.rice_bowl, size: 80, color: Colors.white),
        ),
      );
    }

    final _storageRef = FirebaseStorage.instance.ref().child(
      'recipes/$imageName',
    );

    return FutureBuilder<String>(
      future: _storageRef.getDownloadURL(),
      builder: (context, _snapshot) {
        if (_snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: Icon(
                Icons.rice_bowl,
                size: 50,
                color: Colors.grey.shade400,
              ),
            ),
          );
        }

        if (_snapshot.hasError || !_snapshot.hasData) {
          return Container(
            color: Colors.grey,
            child: const Center(
              child: Icon(Icons.rice_bowl, size: 80, color: Colors.white),
            ),
          );
        }

        final _imageUrl = _snapshot.data!;
        return Image.network(_imageUrl, fit: BoxFit.cover);
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/recipe.dart';

class RecipeCard extends StatelessWidget {
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
                    //Text(" ${recipe.cookTime}  ", style: TextStyle(color: Colors.grey)),
                    Text(" ${recipe.cookTimeMinutes}  ", style: TextStyle(color: Colors.grey)),
                    Icon(Icons.restaurant, size: 14, color: Colors.grey),
                    Text(" ${recipe.difficulty}", style: TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Firebase Storage에서 이미지 불러오는 위젯
class _RecipeImage extends StatelessWidget {
  final String imageName; // 예: "recipe_001.jpg"

  const _RecipeImage({required this.imageName});

  @override
  Widget build(BuildContext context) {
    // imageName이 비어 있으면 기본 플레이스홀더
    if (imageName.isEmpty) {
      return Container(
        color: Colors.grey,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 50, color: Colors.white),
        ),
      );
    }

    // Firebase Storage에서 이미지 URL 가져오기
    final ref = FirebaseStorage.instance.ref().child('recipes/$imageName'); // 파이어 스토리지 경로

    return FutureBuilder<String>(
      future: ref.getDownloadURL(),
      builder: (context, snapshot) {
        // 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        // 에러 또는 데이터 없음
        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            color: Colors.grey,
            child: const Center(
              child: Icon(Icons.error, size: 50, color: Colors.white),
            ),
          );
        }

        // 정상적으로 URL을 받아온 경우
        final url = snapshot.data!;
        return Image.network(
          url,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
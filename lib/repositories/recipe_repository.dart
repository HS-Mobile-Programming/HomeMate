// 레시피 저장소: Firestore recipes 컬렉션에서 레시피 데이터 조회 전담
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class RecipeRepository {
  // Firestore 데이터베이스 인스턴스
  final FirebaseFirestore _firestore;

  RecipeRepository({FirebaseFirestore? db})
    : _firestore = db ?? FirebaseFirestore.instance;

  // Firestore에서 모든 레시피 조회
  Future<List<Recipe>> fetchAllRecipesFromFirestore() async {
    final _snapshot = await _firestore.collection('recipes').get();

    return _snapshot.docs.map((_doc) {
      final _data = _doc.data();
      return Recipe.fromFirestoreDocument(_data, _doc.id);
    }).toList();
  }

  // Firestore에서 특정 ID의 레시피 조회
  Future<Recipe?> fetchRecipeByIdFromFirestore(String _recipeId) async {
    final _doc = await _firestore.collection('recipes').doc(_recipeId).get();

    if (!_doc.exists) return null;

    final _data = _doc.data()!;
    return Recipe.fromFirestoreDocument(_data, _doc.id);
  }
}

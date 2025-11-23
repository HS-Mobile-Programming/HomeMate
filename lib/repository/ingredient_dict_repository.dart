// IngredientDictionaryRepository
// Firestore "ingredients" 컬렉션에서 재료 사전 데이터를 읽어오는 역할입니다.
// AI 추천 로직, 매핑 로직 작업에서 사용을 위한 목적으로 만들었습니다.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_dictionary.dart';

class IngredientDictionaryRepository {
  final FirebaseFirestore _db;

  IngredientDictionaryRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // 전체 재료 사전 가져오기
  Future<List<IngredientDictionary>> fetchAllDictionaries() async {
    final snapshot = await _db.collection('ingredients').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return IngredientDictionary.fromJson(data, doc.id);
    }).toList();
  }

  // 특정 재료(id 기준) 가져오기 (예: id = "간장")
  Future<IngredientDictionary?> fetchById(String id) async {
    final doc = await _db.collection('ingredients').doc(id).get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    return IngredientDictionary.fromJson(data, doc.id);
  }
}

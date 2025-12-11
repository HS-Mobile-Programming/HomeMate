// IngredientDictionaryRepository
// Firestore "ingredients" 컬렉션에서 재료 사전 데이터를 읽어오는 역할입니다.
// AI 추천 로직, 매핑 로직 작업에서 사용을 위한 목적으로 만들었습니다.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_dictionary.dart';
import '../services/local_ingredient_dict_cache.dart';

class IngredientDictionaryRepository {
  final FirebaseFirestore _db;
  final LocalIngredientDictCache _cache = LocalIngredientDictCache();

  IngredientDictionaryRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // 전체 재료 사전 가져오기 (1순위.로컬 2순위.Firestore 동기화)
  Future<List<IngredientDictionary>> fetchAllDictionaries() async {
    List<IngredientDictionary> list = [];

    // 1순위.로컬 -> Hive에서 시도
    try {
      list = _cache.getAll();
    } catch (e, st) {
      list = [];
    }

    final needServerSync =
        list.isEmpty || !_cache.isSyncedToday();

    // 2순위.Firestore 동기화 -> 로컬X or 당일 동기화X -> Firestore에서 새로 가져오기 시도
    if (needServerSync) {
      try {
        final snapshot = await _db.collection('ingredients').get();
        final fetched = snapshot.docs
            .map((doc) => IngredientDictionary.fromJson(doc.data(), doc.id))
            .toList();

        await _cache.saveAll(fetched);
        list = fetched;
      } catch (e, st) {
      }
    }

    return list;
  }

  // id 기준의 재료 가져오기
  Future<IngredientDictionary?> fetchById(String id) async {
    // 1순위.로컬 캐시 검색
    try {
      final all = _cache.getAll();
      final local = all.firstWhere(
            (e) => e.id == id,
        orElse: () => IngredientDictionary(id: '', name: '', rawVariants: []),
      );
      if (local.id.isNotEmpty) {
        return local;
      }
    } catch (_) {
      // 무시한 후 서버 쪽으로 진행
    }

    // 2순위.Firestore 직접 조회(온라인 상태에서 가능)
    try {
      final doc = await _db.collection('ingredients').doc(id).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return IngredientDictionary.fromJson(data, doc.id);
    } catch (e, st) {
      return null;
    }
  }
}

// 재료 사전 저장소: Firestore ingredients 컬렉션에서 표준 재료명 사전 데이터 조회 및 로컬 캐싱
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/ingredient_dictionary.dart';
import '../services/local_ingredient_dict_cache.dart';

class IngredientDictionaryRepository {
  // Firestore 데이터베이스 인스턴스
  final FirebaseFirestore _firestore;
  // 로컬 재료 사전 캐시
  final LocalIngredientDictCache _localCache = LocalIngredientDictCache();

  IngredientDictionaryRepository({FirebaseFirestore? db})
    : _firestore = db ?? FirebaseFirestore.instance;

  // 모든 재료 사전 조회 (로컬 캐시 우선, 필요 시 Firestore 동기화)
  Future<List<IngredientDictionary>> fetchAllDictionariesFromCache() async {
    List<IngredientDictionary> _dictionaries = [];

    try {
      _dictionaries = _localCache.getAll();
    }
    catch (e) {
      _dictionaries = [];
    }

    final _needSync = _dictionaries.isEmpty || !_localCache.isSyncedToday();

    if (_needSync) {
      try {
        final _snapshot = await _firestore.collection('ingredients').get();
        final _fetched = _snapshot.docs
            .map(
              (_doc) => IngredientDictionary.fromFirestoreDocument(
                _doc.data(),
                _doc.id,
              ),
            ).toList();
        await _localCache.saveAll(_fetched);
        _dictionaries = _fetched;
      }
      catch (e) {
        debugPrint('Firestore 동기화 오류: $e');
      }
    }
    return _dictionaries;
  }

  // 특정 ID의 재료 사전 조회 (로컬 캐시 우선, 실패 시 Firestore 조회)
  Future<IngredientDictionary?> fetchDictionaryByIdFromCache(String _dictionaryId,)
  async {
    try {
      final _all = _localCache.getAll();
      final _local = _all.firstWhere(
        (_dict) => _dict.id == _dictionaryId,
        orElse: () => IngredientDictionary(id: '', name: '', rawVariants: []),
      );
      if (_local.id.isNotEmpty) {
        return _local;
      }
    }
    catch (e) {
      debugPrint('[IngredientDictionaryRepository] 로컬 캐시 조회 오류: $e');
    }

    try {
      final _doc = await _firestore
          .collection('ingredients').doc(_dictionaryId).get();
      if (!_doc.exists) {
        return null;
      }
      final _data = _doc.data()!;
      return IngredientDictionary.fromFirestoreDocument(_data, _doc.id);
    }
    catch (e) {
      return null;
    }
  }
}
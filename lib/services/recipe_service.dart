// 레시피 데이터 관리 및 캐싱 서비스: Firestore 레시피 컬렉션 조회, 로컬·메모리 캐시 동기화, 즐겨찾기 상태 관리
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/recipe.dart';
import '../services/favorites_service.dart';
import 'local_recipe_cache.dart';

// 레시피 정렬 모드
enum RecipeSortMode { nameAsc, nameDesc }

class RecipeService {
  // Firestore 데이터베이스 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // 즐겨찾기 관리 서비스
  final FavoritesService _favoritesService = FavoritesService();
  // 로컬 레시피 캐시
  final LocalRecipeCache _localCache = LocalRecipeCache();

  // 앱 실행 중 메모리 캐시
  List<Recipe>? _cachedRecipes;

  // 로컬 캐시 또는 Firestore에서 모든 레시피를 로드 후 즐겨찾기 정보 병합
  Future<List<Recipe>> _loadAllRecipesFromFirestoreAndCache() async {
    if (_cachedRecipes != null) {
      return _cachedRecipes!;
    }

    List<Recipe> _recipes = [];

    try {
      _recipes = _localCache.getRecipes();
    } catch (e) {
      debugPrint('[RecipeService] 로컬 캐시 로드 오류: $e');
      _recipes = [];
    }

    final _needServerSync = _recipes.isEmpty || !_localCache.isSyncedToday();

    if (_needServerSync) {
      try {
        final _snapshot = await _firestore.collection('recipes').get();
        final _fetched = _snapshot.docs
            .map((_doc) => Recipe.fromJson(_doc.data(), _doc.id))
            .toList();
        await _localCache.saveRecipes(_fetched);
        _recipes = _fetched;
      }
      catch (e) {
        debugPrint('[RecipeService] Firestore 로드 오류: $e');
      }
    }

    try {
      final _favoriteIds = await _favoritesService.getFavoriteList();
      final _favSet = _favoriteIds.toSet();
      for (final _recipe in _recipes) {
        _recipe.isFavorite = _favSet.contains(_recipe.id);
      }
    }
    catch (e) {
      debugPrint('[RecipeService] 즐겨찾기 로드 오류: $e');
      for (final _recipe in _recipes) {
        _recipe.isFavorite = false;
      }
    }
    _cachedRecipes = _recipes;
    return _cachedRecipes!;
  }

  // 검색어 기준 레시피 조회 (이름 또는 재료명 매칭)
  Future<List<Recipe>> getRecipes({String? keyword}) async {
    final _recipes = await _loadAllRecipesFromFirestoreAndCache();

    if (keyword == null || keyword.isEmpty) {
      return List<Recipe>.from(_recipes);
    }

    final _keywordLower = keyword.toLowerCase();
    return _recipes.where((_recipe) {
      final _nameMatch = _recipe.name.toLowerCase().contains(_keywordLower);
      final _ingredientMatch = _recipe.ingredients.any(
        (_ingredient) =>
            _ingredient.ingredientName.toLowerCase().contains(_keywordLower),
      );
      return _nameMatch || _ingredientMatch;
    }).toList();
  }

  // 레시피 리스트 정렬 (즐겨찾기 우선 후 이름 정렬)
  List<Recipe> sortRecipes(List<Recipe> _recipes, RecipeSortMode _mode) {
    final _favorites = _recipes.where((_r) => _r.isFavorite).toList();
    final _normal = _recipes.where((_r) => !_r.isFavorite).toList();

    switch (_mode) {
      case RecipeSortMode.nameAsc:
        _favorites.sort((_a, _b) => _a.name.compareTo(_b.name));
        _normal.sort((_a, _b) => _a.name.compareTo(_b.name));
        break;
      case RecipeSortMode.nameDesc:
        _favorites.sort((_a, _b) => _b.name.compareTo(_a.name));
        _normal.sort((_a, _b) => _b.name.compareTo(_a.name));
        break;
    }
    return [..._favorites, ..._normal];
  }

  // 즐겨찾기된 레시피만 조회
  Future<List<Recipe>> getFavoriteRecipes() async {
    final _recipes = await _loadAllRecipesFromFirestoreAndCache();
    return _recipes.where((_r) => _r.isFavorite).toList();
  }

  // 단일 레시피의 즐겨찾기 상태 토글
  Future<void> toggleFavorite(Recipe _recipe) async {
    if (_recipe.isFavorite) {
      await _favoritesService.removeFavorite(_recipe.id);
    }
    else {
      await _favoritesService.addFavorite(_recipe.id);
    }

    _recipe.isFavorite = !_recipe.isFavorite;

    if (_cachedRecipes != null) {
      final _cachedRecipe = _cachedRecipes!.firstWhere(
        (_r) => _r.id == _recipe.id,
        orElse: () => _recipe,
      );
      if (_cachedRecipe.id == _recipe.id) {
        _cachedRecipe.isFavorite = _recipe.isFavorite;
      }
    }
    _invalidateCache();
  }

  // 메모리 캐시 무효화
  void _invalidateCache() {
    _cachedRecipes = null;
  }

  // 랜덤하게 지정된 개수의 레시피 추출
  Future<List<Recipe>> getRandomRecipes(int _num) async {
    final _all = await getRecipes();
    final _random = Random();
    final List<Recipe> _selected = [];
    final List<Recipe> _temp = List.from(_all);

    if (_all.length <= _num) {
      return _all;
    }

    for (int _i = 0; _i < _num; _i++) {
      final _randomIndex = _random.nextInt(_temp.length);
      _selected.add(_temp[_randomIndex]);
      _temp.removeAt(_randomIndex);
    }

    return _selected;
  }
}
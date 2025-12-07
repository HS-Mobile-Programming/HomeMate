import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';
import '../services/favorites_service.dart';
import 'local_recipe_cache.dart';
import 'package:flutter/cupertino.dart';

// 레시피 정렬 모드
enum RecipeSortMode { nameAsc, nameDesc }

class RecipeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FavoritesService _favoritesService = FavoritesService();
  final LocalRecipeCache _localCache = LocalRecipeCache();

  // 앱 실행 중 메모리 캐시
  List<Recipe>? _cachedRecipes;

  Future<List<Recipe>> _loadAllRecipes() async {
    // 이미 메모리 캐시에 있으면 그대로 사용
    if (_cachedRecipes != null) {
      return _cachedRecipes!;
    }

    List<Recipe> recipes = [];

    // 로컬 시도
    try {
      recipes = _localCache.getRecipes();
    } catch (e, st) {
      debugPrint('[RecipeService] _loadAllRecipes local cache error: $e\n$st');
      recipes = [];
    }

    // 서버에서 새로 가져올지 여부(판단로컬이 비어 있거나 or 오늘 동기화한 적이 없으면 시도)
    final bool needServerSync =
        recipes.isEmpty || !_localCache.isSyncedToday();

    if (needServerSync) {
      try {
        // timeout 제거 : 온라인 정상 동작 우선
        final snapshot = await _db.collection('recipes').get();

        final fetched = snapshot.docs
            .map((doc) => Recipe.fromJson(doc.data(), doc.id))
            .toList();

        await _localCache.saveRecipes(fetched);
        recipes = fetched;
      } catch (e, st) {
        debugPrint('[RecipeService] _loadAllRecipes Firestore error: $e\n$st');
        // Firestore 실패 -> (로컬에 남아있는 recipes or 사용로컬도 비어 있으면 그대로 빈 리스트)
      }
    }

    // 즐겨찾기 정보 반영
    try {
      final favoriteIds = await _favoritesService.getFavoriteList();
      final favSet = favoriteIds.toSet();

      for (final recipe in recipes) {
        recipe.isFavorite = favSet.contains(recipe.id);
      }
    } catch (e, st) {
      debugPrint('[RecipeService] favorites load error: $e\n$st');
      for (final recipe in recipes) {
        recipe.isFavorite = false;
      }
    }

    _cachedRecipes = recipes;
    return _cachedRecipes!;
  }

  // 레시피 검색/조회 로직
  Future<List<Recipe>> getRecipes({String? keyword}) async {
    final recipes = await _loadAllRecipes();

    // 검색어 없으면 전체 반환
    if (keyword == null || keyword.isEmpty) {
      // 원본 캐시 보호를 위해 복사본 반환
      return List<Recipe>.from(recipes);
    }

    final keywordLower = keyword.toLowerCase();

    // 이름 또는 재료명(ingredientName)에 키워드가 포함되는지 검사
    return recipes.where((recipe) {
      final nameMatch = recipe.name.toLowerCase().contains(keywordLower);

      final ingredientMatch = recipe.ingredients.any(
            (ingredient) =>
            ingredient.ingredientName.toLowerCase().contains(keywordLower),
      );

      return nameMatch || ingredientMatch;
    }).toList();
  }

  // 레시피 정렬 로직
  List<Recipe> sortRecipes(List<Recipe> recipes, RecipeSortMode mode) {
    List<Recipe> favorites = recipes.where((r) => r.isFavorite).toList();
    List<Recipe> normal = recipes.where((r) => !r.isFavorite).toList();

    switch (mode) {
      case RecipeSortMode.nameAsc:
        favorites.sort((a, b) => a.name.compareTo(b.name));
        normal.sort((a, b) => a.name.compareTo(b.name));
        break;
      case RecipeSortMode.nameDesc:
        favorites.sort((a, b) => b.name.compareTo(a.name));
        normal.sort((a, b) => b.name.compareTo(a.name));
        break;
    }
    return favorites + normal;
  }

  // 즐겨찾기 조회 로직
  Future<List<Recipe>> getFavoriteRecipes() async {
    final recipes = await _loadAllRecipes();
    return recipes.where((r) => r.isFavorite).toList();
  }

  // 즐겨찾기 상태 변경 로직
  Future<void> toggleFavorite(Recipe recipe) async {
    // 현재 상태 기준으로 분기
    if (recipe.isFavorite) {
      // 이미 즐겨찾기인 경우 → 해제
      await _favoritesService.removeFavorite(recipe.id);
    } else {
      // 즐겨찾기가 아닌 경우 → 추가
      await _favoritesService.addFavorite(recipe.id);
    }

    // 로컬 객체도 함께 업데이트 (UI 즉각 반영)
    recipe.isFavorite = !recipe.isFavorite;

    // 캐시에 있는 동일한 레시피 객체도 업데이트
    if (_cachedRecipes != null) {
      final cachedRecipe = _cachedRecipes!.firstWhere(
            (r) => r.id == recipe.id,
        orElse: () => recipe,
      );
      if (cachedRecipe.id == recipe.id) {
        cachedRecipe.isFavorite = recipe.isFavorite;
      }
    }

    // 캐시 무효화: 다음 로드 시 최신 즐겨찾기 상태를 반영하기 위해
    _invalidateCache();
  }

  // 캐시 무효화 메서드
  void _invalidateCache() {
    _cachedRecipes = null;
  }

  // 레시피를 랜덤으로 추출하는 로직
  Future<List<Recipe>> getRandomRecipes(int num) async {
    final all = await getRecipes();

    if (all.length <= num) {
      return all;
    }

    final random = Random();
    final List<Recipe> select = [];
    final List<Recipe> temp = List.from(all);

    for (int i = 0; i < num; i++) {
      int randomIndex = random.nextInt(temp.length);
      select.add(temp[randomIndex]);
      temp.removeAt(randomIndex);
    }

    return select;
  }
}
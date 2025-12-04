import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';
import '../services/favorites_service.dart';

// 레시피 정렬 모드
enum RecipeSortMode { nameAsc, nameDesc }

class RecipeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FavoritesService _favoritesService = FavoritesService();

  // Firestore에서 불러온 레시피들을 앱 실행 중 캐시해두는 리스트
  List<Recipe>? _cachedRecipes;

  Future<List<Recipe>> _loadAllRecipes() async {
    // 내부용 : Firestore에서 전체 레시피 불러오고, 한 번만 캐싱합니다.
    if (_cachedRecipes != null) {
      return _cachedRecipes!;
    }

    // 모든 레시피를 불러옵니다.
    final snapshot = await _db.collection('recipes').get();
    final recipes = snapshot.docs
        .map((doc) => Recipe.fromJson(doc.data(), doc.id))
        .toList();

    // 로그인 유저의 즐겨찾기 목록을 가져옵니다.
    final favoriteIds = await _favoritesService.getFavoriteList();
    final favSet = favoriteIds.toSet(); // contains() 빠르게 하기 위해 Set으로

    // 레시피 리스트에 즐겨찾기 여부를 반영합니다.
    for (final recipe in recipes) {
      recipe.isFavorite = favSet.contains(recipe.id);
    }

    _cachedRecipes = recipes;
    return _cachedRecipes!;
  }

  // 1. 레시피 검색/조회 로직
  Future<List<Recipe>> getRecipes({String? keyword}) async {
    // Firestore에서 전체 레시피 가져오기
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

      final ingredientMatch = recipe.ingredients.any((ingredient) =>
          ingredient.ingredientName.toLowerCase().contains(keywordLower));

      return nameMatch || ingredientMatch;
    }).toList();
  }


  // 2. 레시피 정렬 로직
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

  // 3. 즐겨찾기 조회 로직
  Future<List<Recipe>> getFavoriteRecipes() async {
    final recipes = await _loadAllRecipes();
    return recipes.where((r) => r.isFavorite).toList();
  }

  // 4. 즐겨찾기 상태 변경 로직
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
}

import '../models/recipe.dart';

// 임시 데이터 - DB 완성후 삭제할 것
List<Recipe> allRecipes = [
  Recipe(
    id: 'recipe_001',
    name: '웨지감자',
    description: '맥주 안주로 딱 좋은 짭짤한 웨지감자입니다.',
    difficulty: '초급',
    cookTimeMinutes: 30,
    // ingredients는 List<RecipeIngredient> 타입이어야 합니다.
    ingredients: [
      RecipeIngredient(rawText: '감자 2개', ingredientName: '감자'),
      RecipeIngredient(rawText: '버터 1큰술', ingredientName: '버터'),
      RecipeIngredient(rawText: '소금 약간', ingredientName: '소금'),
      RecipeIngredient(rawText: '파슬리 가루', ingredientName: '파슬리'),
    ],
    // steps는 List<String> 타입이어야 합니다.
    steps: [
      '1. 감자를 깨끗이 씻어 웨지 모양으로 썬다.',
      '2. 물기를 제거하고 버터와 섞는다.',
      '3. 에어프라이어 180도에서 20분 굽는다.'
    ],
    // tasteTags는 List<String> 타입이어야 합니다.
    tasteTags: ['짭짤한', '고소한', '바삭한'],
    imageName: 'recipe_001',
    isFavorite: true,
  ),
  Recipe(
    id: 'recipe_002',
    name: '김치찌개',
    description: '한국인의 소울푸드',
    difficulty: '중급',
    cookTimeMinutes: 40,
    ingredients: [
      RecipeIngredient(rawText: '김치 1포기', ingredientName: '김치'),
      RecipeIngredient(rawText: '돼지고기 200g', ingredientName: '돼지고기'),
      RecipeIngredient(rawText: '두부 1모', ingredientName: '두부'),
      RecipeIngredient(rawText: '대파 1개', ingredientName: '대파'),
    ],
    steps: [
      '1. 김치와 고기를 볶는다.',
      '2. 물을 넣고 끓인다.',
      '3. 두부와 대파를 넣고 마무리.'
    ],
    tasteTags: ['매콤한', '얼큰한', '한식'],
    imageName: 'recipe_002',
  ),
];

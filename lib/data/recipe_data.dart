import '../models/recipe.dart';

// 임시 데이터 - DB 완성후 삭제할 것
List<Recipe> allRecipes = [
  Recipe(
    id: 'recipe_001',
    name: '웨지감자',
    description: '맥주 안주로 딱 좋은 짭짤한 웨지감자입니다.',
    difficulty: '초급',
    cookTimeMinutes: 30,
    ingredients: '감자 2개, 버터 1큰술, 소금 약간, 파슬리 가루',
    steps: '1. 감자를 깨끗이 씻어 웨지 모양으로 썬다.\n2. 물기를 제거하고 버터와 섞는다.\n3. 에어프라이어 180도에서 20분 굽는다.',
    tasteTags: '짭짤한, 고소한, 바삭한',
    imageName: 'recipe_001',
    isFavorite: true,
  ),
  Recipe(
    id: 'recipe_002',
    name: '김치찌개',
    description: '한국인의 소울푸드',
    difficulty: '중급',
    cookTimeMinutes: '40분',
    ingredients: '김치 1포기, 돼지고기 200g, 두부 1모, 대파 1개',
    steps: '1. 김치와 고기를 볶는다.\n2. 물을 넣고 끓인다.\n3. 두부와 대파를 넣고 마무리.',
    tasteTags: '매콤한, 얼큰한, 한식',
    imageName: 'recipe_002',
  ),
];
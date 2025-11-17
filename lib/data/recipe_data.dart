
import '../models/recipe.dart';

//앱 전체에서 공유할 레시피 목록
List<Recipe> allRecipes = [
  Recipe(
      title: "김치찌개",
      description: "매콤하고 맛있는 김치찌개",
      imageUrl: "",
      difficulty: "쉬움",
      ingredients: ["김치 1포기", "돼지고기 200g", "두부 1모"],
      steps: ["김치를 볶는다.", "물을 붓고 끓인다.", "고기와 두부를 넣는다."],
      isFavorite: true // (테스트용으로 하나 켜놓기)
  ),
  Recipe(
      title: "된장찌개",
      description: "구수한 된장찌개",
      imageUrl: "",
      difficulty: "보통",
      ingredients: ["된장 2큰술", "애호박 1/2개", "두부 1모", "양파 1/2개"],
      steps: ["멸치 육수를 낸다.", "된장을 푼다.", "야채를 넣고 끓인다."]
  ),
  Recipe(
      title: "파스타",
      description: "토마토 파스타",
      imageUrl: "",
      difficulty: "쉬움",
      ingredients: ["파스타면 1인분", "토마토 소스 200g", "마늘 5쪽"],
      steps: ["면을 8분간 삶는다.", "마늘을 볶다가 소스를 넣는다.", "면을 넣고 섞는다."]
  ),
  Recipe(
    title: "계란찜",
    description: "부드럽고 촉촉한 계란찜",
    imageUrl: "",
    difficulty: "쉬움",
  ),
];
import '../models/ingredient.dart';

// 재료 목록의 '원본' 데이터. 앱 전체에서 공유됩니다.
List<Ingredient> allIngredients = [
  Ingredient(id: '1', name: '계란', quantity: '10', expiryTime: '2025.11.20'),
  Ingredient(id: '2', name: '우유', quantity: '1', expiryTime: '2025.11.25'),
  Ingredient(id: '3', name: '사과', quantity: '5', expiryTime: '2025.11.18'),
];
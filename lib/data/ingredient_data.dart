import '../models/ingredient.dart';

// 재료 목록의 '원본' 데이터. 앱 전체에서 공유됩니다.
List<Ingredient> allIngredients = [
  Ingredient(id: '1', name: '계란', quantity: 10, expiryTime: '2025.11.23'),
  Ingredient(id: '2', name: '우유', quantity: 1, expiryTime: '2025.12.05'),
  Ingredient(id: '3', name: '사과', quantity: 5, expiryTime: '2025.12.08'),
  Ingredient(id: '4', name: '돼지고기', quantity: 3, expiryTime: '2025.11.30'),
  Ingredient(id: '5', name: '김치', quantity: 2, expiryTime: '2025.11.27'),
  Ingredient(id: '6', name: '대파', quantity: 4, expiryTime: '2025.12.20'),
];
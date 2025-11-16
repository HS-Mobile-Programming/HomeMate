import 'package:table_calendar/table_calendar.dart';
import '../models/ingredient.dart';
import '../data/ingredient_data.dart'; // 가짜 데이터 원본

// 재료 정렬 모드 (UI 파일과 공유해야 하므로 여기로 이동)
enum SortMode { nameAsc, nameDesc, expiryAsc }

class RefrigeratorService {

  // 1. 모든 재료 가져오기
  List<Ingredient> getAllIngredients() {
    // (나중에 여기를 Firebase에서 데이터 불러오는 코드로 변경)
    return allIngredients;
  }

  // 2. 재료 추가하기
  void addIngredient({
    required String name,
    required String quantity,
    required String expiryTime,
  }) {
    final newIngredient = Ingredient(
      id: DateTime.now().toString(), // 임시 ID
      name: name,
      quantity: quantity,
      expiryTime: expiryTime,
    );
    // (나중에 여기를 Firebase에 데이터 전송하는 코드로 변경)
    allIngredients.add(newIngredient);
  }

  // 3. 재료 수정하기
  void updateIngredient(String id, {
    required String name,
    required String quantity,
    required String expiryTime,
  }) {
    try {
      final index = allIngredients.indexWhere((item) => item.id == id);
      final updatedIngredient = Ingredient(
        id: id,
        name: name,
        quantity: quantity,
        expiryTime: expiryTime,
      );
      // (나중에 여기를 Firebase 데이터 업데이트 코드로 변경)
      allIngredients[index] = updatedIngredient;
    } catch (e) {
      print("재료 수정 실패: $e");
    }
  }

  // 4. 재료 삭제하기
  void deleteIngredient(String id) {
    // (나중에 여기를 Firebase 데이터 삭제 코드로 변경)
    allIngredients.removeWhere((item) => item.id == id);
  }

  // 5. 유통기한 날짜 파싱 (로직)
  DateTime? parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr.replaceAll('.', '-'));
    } catch (e) {
      return null;
    }
  }

  // 6. 캘린더 마커용 이벤트 가져오기 (로직)
  List<Ingredient> getEventsForDay(DateTime day) {
    return allIngredients.where((ingredient) {
      DateTime? expiryDate = parseDate(ingredient.expiryTime);
      return expiryDate != null && isSameDay(expiryDate, day);
    }).toList();
  }

  // 7. 리스트 정렬하기 (로직)
  List<Ingredient> sortList(List<Ingredient> list, SortMode mode) {
    switch (mode) {
      case SortMode.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortMode.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortMode.expiryAsc:
        list.sort((a, b) {
          DateTime? dateA = parseDate(a.expiryTime);
          DateTime? dateB = parseDate(b.expiryTime);
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateA.compareTo(dateB);
        });
        break;
    }
    return list;
  }
}
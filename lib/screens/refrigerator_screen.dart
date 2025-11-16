import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../widgets/ingredient_item.dart';

// [추가] 1. 정렬 상태를 관리하기 위한 enum
enum SortMode {
  nameAsc,    // 이름 오름차순
  nameDesc,   // 이름 내림차순
  expiryAsc,  // 유통기한 임박순
}

class RefrigeratorScreen extends StatefulWidget {
  const RefrigeratorScreen({super.key});

  @override
  State<RefrigeratorScreen> createState() => _RefrigeratorScreenState();
}

class _RefrigeratorScreenState extends State<RefrigeratorScreen> {
  DateTime _selectedDay = DateTime.now();
  SortMode _sortMode = SortMode.nameAsc; // [수정] 현재 정렬 상태 변수

  List<Ingredient> ingredients = [
    Ingredient(id: '1', name: '계란', expiryTime: '2025.11.20'),
    Ingredient(id: '2', name: '우유', expiryTime: '2025.11.25'),
    Ingredient(id: '3', name: '사과', expiryTime: '2025.11.18'),
    Ingredient(id: '4', name: '김치', expiryTime: '미정'),
  ];

  // [추가] 2. 유통기한 문자열을 날짜 객체로 변환 (정렬용)
  // "미정"이나 잘못된 형식은 null 반환
  DateTime? _parseDate(String dateStr) {
    try {
      // "2025.11.20" -> "2025-11-20"
      return DateTime.parse(dateStr.replaceAll('.', '-'));
    } catch (e) {
      return null; // "미정" 등은 null 처리
    }
  }

  // [수정] 3. 정렬 로직 (3가지 모드)
  void _sortList() {
    setState(() {
      switch (_sortMode) {
        case SortMode.nameAsc:
          ingredients.sort((a, b) => a.name.compareTo(b.name));
          break;
        case SortMode.nameDesc:
          ingredients.sort((a, b) => b.name.compareTo(a.name));
          break;
        case SortMode.expiryAsc:
          ingredients.sort((a, b) {
            DateTime? dateA = _parseDate(a.expiryTime);
            DateTime? dateB = _parseDate(b.expiryTime);

            // "미정"(null)은 항상 뒤로
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;

            // 날짜가 빠른 순서 (임박순)
            return dateA.compareTo(dateB);
          });
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _sortList(); // 시작 시 정렬
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        // (다이얼로그 코드는 기존과 동일, 생략)
        return AlertDialog(
          backgroundColor: Colors.white,
          titlePadding: EdgeInsets.zero,
          title: Container(
            color: Colors.blue[200],
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(child: Text("재료 등록", style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("이름", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "텍스트를 입력하세요.",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("수량", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "01",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("유통기한", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    hintText: "YYYY.MM.DD 또는 미정", // 힌트 수정
                    filled: true,
                    fillColor: Colors.blue[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소", style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () {
                if (nameController.text.isEmpty) return;
                setState(() {
                  ingredients.add(Ingredient(
                    id: DateTime.now().toString(),
                    name: nameController.text,
                    expiryTime: dateController.text.isEmpty ? "미정" : dateController.text,
                  ));
                  _sortList(); // [수정] 재료 추가 후 다시 정렬
                });
                Navigator.pop(context);
              },
              child: const Text("추가", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // [추가] 4. 정렬 버튼 아이콘과 텍스트를 현재 모드에 맞게 반환
  Widget _buildSortButtonChild() {
    IconData icon;
    String label;

    switch (_sortMode) {
      case SortMode.nameAsc:
        icon = Icons.swap_vert;
        label = "이름 (가-힣)";
        break;
      case SortMode.nameDesc:
        icon = Icons.swap_vert;
        label = "이름 (힣-가)";
        break;
      case SortMode.expiryAsc:
        icon = Icons.calendar_today;
        label = "유통기한 임박순";
        break;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 구글 머터리얼 달력 (기존 코드)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
                ],
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDay,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                onDateChanged: (newDate) {
                  setState(() { _selectedDay = newDate; });
                },
              ),
            ),
            const SizedBox(height: 24),

            // 재료 목록 타이틀 및 [수정] 정렬 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "내 재료 목록",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // [수정] 5. 버튼 클릭 시 3가지 모드 순환
                      setState(() {
                        if (_sortMode == SortMode.nameAsc) {
                          _sortMode = SortMode.nameDesc;
                        } else if (_sortMode == SortMode.nameDesc) {
                          _sortMode = SortMode.expiryAsc;
                        } else {
                          _sortMode = SortMode.nameAsc;
                        }
                        _sortList(); // 리스트 다시 정렬
                      });
                    },
                    child: _buildSortButtonChild(), // 버튼 내용 변경
                  ),
                ],
              ),
            ),
            const Divider(height: 10),

            // 재료 리스트
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(ingredients[index].id),
                  onDismissed: (dir) {
                    setState(() { ingredients.removeAt(index); });
                  },
                  background: Container(color: Colors.red),
                  child: IngredientItem(
                    ingredient: ingredients[index],
                    onEdit: () {
                      print("수정 버튼 눌림 (모양만 있음)");
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFE0E0FF),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
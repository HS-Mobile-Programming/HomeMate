import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../widgets/ingredient_item.dart';

class RefrigeratorScreen extends StatefulWidget {
  const RefrigeratorScreen({super.key});

  @override
  State<RefrigeratorScreen> createState() => _RefrigeratorScreenState();
}

class _RefrigeratorScreenState extends State<RefrigeratorScreen> {
  DateTime _selectedDay = DateTime.now();

  List<Ingredient> ingredients = [
    Ingredient(id: '1', name: '계란', expiryTime: '2025.11.20'),
    Ingredient(id: '2', name: '우유', expiryTime: '2025.11.25'),
  ];

  // (디자인만 보는 버전이라 수정 로직 없이 '추가' 기능만 있는 상태)
  void _showAddDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
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
                    hintText: "YYYY-MM-DD",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 구글 머터리얼 달력
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
                    // [핵심] 빈 함수를 넣어서 버튼 모양만 보여줌 (기능 X)
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
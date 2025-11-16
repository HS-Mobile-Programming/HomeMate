import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/ingredient.dart';
import '../widgets/ingredient_item.dart';
// [추가] 1. 서비스와 정렬 모드를 import
import '../services/refrigerator_service.dart';

class RefrigeratorScreen extends StatefulWidget {
  const RefrigeratorScreen({super.key});
  @override
  State<RefrigeratorScreen> createState() => _RefrigeratorScreenState();
}

class _RefrigeratorScreenState extends State<RefrigeratorScreen> {
  // [추가] 2. 서비스(로직) 객체 생성
  final RefrigeratorService _service = RefrigeratorService();

  // [유지] 3. UI 상태 변수들
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  SortMode _sortMode = SortMode.nameAsc;

  // [제거] 4. 데이터 리스트 (allIngredients) 삭제
  // List<Ingredient> allIngredients = [...]

  // [유지] 5. 화면에 보여질 리스트
  List<Ingredient> filteredIngredients = [];

  // [제거] 6. 모든 로직 함수 삭제
  // _parseDate(), _getEventsForDay(), _sortList() (일부 로직 제외)

  @override
  void initState() {
    super.initState();
    _refreshList(); // [수정] 7. 새로고침 함수 호출
  }

  // [추가] 8. 데이터를 서비스에서 다시 불러오는 '새로고침' 함수
  void _refreshList() {
    setState(() {
      List<Ingredient> allData = _service.getAllIngredients();
      if (_selectedDay == null) {
        // 전체 보기
        filteredIngredients = allData;
      } else {
        // 날짜 필터링
        filteredIngredients = _service.getEventsForDay(_selectedDay!);
      }
      // 정렬
      filteredIngredients = _service.sortList(filteredIngredients, _sortMode);
    });
  }

  // [유지] 9. UI 관련 헬퍼 함수
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // [수정] 10. 다이얼로그 (UI)
  void _showIngredientDialog({Ingredient? ingredient, int? index}) {
    final isEditMode = ingredient != null;

    final nameController = TextEditingController(text: ingredient?.name ?? "");
    final quantityController = TextEditingController(text: ingredient?.quantity ?? "");

    String year = '', month = '', day = '';
    if (isEditMode) {
      DateTime? date = _service.parseDate(ingredient!.expiryTime); // 서비스 함수 호출
      if (date != null) {
        year = date.year.toString();
        month = date.month.toString();
        day = date.day.toString();
      }
    }
    final yearController = TextEditingController(text: year);
    final monthController = TextEditingController(text: month);
    final dayController = TextEditingController(text: day);

    showDialog(
      context: context,
      builder: (context) {

        Widget buildDateTextField(TextEditingController controller, String hint, int maxLength) {
          // (내부 UI 코드는 동일)
          return TextField(
            controller: controller,
            maxLength: maxLength,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: hint, counterText: '', filled: true,
              fillColor: Colors.blue[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          );
        }

        return AlertDialog(
          // (다이얼로그 UI 코드는 동일)
          backgroundColor: Colors.white,
          titlePadding: EdgeInsets.zero,
          title: Container(
            color: Colors.blue[200],
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                isEditMode ? "재료 수정" : "재료 등록",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("이름", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(controller: nameController, /* ... */),
                const SizedBox(height: 16),
                const Text("수량", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(controller: quantityController, /* ... */),
                const SizedBox(height: 16),
                const Text("유통기한", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(flex: 2, child: buildDateTextField(yearController, "YYYY", 4)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text(".")),
                    Expanded(flex: 1, child: buildDateTextField(monthController, "MM", 2)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text(".")),
                    Expanded(flex: 1, child: buildDateTextField(dayController, "DD", 2)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                // (유효성 검사 로직은 동일)
                final name = nameController.text.trim();
                final quantityStr = quantityController.text.trim();
                final yearStr = yearController.text.trim();
                final monthStr = monthController.text.trim();
                final dayStr = dayController.text.trim();
                if (name.isEmpty) { _showErrorSnackBar("이름을 입력해주세요."); return; }
                int quantity = int.tryParse(quantityStr) ?? 0;
                if (quantity <= 0) { _showErrorSnackBar("수량을 1 이상 입력해주세요."); return; }
                String expiryDate;
                if (yearStr.isEmpty || monthStr.isEmpty || dayStr.isEmpty) {
                  _showErrorSnackBar("유통기한(연/월/일)을 모두 입력해주세요."); return; }
                try {
                  int y = int.parse(yearStr); int m = int.parse(monthStr); int d = int.parse(dayStr);
                  DateTime date = DateTime(y, m, d);
                  if (date.year != y || date.month != m || date.day != d) { throw FormatException("유효하지 않은 날짜입니다."); }
                  DateTime today = DateTime.now();
                  DateTime todayOnly = DateTime(today.year, today.month, today.day);
                  if (date.isBefore(todayOnly)) { _showErrorSnackBar("유통기한이 오늘보다 빠를 수 없습니다."); return; }
                  expiryDate = DateFormat('yyyy.MM.dd').format(date);
                } catch (e) {
                  _showErrorSnackBar("유효하지 않은 날짜 형식입니다."); return;
                }

                // [수정] 11. 로직 대신 서비스 호출
                if (isEditMode) {
                  _service.updateIngredient(ingredient!.id,
                    name: name,
                    quantity: quantity.toString(),
                    expiryTime: expiryDate,
                  );
                } else {
                  _service.addIngredient(
                    name: name,
                    quantity: quantity.toString(),
                    expiryTime: expiryDate,
                  );
                }

                _refreshList(); // 12. 서비스 호출 후 화면 갱신
                Navigator.pop(context);
              },
              child: Text(
                isEditMode ? "수정" : "추가",
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // [유지] 13. 정렬 버튼 UI
  Widget _buildSortButtonChild() {
    IconData icon = Icons.swap_vert;
    String label;
    switch (_sortMode) {
      case SortMode.nameAsc: label = "이름 (가-힣)"; break;
      case SortMode.nameDesc: label = "이름 (힣-가)"; break;
      case SortMode.expiryAsc: label = "유통기한 임박순"; break;
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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TableCalendar(
                locale: 'en_US',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                eventLoader: _service.getEventsForDay, // [수정] 14. 서비스 함수 호출
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    if (isSameDay(_selectedDay, selectedDay)) {
                      _selectedDay = null;
                      _focusedDay = focusedDay;
                    } else {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    }
                    _refreshList(); // [수정] 15. 날짜 선택 시 갱신
                  });
                },
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarStyle: CalendarStyle(
                  markerDecoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.green.shade300, shape: BoxShape.circle),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, color: Colors.green, size: 20),
                    label: const Text(
                      "추가",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onPressed: () => _showIngredientDialog(), // UI 함수 호출
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.green, width: 1),
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: _selectedDay != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDay = null;
                          _refreshList(); // [수정] 16. 갱신
                        });
                      },
                      child: const Text("X 전체 보기"),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_sortMode == SortMode.nameAsc) _sortMode = SortMode.nameDesc;
                        else if (_sortMode == SortMode.nameDesc) _sortMode = SortMode.expiryAsc;
                        else _sortMode = SortMode.nameAsc;
                        _refreshList(); // [수정] 17. 갱신
                      });
                    },
                    child: _buildSortButtonChild(),
                  ),
                ],
              ),
            ),
            const Divider(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredIngredients.length,
              itemBuilder: (context, index) {
                final item = filteredIngredients[index];
                return Dismissible(
                  key: Key(item.id),
                  confirmDismiss: (direction) async {
                    // (삭제 확인 팝업 UI 로직)
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("삭제 확인"),
                          content: Text("재료 '${item.name}'을(를) 삭제하시겠습니까?"),
                          actions: <Widget>[
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("삭제", style: TextStyle(color: Colors.red))),
                          ],
                        );
                      },
                    );
                    return confirm ?? false;
                  },
                  onDismissed: (dir) {
                    // [수정] 18. 서비스 호출
                    _service.deleteIngredient(item.id);
                    setState(() {
                      filteredIngredients.removeAt(index);
                    });
                  },
                  background: Container(color: Colors.red),
                  secondaryBackground: Container(color: Colors.red),
                  child: IngredientItem(
                    ingredient: item,
                    onEdit: () {
                      _showIngredientDialog( // UI 함수 호출
                        ingredient: item,
                        index: index,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
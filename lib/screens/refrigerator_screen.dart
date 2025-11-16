import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/ingredient.dart';
import '../widgets/ingredient_item.dart';

enum SortMode { nameAsc, nameDesc, expiryAsc }

class RefrigeratorScreen extends StatefulWidget {
  const RefrigeratorScreen({super.key});
  @override
  State<RefrigeratorScreen> createState() => _RefrigeratorScreenState();
}

class _RefrigeratorScreenState extends State<RefrigeratorScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  SortMode _sortMode = SortMode.nameAsc;

  List<Ingredient> allIngredients = [
    Ingredient(id: '1', name: '계란', quantity: '10', expiryTime: '2025.11.20'),
    Ingredient(id: '2', name: '우유', quantity: '1', expiryTime: '2025.11.25'),
    Ingredient(id: '3', name: '사과', quantity: '5', expiryTime: '2025.11.18'),
  ];
  List<Ingredient> filteredIngredients = [];

  // (날짜 파싱, _getEventsForDay, _filterIngredients, _sortList 함수... 기존과 동일)
  DateTime? _parseDate(String dateStr) {
    try { return DateTime.parse(dateStr.replaceAll('.', '-')); } catch (e) { return null; }
  }
  List<Ingredient> _getEventsForDay(DateTime day) {
    return allIngredients.where((ingredient) {
      DateTime? expiryDate = _parseDate(ingredient.expiryTime);
      return expiryDate != null && isSameDay(expiryDate, day);
    }).toList();
  }
  void _filterIngredients(DateTime selectedDay) {
    setState(() {
      filteredIngredients = _getEventsForDay(selectedDay);
      _sortList();
    });
  }
  void _sortList() {
    setState(() {
      List<Ingredient> listToSort = (_selectedDay == null) ? allIngredients : filteredIngredients;
      switch (_sortMode) {
        case SortMode.nameAsc: listToSort.sort((a, b) => a.name.compareTo(b.name)); break;
        case SortMode.nameDesc: listToSort.sort((a, b) => b.name.compareTo(a.name)); break;
        case SortMode.expiryAsc:
          listToSort.sort((a, b) {
            DateTime? dateA = _parseDate(a.expiryTime);
            DateTime? dateB = _parseDate(b.expiryTime);
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateA.compareTo(dateB);
          });
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    filteredIngredients = allIngredients;
    _sortList();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showIngredientDialog({Ingredient? ingredient, int? index}) {
    final isEditMode = ingredient != null;

    final nameController = TextEditingController(text: ingredient?.name ?? "");
    final quantityController = TextEditingController(text: ingredient?.quantity ?? "");

    String year = '', month = '', day = '';
    // [수정] '미정'이 없으므로 파싱 실패를 걱정할 필요가 거의 없음
    if (isEditMode) {
      DateTime? date = _parseDate(ingredient!.expiryTime);
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
          return TextField(
            controller: controller,
            maxLength: maxLength,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: hint,
              counterText: '',
              filled: true,
              fillColor: Colors.blue[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          );
        }

        return AlertDialog(
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: "1",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
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
                // [수정됨] 1. 유효성 검사
                final name = nameController.text.trim();
                final quantityStr = quantityController.text.trim();
                final yearStr = yearController.text.trim();
                final monthStr = monthController.text.trim();
                final dayStr = dayController.text.trim();

                if (name.isEmpty) { _showErrorSnackBar("이름을 입력해주세요."); return; }
                int quantity = int.tryParse(quantityStr) ?? 0;
                if (quantity <= 0) { _showErrorSnackBar("수량을 1 이상 입력해주세요."); return; }

                String expiryDate; // 날짜 저장 변수

                // [수정됨] 2. 날짜 필드가 하나라도 비어있으면 경고
                if (yearStr.isEmpty || monthStr.isEmpty || dayStr.isEmpty) {
                  _showErrorSnackBar("유통기한(연/월/일)을 모두 입력해주세요.");
                  return;
                }

                // 3. 날짜 형식 검증
                try {
                  int y = int.parse(yearStr);
                  int m = int.parse(monthStr);
                  int d = int.parse(dayStr);

                  DateTime date = DateTime(y, m, d);
                  // (2025.2.30 -> 2025.3.1)처럼 자동 변경되는 것 방지
                  if (date.year != y || date.month != m || date.day != d) {
                    throw FormatException("유효하지 않은 날짜입니다.");
                  }

                  DateTime today = DateTime.now();
                  DateTime todayOnly = DateTime(today.year, today.month, today.day);
                  if (date.isBefore(todayOnly)) {
                    _showErrorSnackBar("유통기한이 오늘보다 빠를 수 없습니다.");
                    return;
                  }

                  expiryDate = DateFormat('yyyy.MM.dd').format(date);

                } catch (e) {
                  _showErrorSnackBar("유효하지 않은 날짜 형식입니다.");
                  return;
                }

                // 4. 저장
                setState(() {
                  Ingredient newIngredient = Ingredient(
                    id: ingredient?.id ?? DateTime.now().toString(),
                    name: name,
                    quantity: quantity.toString(),
                    expiryTime: expiryDate, // [수정] '미정'이 아닌 검증된 날짜
                  );

                  if (isEditMode) {
                    allIngredients[allIngredients.indexWhere((item) => item.id == ingredient.id)] = newIngredient;
                  } else {
                    allIngredients.add(newIngredient);
                  }

                  if (_selectedDay == null) {
                    filteredIngredients = allIngredients;
                  } else {
                    _filterIngredients(_selectedDay!);
                  }
                  _sortList();
                });
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

  Widget _buildSortButtonChild() {
    // (기존과 동일 ... 생략)
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
            // (캘린더 ... 기존과 동일)
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
                eventLoader: _getEventsForDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    if (isSameDay(_selectedDay, selectedDay)) {
                      _selectedDay = null;
                      _focusedDay = focusedDay;
                      filteredIngredients = allIngredients;
                    } else {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _filterIngredients(selectedDay);
                    }
                    _sortList();
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

            // [수정됨] 1. 버튼 영역 (타이틀, 추가 버튼, 필터 해제, 정렬)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  // [추가됨] 2. (+) 추가 버튼
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, color: Colors.green, size: 20),
                    label: const Text(
                      "추가",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onPressed: () => _showIngredientDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade50, // 연두색 배경
                      foregroundColor: Colors.green, // 텍스트/아이콘 색상
                      elevation: 0, // 그림자 없애기
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // 둥근 모서리
                        side: const BorderSide(color: Colors.green, width: 1), // 테두리
                      ),
                    ),
                  ),
                  const Spacer(),

                  // 'X 전체 보기' 버튼
                  AnimatedOpacity(
                    opacity: _selectedDay != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDay = null;
                          filteredIngredients = allIngredients;
                          _sortList();
                        });
                      },
                      child: const Text("X 전체 보기"),
                    ),
                  ),
                  // '정렬' 버튼
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_sortMode == SortMode.nameAsc) _sortMode = SortMode.nameDesc;
                        else if (_sortMode == SortMode.nameDesc) _sortMode = SortMode.expiryAsc;
                        else _sortMode = SortMode.nameAsc;
                        _sortList();
                      });
                    },
                    child: _buildSortButtonChild(),
                  ),
                ],
              ),
            ),
            const Divider(height: 10),

            // (리스트뷰 ... 기존과 동일)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredIngredients.length,
              itemBuilder: (context, index) {
                final item = filteredIngredients[index];
                return Dismissible(
                  key: Key(item.id),
                  confirmDismiss: (direction) async {
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
                    setState(() {
                      allIngredients.removeWhere((i) => i.id == item.id);
                      filteredIngredients.removeAt(index);
                    });
                  },
                  background: Container(color: Colors.red),
                  secondaryBackground: Container(color: Colors.red),
                  child: IngredientItem(
                    ingredient: item,
                    onEdit: () {
                      _showIngredientDialog(
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
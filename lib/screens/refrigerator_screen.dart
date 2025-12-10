// 냉장고 재료 관리·달력·정렬/검색
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/ingredient.dart';
import '../services/notification_service.dart';
import '../services/refrigerator_service.dart';
import '../widgets/ingredient_item.dart';

class RefrigeratorScreen extends StatefulWidget {
  const RefrigeratorScreen({super.key});

  @override
  State<RefrigeratorScreen> createState() => _RefrigeratorScreenState();
}

class _RefrigeratorScreenState extends State<RefrigeratorScreen> {
  // 서비스
  final RefrigeratorService _refrigeratorService = RefrigeratorService();
  // 달력 상태
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  // 정렬/검색 상태
  SortMode _sortMode = SortMode.expiryAsc;
  String _search = "";
  // 목록 상태
  List<Ingredient> _allIngredients = [];
  List<Ingredient> filteredIngredients = [];

  @override
  void initState() {
    super.initState();
    _refreshList();
    alarm.addListener(_refreshList);
  }

  @override
  void dispose() {
    alarm.removeListener(_refreshList);
    super.dispose();
  }

  // 목록 새로고침(조회→검색/날짜 필터→정렬)
  Future<void> _refreshList() async {
    final allData = await _refrigeratorService.getAllIngredients();
    if (!mounted) return;

    setState(() {
      _allIngredients = allData;
      List<Ingredient> temp = List.from(_allIngredients);

      if (_search.isNotEmpty) {
        temp = temp
            .where((ingredient) => ingredient.name.contains(_search))
            .toList();
      }

      if (_selectedDay != null) {
        temp = temp.where((ingredient) {
          final expiryDate = _refrigeratorService.parseDate(
            ingredient.expiryTime,
          );
          return expiryDate != null && isSameDay(expiryDate, _selectedDay!);
        }).toList();
      }

      filteredIngredients = _refrigeratorService.sortList(temp, _sortMode);
    });
  }

  // 검색어 변경
  void _onSearchChanged(String keyword) {
    setState(() {
      _search = keyword;
    });
    _refreshList();
  }

  // 에러 스낵바
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // 재료 추가/수정 다이얼로그
  void _showIngredientDialog({Ingredient? ingredient}) {
    final isEditMode = ingredient != null;

    final nameController = TextEditingController(text: ingredient?.name ?? "");
    final quantityController = TextEditingController(
      text: isEditMode ? ingredient!.quantity.toString() : "1",
    );

    String year = '', month = '', day = '';
    if (isEditMode) {
      final date = _refrigeratorService.parseDate(ingredient!.expiryTime);
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
        final colorScheme = Theme.of(context).colorScheme;

        Widget buildDateTextField(
          TextEditingController controller,
          String hint,
          int maxLength,
        ) {
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
              fillColor: colorScheme.primary.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          );
        }

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                isEditMode ? "재료 수정" : "재료 등록",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          content: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("이름", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(controller: nameController),
                const SizedBox(height: 16),
                const Text("수량", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                const Text(
                  "유통기한",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: buildDateTextField(yearController, "YYYY", 4),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("."),
                    ),
                    Expanded(
                      flex: 1,
                      child: buildDateTextField(monthController, "MM", 2),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("."),
                    ),
                    Expanded(
                      flex: 1,
                      child: buildDateTextField(dayController, "DD", 2),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final quantityStr = quantityController.text.trim();
                final yearStr = yearController.text.trim();
                final monthStr = monthController.text.trim();
                final dayStr = dayController.text.trim();

                if (name.isEmpty) {
                  _showErrorSnackBar("이름을 입력해주세요.");
                  return;
                }

                final quantity = int.tryParse(quantityStr) ?? 0;
                if (quantity <= 0) {
                  _showErrorSnackBar("수량을 1 이상 입력해주세요.");
                  return;
                }

                if (yearStr.isEmpty || monthStr.isEmpty || dayStr.isEmpty) {
                  _showErrorSnackBar("유통기한(연/월/일)을 모두 입력해주세요.");
                  return;
                }

                String expiryDate;
                try {
                  final y = int.parse(yearStr);
                  final m = int.parse(monthStr);
                  final d = int.parse(dayStr);
                  final date = DateTime(y, m, d);

                  if (date.year != y || date.month != m || date.day != d) {
                    throw const FormatException();
                  }

                  final today = DateTime.now();
                  final todayOnly = DateTime(
                    today.year,
                    today.month,
                    today.day,
                  );
                  if (date.isBefore(todayOnly)) {
                    _showErrorSnackBar("유통기한이 오늘보다 빠를 수 없습니다.");
                    return;
                  }

                  expiryDate = DateFormat('yyyy.MM.dd').format(date);
                } catch (_) {
                  _showErrorSnackBar("유효하지 않은 날짜 형식입니다.");
                  return;
                }

                Navigator.pop(context);

                List<Ingredient> updatedList;
                if (isEditMode) {
                  updatedList = await _refrigeratorService.updateIngredient(
                    ingredient!.id,
                    name: name,
                    quantity: quantity,
                    expiryTime: expiryDate,
                  );
                } else {
                  updatedList = await _refrigeratorService.addIngredient(
                    name: name,
                    quantity: quantity,
                    expiryTime: expiryDate,
                  );
                }
                alarm.value++;

                if (!mounted) return;

                setState(() {
                  _allIngredients = updatedList;
                  List<Ingredient> temp = List.from(_allIngredients);

                  if (_search.isNotEmpty) {
                    temp = temp
                        .where((ing) => ing.name.contains(_search))
                        .toList();
                  }

                  if (_selectedDay != null) {
                    temp = temp.where((ing) {
                      final expiryDateParsed = _refrigeratorService.parseDate(
                        ing.expiryTime,
                      );
                      return expiryDateParsed != null &&
                          isSameDay(expiryDateParsed, _selectedDay!);
                    }).toList();
                  }

                  filteredIngredients = _refrigeratorService.sortList(
                    temp,
                    _sortMode,
                  );
                });

                try {
                  await NotificationService.instance.checkExpiringIngredients();
                } catch (_) {
                  // 알림 체크 실패는 무시
                }
              },
              child: Text(
                isEditMode ? "수정" : "추가",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 정렬 버튼
  Widget _buildSortButton(String type, String label) {
    bool isActive = false;
    bool isAsc = true;

    if (type == "name") {
      isActive =
          _sortMode == SortMode.nameAsc || _sortMode == SortMode.nameDesc;
      isAsc = _sortMode == SortMode.nameAsc;
    } else {
      isActive =
          _sortMode == SortMode.expiryAsc || _sortMode == SortMode.expiryDesc;
      isAsc = _sortMode == SortMode.expiryAsc;
    }

    return TextButton(
      onPressed: () {
        setState(() {
          if (type == "name") {
            _sortMode = _sortMode == SortMode.nameAsc
                ? SortMode.nameDesc
                : SortMode.nameAsc;
          } else {
            _sortMode = _sortMode == SortMode.expiryAsc
                ? SortMode.expiryDesc
                : SortMode.expiryAsc;
          }
          _refreshList();
        });
      },
      style: TextButton.styleFrom(
        foregroundColor: isActive ? Colors.black87 : Colors.grey,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 4),
            Icon(isAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 검색창
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
          ),
          // 달력
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                left: 16.0,
                right: 16.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TableCalendar(
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.utc(2099, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  eventLoader: (day) {
                    return _allIngredients.where((ingredient) {
                      final expiryDate = _refrigeratorService.parseDate(
                        ingredient.expiryTime,
                      );
                      return expiryDate != null && isSameDay(expiryDate, day);
                    }).toList();
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      if (isSameDay(_selectedDay, selectedDay)) {
                        _selectedDay = null;
                        _focusedDay = focusedDay;
                      } else {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      }
                      _refreshList();
                    });
                  },
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return null;
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final target = DateTime(day.year, day.month, day.day);
                      final difference = target.difference(today).inDays;

                      Color dotColor = Colors.black;
                      if (difference < 0) {
                        dotColor = Colors.red;
                      } else if (difference == 0) {
                        dotColor = Colors.orange;
                      } else if (difference <= 3) {
                        dotColor = Colors.yellow;
                      }

                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 7.0,
                          height: 7.0,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // 상단 버튼들
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.add,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      label: Text(
                        "추가",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => _showIngredientDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                        surfaceTintColor: colorScheme.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: colorScheme.primary,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildSortButton("name", "이름"),
                    _buildSortButton("유통기한", "유통기한"),
                  ],
                ),
              ),
            ),
          ),
          // 선택 날짜 안내
          if (_selectedDay != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Text(
                      "${_selectedDay!.month}월 ${_selectedDay!.day}일 재료만 보는 중",
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDay = null;
                          _refreshList();
                        });
                      },
                      child: const Text(
                        "전체 보기",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(height: 10),
            ),
          ),
          // 재료 목록
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = filteredIngredients[index];
                return Dismissible(
                  key: Key(item.id),
                  confirmDismiss: (direction) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("삭제 확인"),
                          content: Text("재료 '${item.name}'을(를) 삭제하시겠습니까?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("취소"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                "삭제",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    return confirm ?? false;
                  },
                  onDismissed: (dir) async {
                    final updatedList = await _refrigeratorService
                        .deleteIngredient(item.id);
                    alarm.value++;

                    if (!mounted) return;

                    setState(() {
                      _allIngredients = updatedList;
                      List<Ingredient> temp = List.from(_allIngredients);

                      if (_search.isNotEmpty) {
                        temp = temp
                            .where((ing) => ing.name.contains(_search))
                            .toList();
                      }

                      if (_selectedDay != null) {
                        temp = temp.where((ing) {
                          final expiryDateParsed = _refrigeratorService
                              .parseDate(ing.expiryTime);
                          return expiryDateParsed != null &&
                              isSameDay(expiryDateParsed, _selectedDay!);
                        }).toList();
                      }

                      filteredIngredients = _refrigeratorService.sortList(
                        temp,
                        _sortMode,
                      );
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "삭제",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "삭제",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.delete, color: Colors.white),
                      ],
                    ),
                  ),
                  child: IngredientItem(
                    ingredient: item,
                    onEdit: () => _showIngredientDialog(ingredient: item),
                  ),
                );
              }, childCount: filteredIngredients.length),
            ),
          ),
        ],
      ),
    );
  }
}

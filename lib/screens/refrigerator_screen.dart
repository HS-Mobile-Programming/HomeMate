// [IMPORT] - 외부 라이브러리 또는 다른 파일의 기능을 가져옵니다.

// flutter/material.dart: 플러터의 핵심 UI 위젯(예: Scaffold, Text, Icon)들을 포함합니다.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/ingredient.dart';
import '../widgets/ingredient_item.dart';
import '../services/refrigerator_service.dart';

// [StatefulWidget]
// RefrigeratorScreen 위젯을 정의합니다.
// StatefulWidget은 화면의 내용(데이터)이 사용자의 행동에 따라 변경되어야 할 때 사용합니다.
// (예: 날짜를 선택하거나, 재료를 추가/삭제하면 화면이 바뀌어야 함)
class RefrigeratorScreen extends StatefulWidget {
  // const RefrigeratorScreen(...): 위젯을 생성할 때 사용하는 생성자입니다.
  const RefrigeratorScreen({super.key});

  // createState() : 이 위젯이 관리할 '상태(State)' 객체를 생성하는 메서드입니다.
  // 실제 UI와 로직은 _RefrigeratorScreenState 클래스에서 구현됩니다.
  @override
  State<RefrigeratorScreen> createState() => _RefrigeratorScreenState();
}

// [_RefrigeratorScreenState]
// RefrigeratorScreen의 실제 상태와 UI를 관리하는 클래스입니다.
class _RefrigeratorScreenState extends State<RefrigeratorScreen> {

  // [상태 변수 (State Variables)]
  // 이 변수들의 값이 바뀌고 'setState'가 호출되면 화면이 다시 그려집니다.

  //  2. 서비스(로직) 객체 생성
  // RefrigeratorService 클래스의 인스턴스(실제 객체)를 생성합니다.
  // 앞으로 재료 데이터를 처리할 때는 `_service.addIngredient(...)`처럼 이 객체를 사용합니다.
  final RefrigeratorService _service = RefrigeratorService();

  //  3. UI 상태 변수들

  // TableCalendar가 현재 '포커스'하고 있는 날짜 (기본값: 오늘)
  // 이 값이 바뀌면 달력이 해당 월로 스크롤됩니다.
  DateTime _focusedDay = DateTime.now();

  // 사용자가 '선택'한 날짜 (기본값: null - 아무것도 선택 안 함)
  // 이 값이 null이 아니면 해당 날짜의 재료만 필터링해서 보여줍니다.
  DateTime? _selectedDay;

  // 달력의 표시 형식 (기본값: month - 월 단위)
  // (이 코드에서는 사용자가 형식을 바꾸는 기능은 없지만, 'week'나 '2weeks'로 변경 가능합니다.)
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // 재료 목록의 정렬 방식 (기본값: nameAsc - 이름 오름차순)
  // 이 값에 따라 _refreshList()에서 목록을 정렬하는 방식이 달라집니다.
  SortMode _sortMode = SortMode.nameAsc;


  // 4. 화면에 보여질 리스트
  // 실제 UI(ListView)에 그려질 필터링 및 정렬이 완료된 재료 목록입니다.
  // _refreshList() 함수가 이 리스트를 최신 상태로 업데이트합니다.
  List<Ingredient> filteredIngredients = [];

  // [initState]
  // 이 위젯(화면)이 처음 생성될 때 딱 한 번 호출됩니다.
  @override
  void initState() {
    super.initState();
    _refreshList(); //  7. 화면이 처음 뜰 때 재료 목록을 불러오도록 함수 호출
  }

  //  8. 데이터를 서비스에서 다시 불러오는 '새로고침' 함수
  // 이 함수는 화면에 보여질 'filteredIngredients' 목록을 갱신하는 유일한 통로입니다.
  // (1) 재료 추가/수정/삭제 시, (2) 날짜 선택 시, (3) 정렬 변경 시 호출됩니다.
  Future<void> _refreshList() async {

    // (A) 서비스에서 '모든' 재료 데이터를 가져옵니다. (비동기)
    List<Ingredient> allData = await _service.getAllIngredients();

    if (mounted) {
      setState(() {
        // (B) 날짜 필터링
        if (_selectedDay == null) {
          // _selectedDay가 null이면 (즉, 'X 전체 보기' 상태) 모든 데이터를 보여줍니다.
          filteredIngredients = allData;
        } else {
          // _selectedDay가 선택되어 있으면, 서비스의 'getEventsForDay' 로직을 호출해
          // 해당 날짜의 재료만 필터링합니다.
          // (getEventsForDay는 메모리상의 데이터를 필터링하므로 동기 호출 유지)
          filteredIngredients = _service.getEventsForDay(_selectedDay!);
        }

        // (C) 정렬
        // (A) 또는 (B)에서 필터링된 결과를 현재 설정된 `_sortMode` 기준으로 정렬합니다.
        filteredIngredients = _service.sortList(filteredIngredients, _sortMode);

      });
    }
  }

  //  9. UI 관련 헬퍼 함수
  // 사용자에게 빨간색 배경의 에러 메시지(스낵바)를 띄웁니다.
// [IMPORT] - 외부 라이브러리 또는 다른 파일의 기능을 가져옵니다.
  void _showErrorSnackBar(String message) {
    // ScaffoldMessenger: 화면 하단에 스낵바, 상단에 배너 등을 관리하는 객체입니다.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), // 표시할 텍스트
        backgroundColor: Colors.red, // 배경색
      ),
    );
  }

//  10. 재료 추가/수정 다이얼로그 (UI)
// '추가' 버튼을 누르거나(ingredient: null),
// 기존 항목의 '수정' 버튼을 누를 때(ingredient: 기존 재료) 호출됩니다.
  void _showIngredientDialog({Ingredient? ingredient, int? index}) {
    // 'ingredient' 파라미터가 null이 아니면 '수정' 모드입니다.
    final isEditMode = ingredient != null;

    // 다이얼로그 내부의 텍스트 필드(TextField)를 제어하기 위한 컨트롤러입니다.
    // '수정' 모드일 경우, 기존 재료의 값으로 초기화합니다.
    final nameController = TextEditingController(text: ingredient?.name ?? "");
    final quantityController = TextEditingController(
        text: ingredient?.quantity ?? "");

    // '수정' 모드일 때, 기존 유통기한(예: "2025.11.20")을 파싱하여
    // 년/월/일 컨트롤러에 각각 초기값(예: "2025", "11", "20")을 설정합니다.
    String year = '',
        month = '',
        day = '';
    if (isEditMode) {
      // 날짜 파싱 로직을 서비스에 위임합니다.
      DateTime? date = _service.parseDate(ingredient.expiryTime);
      if (date != null) {
        year = date.year.toString();
        month = date.month.toString();
        day = date.day.toString();
      }
    }
    // '등록' 모드일 경우 빈 값("")으로 초기화됩니다.
    final yearController = TextEditingController(text: year);
    final monthController = TextEditingController(text: month);
    final dayController = TextEditingController(text: day);

    // showDialog: 플러터에서 기본 제공하는 다이얼로그(팝업) 표시 함수입니다.
    showDialog(
      context: context,
      builder: (context) { // 'context'는 다이얼로그가 그려질 위치(화면) 정보입니다.

        // (내부 함수) 년/월/일 입력을 위한 텍스트 필드 UI를 생성합니다.
        Widget buildDateTextField(TextEditingController controller, String hint,
            int maxLength) {
          return TextField(
            controller: controller,
            // 이 컨트롤러와 텍스트 필드를 연결
            maxLength: maxLength,
            // 최대 입력 글자 수 (예: 'YYYY'는 4)
            keyboardType: TextInputType.number,
            // 숫자 키보드만 표시
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            // 숫자만 입력되도록 필터링
            textAlign: TextAlign.center,
            // 텍스트 가운데 정렬
            decoration: InputDecoration(
              hintText: hint,
              // 입력 예시 (예: "YYYY")
              counterText: '',
              // '4/4' 같은 글자 수 표시 숨김
              filled: true,
              // 배경색 채우기
              fillColor: Colors.blue[50],
              // 연한 파란색 배경
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none // 테두리선 없음
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          );
        }

        // AlertDialog: 다이얼로그의 본체입니다.
        return AlertDialog(
          // (다이얼로그 UI 코드는 동일)
          backgroundColor: Colors.white,
          // 다이얼로그 배경색
          titlePadding: EdgeInsets.zero,
          // 제목(Title) 영역의 기본 패딩(여백) 제거
          title: Container( // 제목 영역을 직접 디자인
            color: Colors.blue[200], // 제목 배경색
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                isEditMode ? "재료 수정" : "재료 등록", // 모드에 따라 텍스트 변경
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          content: SingleChildScrollView( // 내용(Content) 영역
            // 내용이 길어지면 스크롤이 가능하도록 합니다.
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // 컨텐츠 높이만큼만 다이얼로그 크기 잡기
              crossAxisAlignment: CrossAxisAlignment.start,
              // '이름', '수량' 글자를 왼쪽 정렬
              children: [
                const Text("이름", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(controller: nameController, /* ... */),
                const SizedBox(height: 16), // 위젯 사이의 수직 간격
                const Text("수량", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(controller: quantityController, /* ... */),
                const SizedBox(height: 16),
                const Text(
                    "유통기한", style: TextStyle(fontWeight: FontWeight.bold)),
                Row( // 년/월/일 필드를 가로로 배치
                  children: [
                    // Expanded: Row 안에서 남은 공간을 차지하는 비율을 정합니다.
                    Expanded(flex: 2,
                        child: buildDateTextField(yearController, "YYYY", 4)),
                    // '년' (2비율)
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(".")),
                    Expanded(flex: 1,
                        child: buildDateTextField(monthController, "MM", 2)),
                    // '월' (1비율)
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(".")),
                    Expanded(flex: 1,
                        child: buildDateTextField(dayController, "DD", 2)),
                    // '일' (1비율)
                  ],
                ),
              ],
            ),
          ),
          actions: [ // 하단 버튼(Actions) 영역
            TextButton(
              onPressed: () => Navigator.pop(context), // 버튼 누르면 다이얼로그 닫기
              child: const Text("취소", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async { // [수정] async 추가
                // [유효성 검사 (Validation)]

                // 1. 입력값 가져오기 (trim: 앞뒤 공백 제거)
                final name = nameController.text.trim();
                final quantityStr = quantityController.text.trim();
                final yearStr = yearController.text.trim();
                final monthStr = monthController.text.trim();
                final dayStr = dayController.text.trim();

                // 2. 이름 검사
                if (name.isEmpty) {
                  _showErrorSnackBar("이름을 입력해주세요.");
                  return; // 함수 종료
                }

                // 3. 수량 검사
                int quantity = int.tryParse(quantityStr) ??
                    0; // 숫자로 변환 시도, 실패하면 0
                if (quantity <= 0) {
                  _showErrorSnackBar("수량을 1 이상 입력해주세요.");
                  return;
                }

                // 4. 날짜 검사
                String expiryDate;
                if (yearStr.isEmpty || monthStr.isEmpty || dayStr.isEmpty) {
                  _showErrorSnackBar("유통기한(연/월/일)을 모두 입력해주세요.");
                  return;
                }

                try {
                  int y = int.parse(yearStr);
                  int m = int.parse(monthStr);
                  int d = int.parse(dayStr);
                  DateTime date = DateTime(
                      y, m, d); // 2025, 2, 30 -> 2025, 3, 1 (DateTime이 자동 보정)

                  // '2025.2.30'처럼 유효하지 않은 날짜를 입력했는지 확인 (보정된 날짜와 원본이 다른지)
                  if (date.year != y || date.month != m || date.day != d) {
                    throw FormatException("유효하지 않은 날짜입니다.");
                  }

                  // 오늘 날짜와 비교 (시간, 분, 초 제외)
                  DateTime today = DateTime.now();
                  DateTime todayOnly = DateTime(
                      today.year, today.month, today.day);
                  if (date.isBefore(todayOnly)) { // 선택한 날짜가 오늘 이전이면
                    _showErrorSnackBar("유통기한이 오늘보다 빠를 수 없습니다.");
                    return;
                  }

                  // 모든 검사 통과 -> "yyyy.MM.dd" 형식의 문자열로 변환
                  expiryDate = DateFormat('yyyy.MM.dd').format(date);
                } catch (e) {
                  // int.parse 실패 또는 FormatException 발생 시
                  _showErrorSnackBar("유효하지 않은 날짜 형식입니다.");
                  return;
                }

                Navigator.pop(context); // 다이얼로그 닫기


                //  11. 로직 대신 서비스 호출
                // 유효성 검사를 모두 통과하면, 실제 데이터 처리는 서비스에 위임합니다.
                if (isEditMode) {
                  // '수정' 모드일 경우
                  await _service.updateIngredient(ingredient.id,
                    name: name,
                    quantity: quantity.toString(),
                    expiryTime: expiryDate,
                  );
                } else {
                  // '등록' 모드일 경우
                  await _service.addIngredient(
                    name: name,
                    quantity: quantity.toString(),
                    expiryTime: expiryDate,
                  );
                }

                await _refreshList(); // 12. 서비스 호출 후 화면 갱신 (가장 중요)
              },
              child: Text(
                isEditMode ? "수정" : "추가", // 모드에 따라 버튼 텍스트 변경
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

//  13. 정렬 버튼 UI
// 현재 `_sortMode` 상태에 따라 버튼의 아이콘과 텍스트를 동적으로 생성합니다.
  Widget _buildSortButtonChild() {
    IconData icon = Icons.swap_vert; // 기본 아이콘
    String label; // 버튼에 표시될 텍스트

    // `_sortMode` 값에 따라 'label' 텍스트를 다르게 설정
    switch (_sortMode) {
      case SortMode.nameAsc:
        label = "이름 (가-힣)";
        break;
      case SortMode.nameDesc:
        label = "이름 (힣-가)";
        break;
      case SortMode.expiryAsc:
        label = "유통기한 임박순";
        break;
    }

    // 아이콘과 텍스트를 가로(Row)로 배치하여 반환
    return Row(
      mainAxisSize: MainAxisSize.min, // 자식 위젯 크기만큼만 Row 크기 설정
      children: [
        Icon(icon, size: 18, color: Colors.black54), // 아이콘
        const SizedBox(width: 4), // 아이콘과 텍스트 사이 간격
        Text(label, style: const TextStyle(color: Colors.black54)), // 텍스트
      ],
    );
  }

// [build]
  // 이 위젯의 UI(화면)를 실제로 그리는 메서드입니다.
  // `setState()`가 호출될 때마다 이 `build` 메서드가 다시 실행됩니다.
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    // Scaffold: 앱 화면의 기본적인 구조(상단바, 본문, 하단바 등)를 제공합니다.
    return Scaffold(
      // SingleChildScrollView + Column 구조를 CustomScrollView + Slivers 구조로 변경
      // 성능 최적화를 위해 리스트 부분을 SliverList로 처리합니다.
      body: CustomScrollView(
        slivers: [
          // [달력 위젯]
          // 기존 Container를 SliverToBoxAdapter로 감싸서 Sliver 영역에 배치
          SliverToBoxAdapter(
            child: Padding(
              // 기존 SingleChildScrollView의 padding(16.0)을 여기서 적용
              padding: const EdgeInsets.only(
                  top: 16.0, left: 16.0, right: 16.0),
              child: Container( // 달력을 감싸는 컨테이너
                decoration: BoxDecoration(
                  color: Colors.white, // 배경색 흰색
                  borderRadius: BorderRadius.circular(16), // 모서리 둥글게
                ),
                child: TableCalendar(
                  locale: 'ko_KR',
                  // 달력 언어
                  firstDay: DateTime.utc(2020, 1, 1),
                  // 달력이 보여줄 수 있는 최소 날짜
                  lastDay: DateTime.utc(2030, 12, 31),
                  // 달력이 보여줄 수 있는 최대 날짜
                  focusedDay: _focusedDay,
                  // 현재 포커스된 날짜 (상태 변수)
                  calendarFormat: _calendarFormat,
                  // 달력 형식 (상태 변수)
                  headerStyle: const HeaderStyle(
                      formatButtonVisible: false, // 'Month'/'Week' 전환 버튼 숨김
                      titleCentered: true // '2025년 11월' 제목 가운데 정렬
                  ),
                  // eventLoader: 각 날짜 하단에 마커(이벤트)를 표시하기 위한 데이터를 제공하는 함수
                  // 서비스의 `getEventsForDay` 로직을 그대로 연결합니다.
                  // 달력이 날짜(예: 11/20)를 그릴 때마다 `_service.getEventsForDay(11/20)`를 호출합니다.
                  eventLoader: _service.getEventsForDay,
                  //  14. 서비스 함수 호출

                  // onDaySelected: 사용자가 특정 날짜를 탭(클릭)했을 때 호출되는 콜백 함수
                  onDaySelected: (selectedDay, focusedDay) {
                    // setState를 호출하여 UI 상태를 변경합니다.
                    setState(() {
                      // isSameDay: 두 날짜가 같은 날인지 비교 (시간, 분, 초 무시)
                      if (isSameDay(_selectedDay, selectedDay)) {
                        // 만약 이미 선택된 날짜를 다시 탭하면, 선택을 해제합니다. (전체 보기)
                        _selectedDay = null;
                        _focusedDay = focusedDay; // 포커스는 탭한 날짜로 이동
                      } else {
                        // 다른 날짜를 탭하면, 해당 날짜를 선택 상태로 변경합니다.
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay; // 포커스도 함께 이동
                      }
                      _refreshList(); //  15. 날짜 선택이 변경되었으므로 목록을 새로고침
                    });
                  },
                  // selectedDayPredicate: 어떤 날짜를 '선택됨'으로 표시할지 결정하는 함수
                  // 현재 `_selectedDay` 상태 변수와 같은 날짜에 '선택됨' 스타일을 적용합니다.
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                  // calendarStyle: 달력의 세부 스타일을 지정합니다.
                  calendarStyle: CalendarStyle(
                    // markerDecoration: eventLoader에 의해 이벤트가 있는 날(유통기한)의 마커 스타일
                    markerDecoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    // todayDecoration: '오늘' 날짜의 스타일
                    todayDecoration: BoxDecoration(
                        color: Colors.grey.shade300, shape: BoxShape.circle),
                    // selectedDecoration: '선택된' 날짜의 스타일
                    selectedDecoration: BoxDecoration(
                        color: Colors.green.shade300, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          ),

          // [버튼 영역] (추가 버튼, 전체 보기 버튼, 정렬 버튼)
          SliverToBoxAdapter(
            child: Padding(
              // 기존 SingleChildScrollView의 가로 패딩 적용
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0, vertical: 4.0),
                child: Row( // 위젯들을 가로로 배치
                  children: [
                    // '추가' 버튼
                    ElevatedButton.icon(
                      icon: Icon(
                          Icons.add, color: colorScheme.primary, size: 20),
                      label: Text(
                        "추가",
                        style: TextStyle(color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      onPressed: () => _showIngredientDialog(),
                      // _showIngredientDialog() 호출
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                        // 흰색/밝은색
                        surfaceTintColor: colorScheme.primary,
                        // 틴트
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: colorScheme.primary,
                              width: 1),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // '추가' 버튼과 '전체 보기' 버튼 사이의 공간을 모두 차지 (오른쪽으로 밀어냄)

                    // 'X 전체 보기' 버튼
                    AnimatedOpacity(
                      // `_selectedDay`가 null이 아닐 때만(즉, 날짜가 선택됐을 때만) 보이도록 처리
                      opacity: _selectedDay != null ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      // 0.3초 동안 서서히 나타남/사라짐
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedDay = null; // 날짜 선택 해제
                            _refreshList(); //  16. 전체 목록 새로고침
                          });
                        },
                        child: const Text("X 전체 보기"),
                      ),
                    ),

                    // '정렬' 버튼
                    TextButton(
                      onPressed: () {
                        // 정렬 버튼을 누를 때마다 `_sortMode` 상태를 순환시킵니다.
                        setState(() {
                          if (_sortMode == SortMode.nameAsc)
                            _sortMode = SortMode.nameDesc;
                          else if (_sortMode == SortMode.nameDesc)
                            _sortMode = SortMode.expiryAsc;
                          else
                            _sortMode = SortMode.nameAsc;
                          _refreshList(); //  17. 정렬 모드가 바뀌었으므로 목록 새로고침
                        });
                      },
                      // 버튼의 내용은 `_buildSortButtonChild` 함수가 동적으로 생성
                      child: _buildSortButtonChild(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(height: 10),
            ),
          ), // 구분선

          // [재료 목록 (ListView)]
          // filteredIngredients(상태 변수)의 내용에 따라 목록을 동적으로 생성합니다.
          // 기존 ListView.builder를 SliverList로 변경하여 성능 최적화
          SliverPadding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, bottom: 16.0),
            sliver: SliverList(
              // itemBuilder: 'itemCount'만큼 반복 호출되며, 각 인덱스(index)에 해당하는
              // UI(위젯)를 생성합니다.
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  // 현재 인덱스에 해당하는 재료 아이템
                  final item = filteredIngredients[index];

                  // Dismissible: 자식 위젯(IngredientItem)을 좌우로 스와이프하여
                  // 삭제할 수 있게 해주는 위젯입니다.
                  return Dismissible(
                    // key: 플러터가 각 위젯을 구별하는 고유 ID입니다. (필수!)
                    // 아이템이 삭제/추가될 때 목록이 꼬이지 않게 해줍니다.
                    key: Key(item.id),

                    // confirmDismiss: 스와이프가 완료되기 '직전'에 호출됩니다.
                    // 사용자에게 "정말 삭제하시겠습니까?"라고 물어볼 기회를 줍니다.
                    confirmDismiss: (direction) async {
                      // (삭제 확인 팝업 UI 로직)
                      bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("삭제 확인"),
                            content: Text("재료 '${item.name}'을(를) 삭제하시겠습니까?"),
                            actions: <Widget>[
                              TextButton(onPressed: () =>
                                  Navigator.pop(context, false),
                                  child: const Text("취소")),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("삭제",
                                      style: TextStyle(color: Colors.red))),
                            ],
                          );
                        },
                      );
                      // '삭제' 버튼을 누르면 true, '취소' 버튼이나 팝업 바깥을 누르면 false (또는 null) 반환
                      return confirm ?? false;
                    },

                    // onDismissed: 'confirmDismiss'가 true를 반환하여 스와이프가 '완료'되었을 때 호출됩니다.
                    onDismissed: (dir) {
                      //  18. 서비스 호출
                      _service.deleteIngredient(item.id); // 서비스에 실제 데이터 삭제 요청

                      // 화면에서도 즉각적인 반응을 보여주기 위해 'filteredIngredients' 목록에서 제거
                      // (주의: _refreshList()를 호출하면 서버/DB에서 다시 읽어오므로,
                      //       즉각적인 UI 반영을 위해 로컬 리스트에서 바로 제거하는 것이 더 빠릅니다.)
                      setState(() {
                        filteredIngredients.removeAt(index);
                      });
                    },

                    // background: 왼쪽 -> 오른쪽 스와이프 시 배경
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft, // 아이콘을 왼쪽에 배치
                      padding: const EdgeInsets.symmetric(horizontal: 20), // 여백
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.delete, color: Colors.white), // 휴지통 아이콘
                          SizedBox(width: 8),
                          Text("삭제", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    // secondaryBackground: 오른쪽 -> 왼쪽 스와이프 시 배경
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight, // 아이콘을 오른쪽에 배치
                      padding: const EdgeInsets.symmetric(horizontal: 20), // 여백
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("삭제", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.delete, color: Colors.white), // 휴지통 아이콘
                        ],
                      ),
                    ),
                    // child: 실제 화면에 보이는 재료 아이템 위젯
                    child: IngredientItem(
                      ingredient: item, // 표시할 재료 데이터
                      onEdit: () { // '수정' 아이콘이 눌렸을 때 실행될 콜백 함수
                        _showIngredientDialog( // UI 함수 호출
                          ingredient: item, // '수정' 모드이므로 기존 재료 데이터 전달
                          index: index,
                        );
                      },
                    ),
                  );
                },
                childCount: filteredIngredients.length, // 목록 아이템의 총 개수
              ),
            ),
          ),
        ],
      ),
    );
  }
}
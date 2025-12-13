// 맛 태그 선택 아이템 위젯
// 선호도 설정 화면의 개별 태그 UI 및 선택 상태 표시
import 'package:flutter/material.dart';
import '../models/tag_model.dart';

class TagItem extends StatelessWidget {
  // 표시할 태그 데이터
  final TagModel tag;
  // 태그 탭 이벤트 핸들러
  final VoidCallback onTap;

  const TagItem({super.key, required this.tag, required this.onTap});

  // 태그 이름을 assets 이미지 경로로 변환 (공백 제거)
  String _getImagePath(String _tagName) {
    String _fileName = _tagName.replaceAll(' ', '');
    return 'assets/images/tags/$_fileName.png';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tag.isSelected
                  ? Colors.green.shade50
                  : const Color(0xFFEEEEEE),
              border: Border.all(
                color: tag.isSelected ? Colors.green : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                _getImagePath(tag.name),
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, _error, _stackTrace) {
                  return Icon(
                    Icons.collections,
                    color: tag.isSelected ? Colors.green : Colors.grey[600],
                    size: 32,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tag.name,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
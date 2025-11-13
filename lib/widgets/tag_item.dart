import 'package:flutter/material.dart';
import '../models/tag_model.dart';

class TagItem extends StatelessWidget {
  final TagModel tag;
  final VoidCallback onTap;

  const TagItem({super.key, required this.tag, required this.onTap});

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
              color: tag.isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFEEEEEE),
              border: Border.all(
                color: tag.isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.collections,
              color: Colors.grey[600],
              size: 32,
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
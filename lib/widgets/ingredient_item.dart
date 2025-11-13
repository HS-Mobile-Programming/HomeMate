import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientItem extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback? onEdit; // [변경] 물음표(?)를 붙여서 '없을 수도 있음'을 표시

  const IngredientItem({
    super.key,
    required this.ingredient,
    this.onEdit, // [변경] required 제거 (선택 사항으로 변경)
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Text(
              ingredient.expiryTime,
              style: const TextStyle(fontSize: 14, color: Color(0xFFC90000)),
            ),

            // [핵심 변경] onEdit이 null이 아닐 때만 버튼을 그린다!
            if (onEdit != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                onPressed: onEdit,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                splashRadius: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
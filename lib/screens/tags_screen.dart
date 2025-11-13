import 'package:flutter/material.dart';
import '../models/tag_model.dart';
import '../widgets/tag_item.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  late List<TagModel> tags;

  @override
  void initState() {
    super.initState();
    tags = List.generate(24, (index) {
      return TagModel("태그 ${String.fromCharCode(65 + index)}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          return TagItem(
            tag: tags[index],
            onTap: () {
              setState(() {
                tags[index].isSelected = !tags[index].isSelected;
              });
            },
          );
        },
      ),
    );
  }
}
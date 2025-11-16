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
    // [추가] "선호도 설정" 화면으로 보이도록 Scaffold 추가
    return Scaffold(
      appBar: AppBar(
        title: const Text("선호도 설정 (태그)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder( // 기존 로직은 그대로 유지
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
      ),
    );
  }
}
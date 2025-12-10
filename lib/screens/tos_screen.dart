// 이용약관 표시 전용 화면
import 'package:flutter/material.dart';
import '../data/tos_data.dart';

class TosScreen extends StatelessWidget {
  const TosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "이용약관",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 약관 내용 영역
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const SingleChildScrollView(
                    child: Text(
                      tosContent,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 닫기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "닫기",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

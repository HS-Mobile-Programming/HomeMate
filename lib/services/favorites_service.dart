import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _favCol =>
      _db.collection('users').doc(_uid).collection('favorites');

  // 즐겨찾기 추가
  Future<void> addFavorite(String recipeId) async {
    await _favCol.doc(recipeId).set({"saved": true});
  }

  // 즐겨찾기 제거
  Future<void> removeFavorite(String recipeId) async {
    await _favCol.doc(recipeId).delete();
  }

  // 즐겨찾기 전체 리스트 가져오기
  Future<List<String>> getFavoriteList() async {
    final snapshot = await _favCol.get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }
}
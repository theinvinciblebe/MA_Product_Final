import 'package:flutter/material.dart';

class FavoritesManager extends ChangeNotifier {
  final List<Map<String, dynamic>> _favoriteItems = [];

  List<Map<String, dynamic>> get favoriteItems => List.unmodifiable(_favoriteItems);

  int get favoriteCount => _favoriteItems.length;

  bool isFavorite(int productId) {
    return _favoriteItems.any((item) => item['id'] == productId);
  }

  void toggleFavorite(Map<String, dynamic> product) {
    if (isFavorite(product['id'])) {
      _favoriteItems.removeWhere((item) => item['id'] == product['id']);
    } else {
      _favoriteItems.add(product);
    }
    notifyListeners();
  }
}

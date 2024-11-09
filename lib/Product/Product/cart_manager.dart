import 'package:flutter/material.dart';

class CartManager extends ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  double get totalAmount {
    return _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  int get totalItemCount {
    return _cartItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
  }

  void addItem(Map<String, dynamic> product) {
    int index = _cartItems.indexWhere((item) => item['id'] == product['id']);
    if (index >= 0) {
      _cartItems[index]['quantity'] += product['quantity'] ?? 1;
    } else {
      _cartItems.add({...product, 'quantity': product['quantity'] ?? 1});
    }
    notifyListeners();
  }

  void updateItemQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
    } else {
      _cartItems[index]['quantity'] = quantity;
      notifyListeners();
    }
  }

  void removeItem(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

import 'package:flutter/cupertino.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';

class CartProvider with ChangeNotifier {
   List<CartItem> cartItems = List.empty(growable: true);

   void addItem(CartItem item) {
     cartItems.add(item);
     notifyListeners();
   }

   void removeItem(CartItem item) {
     cartItems.remove(item);
     notifyListeners();
   }

  void clearItems() {
     cartItems.clear();
     notifyListeners();
  }
}

final cartProvider = CartProvider();

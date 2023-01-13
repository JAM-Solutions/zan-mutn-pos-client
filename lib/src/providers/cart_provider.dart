import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';

class CartProvider with ChangeNotifier {
   List<RevenueItem> cartItems = List.empty(growable: true);

   void addItem(RevenueItem item) {
     cartItems.add(item);
     notifyListeners();
   }

   void removeItem(RevenueItem item) {
     cartItems.remove(item);
     notifyListeners();
   }

  void clearItems() {
     cartItems.clear();
     notifyListeners();
  }
}

final cartProvider = CartProvider();

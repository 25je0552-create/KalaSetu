import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../mock_data/mock_data_loader.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartController extends StateNotifier<List<CartItem>> {
  CartController() : super([]);

  void addItem(Product product) {
    final idx = state.indexWhere((item) => item.product.id == product.id);
    if (idx != -1) {
      final updated = List<CartItem>.from(state);
      updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + 1);
      state = updated;
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int delta) {
    final idx = state.indexWhere((item) => item.product.id == productId);
    if (idx == -1) return;

    final newQty = state[idx].quantity + delta;
    if (newQty <= 0) {
      removeItem(productId);
    } else {
      final updated = List<CartItem>.from(state);
      updated[idx] = updated[idx].copyWith(quantity: newQty);
      state = updated;
    }
  }

  void clear() {
    state = [];
  }
}

final cartControllerProvider = StateNotifierProvider<CartController, List<CartItem>>((ref) {
  return CartController();
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartControllerProvider);
  return items.fold(0, (sum, i) => sum + i.quantity);
});

final cartTotalAmountProvider = Provider<double>((ref) {
  final items = ref.watch(cartControllerProvider);
  return items.fold(0.0, (sum, i) => sum + (i.product.price * i.quantity));
});

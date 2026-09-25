import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../mock_data/mock_data_loader.dart';

abstract class ProductRepository {
  // Real impl later: GET /api/products
  Future<List<Product>> getProducts({String? category, String? cluster});
  
  // Real impl later: GET /api/products/:id
  Future<Product?> getProductById(String id);
}

class MockProductRepository implements ProductRepository {
  List<Product>? _cachedProducts;

  @override
  Future<List<Product>> getProducts({String? category, String? cluster}) async {
    _cachedProducts ??= await MockDataLoader.loadProducts();
    var list = _cachedProducts!;
    if (category != null && category.isNotEmpty) {
      list = list.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
    }
    if (cluster != null && cluster.isNotEmpty) {
      list = list.where((p) => p.cluster.toLowerCase().contains(cluster.toLowerCase())).toList();
    }
    return list;
  }

  @override
  Future<Product?> getProductById(String id) async {
    _cachedProducts ??= await MockDataLoader.loadProducts();
    try {
      return _cachedProducts!.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return MockProductRepository();
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProducts();
});

final productDetailProvider = FutureProvider.family<Product?, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProductById(id);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../mock_data/mock_data_loader.dart';

abstract class OrderRepository {
  // Real impl later: GET /api/orders?artisanId=:id
  Future<List<ArtisanOrder>> getArtisanOrders();
}

class MockOrderRepository implements OrderRepository {
  @override
  Future<List<ArtisanOrder>> getArtisanOrders() async {
    return MockDataLoader.loadOrders();
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return MockOrderRepository();
});

final artisanOrdersProvider = FutureProvider<List<ArtisanOrder>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getArtisanOrders();
});

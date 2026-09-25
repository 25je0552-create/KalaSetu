import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../mock_data/mock_data_loader.dart';

abstract class FairRepository {
  // Real impl later: GET /api/fairs
  Future<List<CraftFair>> getFairs();
  
  // Real impl later: POST /api/fairs/:id/apply
  Future<bool> applyForFair(String fairId);
}

class MockFairRepository implements FairRepository {
  List<CraftFair>? _cached;

  @override
  Future<List<CraftFair>> getFairs() async {
    _cached ??= await MockDataLoader.loadFairs();
    return _cached!;
  }

  @override
  Future<bool> applyForFair(String fairId) async {
    return true;
  }
}

final fairRepositoryProvider = Provider<FairRepository>((ref) {
  return MockFairRepository();
});

final craftFairsProvider = FutureProvider<List<CraftFair>>((ref) async {
  final repo = ref.watch(fairRepositoryProvider);
  return repo.getFairs();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../mock_data/mock_data_loader.dart';

abstract class FairRepository {
  // Real impl later: GET /api/fairs
  Future<List<CraftFair>> getFairs();
  
  // Real impl later: POST /api/fairs/:id/apply
  Future<bool> applyForFair(String fairId);

  // Real impl later: GET /api/fairs/:id
  Future<CraftFair?> getFairById(String id);
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

  @override
  Future<CraftFair?> getFairById(String id) async {
    _cached ??= await MockDataLoader.loadFairs();
    try {
      return _cached!.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}

final fairRepositoryProvider = Provider<FairRepository>((ref) {
  return MockFairRepository();
});

final craftFairsProvider = FutureProvider<List<CraftFair>>((ref) async {
  final repo = ref.watch(fairRepositoryProvider);
  return repo.getFairs();
});

final fairDetailProvider = FutureProvider.family<CraftFair?, String>((ref, id) async {
  final repo = ref.watch(fairRepositoryProvider);
  return repo.getFairById(id);
});

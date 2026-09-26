import 'package:flutter/foundation.dart';
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
    debugPrint('[MockFairRepository] getFairs() called. Cached count: ${_cached?.length}');
    if (_cached == null || _cached!.isEmpty) {
      _cached = await MockDataLoader.loadFairs();
    }
    debugPrint('[MockFairRepository] getFairs() returning ${_cached!.length} fairs');
    return _cached!;
  }

  @override
  Future<bool> applyForFair(String fairId) async {
    debugPrint('[MockFairRepository] applyForFair($fairId) called');
    return true;
  }

  @override
  Future<CraftFair?> getFairById(String id) async {
    debugPrint('[MockFairRepository] getFairById($id) called');
    if (_cached == null || _cached!.isEmpty) {
      _cached = await MockDataLoader.loadFairs();
    }
    try {
      final fair = _cached!.firstWhere((f) => f.id == id);
      debugPrint('[MockFairRepository] Found fair: ${fair.titleEn}');
      return fair;
    } catch (_) {
      debugPrint('[MockFairRepository] Fair not found for id: $id');
      return null;
    }
  }
}

final fairRepositoryProvider = Provider<FairRepository>((ref) {
  return MockFairRepository();
});

final craftFairsProvider = FutureProvider<List<CraftFair>>((ref) async {
  debugPrint('[craftFairsProvider] Provider triggered. Fetching fairs from repository...');
  final repo = ref.watch(fairRepositoryProvider);
  final fairs = await repo.getFairs();
  debugPrint('[craftFairsProvider] Provider received ${fairs.length} fairs');
  return fairs;
});

final fairDetailProvider = FutureProvider.family<CraftFair?, String>((ref, id) async {
  debugPrint('[fairDetailProvider] Provider triggered for fairId: $id');
  final repo = ref.watch(fairRepositoryProvider);
  return repo.getFairById(id);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../mock_data/mock_data_loader.dart';

abstract class ArtisanRepository {
  // Real impl later: GET /api/artisans/:id
  Future<Artisan?> getArtisanById(String id);
}

class MockArtisanRepository implements ArtisanRepository {
  @override
  Future<Artisan?> getArtisanById(String id) async {
    final list = await MockDataLoader.loadArtisans();
    try {
      return list.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

final artisanRepositoryProvider = Provider<ArtisanRepository>((ref) {
  return MockArtisanRepository();
});

final currentArtisanProvider = FutureProvider<Artisan?>((ref) async {
  final repo = ref.watch(artisanRepositoryProvider);
  return repo.getArtisanById('art_1');
});

final artisanByIdProvider = FutureProvider.family<Artisan?, String>((ref, id) async {
  final repo = ref.watch(artisanRepositoryProvider);
  return repo.getArtisanById(id);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/home_repository.dart';
import '../data/models/perumahan_model.dart';

final homeRepositoryProvider = Provider((ref) => HomeRepository());

final perumahanListProvider = FutureProvider<List<Perumahan>>((ref) {
  final repo = ref.read(homeRepositoryProvider);
  return repo.getPerumahanList();
});

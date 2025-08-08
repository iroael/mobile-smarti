import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perumahanAsync = ref.watch(perumahanListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Perumahan')),
      body: perumahanAsync.when(
        data:
            (list) => ListView.builder(
              itemCount: list.length,
              itemBuilder:
                  (_, i) => ListTile(
                    title: Text(list[i].nama),
                    subtitle: Text('ID: ${list[i].id}'),
                  ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

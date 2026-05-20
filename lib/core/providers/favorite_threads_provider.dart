import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kFavThreads = 'favorite_message_thread_ids';

final favoriteThreadIdsProvider =
    StateNotifierProvider<FavoriteThreadIdsNotifier, Set<int>>((ref) {
  return FavoriteThreadIdsNotifier();
});

class FavoriteThreadIdsNotifier extends StateNotifier<Set<int>> {
  FavoriteThreadIdsNotifier() : super({}) {
    _hydrate();
  }

  Future<void> _hydrate() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_kFavThreads) ?? [];
    final ids = <int>{};
    for (final s in raw) {
      final v = int.tryParse(s);
      if (v != null) ids.add(v);
    }
    state = ids;
  }

  Future<void> toggle(int threadId) async {
    final next = Set<int>.from(state);
    if (next.contains(threadId)) {
      next.remove(threadId);
    } else {
      next.add(threadId);
    }
    state = next;
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_kFavThreads, next.map((e) => '$e').toList());
  }

  bool isFavorite(int threadId) => state.contains(threadId);
}

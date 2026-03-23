import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/session_controller.dart';
import '../../features/auth/application/session_state.dart';

class RouterRefreshListenable extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerRefreshListenableProvider = Provider<RouterRefreshListenable>((
  ref,
) {
  final listenable = RouterRefreshListenable();

  ref.listen<SessionState>(sessionControllerProvider, (previous, next) {
    listenable.refresh();
  });
  ref.onDispose(listenable.dispose);

  return listenable;
});

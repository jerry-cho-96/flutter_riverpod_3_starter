import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import '../core/logging/app_logger.dart';
import '../core/logging/app_provider_observer.dart';
import 'app.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  const logger = DebugAppLogger();

  runApp(
    ProviderScope(
      observers: <ProviderObserver>[AppProviderObserver(logger)],
      child: const App(),
    ),
  );
}

import 'package:flutter/material.dart';

import '../../core/config/app_environment.dart';

class EnvironmentBanner extends StatelessWidget {
  const EnvironmentBanner({
    super.key,
    required this.environment,
    required this.child,
  });

  final AppEnvironment environment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (environment == AppEnvironment.production) {
      return child;
    }

    return Banner(
      message: environment.value.toUpperCase(),
      location: BannerLocation.topEnd,
      child: child,
    );
  }
}

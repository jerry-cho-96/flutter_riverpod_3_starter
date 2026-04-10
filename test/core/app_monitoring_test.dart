import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/logging/app_monitoring.dart';

void main() {
  group('DebugAppMonitoring', () {
    test('breadcrumb 는 최대 개수까지만 유지한다', () {
      final monitoring = DebugAppMonitoring(maxBreadcrumbs: 2);

      monitoring.recordBreadcrumb('first');
      monitoring.recordBreadcrumb('second');
      monitoring.recordBreadcrumb('third');

      expect(monitoring.breadcrumbs, hasLength(2));
      expect(monitoring.breadcrumbs.first, contains('second'));
      expect(monitoring.breadcrumbs.last, contains('third'));
    });

    test('error 기록 후에도 최근 breadcrumb 는 유지된다', () {
      final monitoring = DebugAppMonitoring(maxBreadcrumbs: 2);

      monitoring.recordBreadcrumb('bootstrap');
      monitoring.recordError('provider failed', error: Exception('boom'));

      expect(monitoring.breadcrumbs.single, contains('bootstrap'));
    });
  });
}

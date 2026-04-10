import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/result/query_result_cache.dart';

void main() {
  group('QueryResultCache', () {
    test('같은 key 의 진행 중 요청을 재사용한다', () async {
      final cache = QueryResultCache<String, int>();
      final completer = Completer<int>();
      var loadCount = 0;

      final firstFuture = cache.run('products', () {
        loadCount += 1;
        return completer.future;
      });
      final secondFuture = cache.run('products', () {
        loadCount += 1;
        return Future<int>.value(2);
      });

      completer.complete(1);

      expect(await firstFuture, 1);
      expect(await secondFuture, 1);
      expect(loadCount, 1);
    });

    test('성공 결과를 캐시하고 clear 로 비운다', () async {
      final cache = QueryResultCache<String, int>();
      var nextValue = 1;
      Future<int> loader() async => nextValue++;

      expect(await cache.run('products', loader), 1);
      expect(await cache.run('products', loader), 1);

      cache.clear();

      expect(await cache.run('products', loader), 2);
    });

    test('shouldCache 가 false 이면 결과를 저장하지 않는다', () async {
      final cache = QueryResultCache<String, int>();
      var loadCount = 0;

      Future<int> loader() async {
        loadCount += 1;
        return 1;
      }

      await cache.run('products', loader, shouldCache: (_) => false);
      await cache.run('products', loader, shouldCache: (_) => false);

      expect(loadCount, 2);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/features/home/presentation/screens/invalid_product_detail_screen.dart';

void main() {
  testWidgets('잘못된 상품 경로 화면은 안내 문구를 렌더링한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: InvalidProductDetailScreen()),
    );

    expect(find.text('유효하지 않은 상품 경로입니다.'), findsOneWidget);
  });
}

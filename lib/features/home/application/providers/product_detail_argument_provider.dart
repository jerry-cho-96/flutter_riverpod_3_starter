import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_detail_argument_provider.g.dart';

@riverpod
int productDetailArgument(Ref ref) {
  throw StateError(
    '상품 상세 화면에서 productDetailArgumentProvider 를 override 해야 합니다.',
  );
}

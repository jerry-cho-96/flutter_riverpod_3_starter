import 'package:riverpod_origin_template/core/pagination/page_chunk.dart';
import 'package:riverpod_origin_template/core/storage/token_storage.dart';
import 'package:riverpod_origin_template/features/auth/domain/entities/app_user.dart';
import 'package:riverpod_origin_template/features/auth/domain/entities/auth_session.dart';
import 'package:riverpod_origin_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_origin_template/features/auth/domain/value_objects/auth_tokens.dart';
import 'package:riverpod_origin_template/features/home/domain/entities/product.dart';
import 'package:riverpod_origin_template/features/home/domain/repositories/products_repository.dart';
import 'package:riverpod_origin_template/features/quotes/domain/entities/quote.dart';
import 'package:riverpod_origin_template/features/quotes/domain/repositories/quotes_repository.dart';

AuthTokens createTokens({
  String accessToken = 'access-token',
  String refreshToken = 'refresh-token',
}) {
  return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
}

AppUser createUser({
  int id = 1,
  String username = 'emilys',
  String email = 'emilys@dummyjson.com',
  String firstName = 'Emily',
  String lastName = 'Stone',
  String? image = 'https://cdn.dummyjson.com/users/1.png',
}) {
  return AppUser(
    id: id,
    username: username,
    email: email,
    firstName: firstName,
    lastName: lastName,
    image: image,
  );
}

AuthSession createSession({AuthTokens? tokens, AppUser? user}) {
  return AuthSession(
    user: user ?? createUser(),
    tokens: tokens ?? createTokens(),
  );
}

class FakeTokenStorage implements TokenStorage {
  FakeTokenStorage([AuthTokens? tokens])
    : storedAccessToken = tokens?.accessToken,
      storedRefreshToken = tokens?.refreshToken;

  String? storedAccessToken;
  String? storedRefreshToken;
  int saveCallCount = 0;
  int clearCallCount = 0;

  AuthTokens? get storedTokens {
    final accessToken = storedAccessToken;
    final refreshToken = storedRefreshToken;
    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> clear() async {
    clearCallCount += 1;
    storedAccessToken = null;
    storedRefreshToken = null;
  }

  @override
  Future<String?> readAccessToken() async => storedAccessToken;

  @override
  Future<String?> readRefreshToken() async => storedRefreshToken;

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    saveCallCount += 1;
    storedAccessToken = accessToken;
    storedRefreshToken = refreshToken;
  }
}

class FakeAuthRepository implements AuthRepository {
  final List<Object> currentUserResults = <Object>[];
  Object? signInResult;
  Object? refreshResult;
  int signInCallCount = 0;
  int refreshCallCount = 0;
  int fetchCurrentUserCallCount = 0;

  void enqueueCurrentUserResult(Object result) {
    currentUserResults.add(result);
  }

  @override
  Future<AppUser> fetchCurrentUser() async {
    fetchCurrentUserCallCount += 1;
    if (currentUserResults.isEmpty) {
      throw StateError('No current user response configured');
    }

    final result = currentUserResults.removeAt(0);
    if (result is Exception) {
      throw result;
    }
    if (result is Error) {
      throw result;
    }

    return result as AppUser;
  }

  @override
  Future<AuthTokens> refreshSession({required String refreshToken}) async {
    refreshCallCount += 1;
    return _resolve<AuthTokens>(
      refreshResult,
      fallback: StateError('No refresh result configured'),
    );
  }

  @override
  Future<AuthSession> signIn({
    required String username,
    required String password,
  }) async {
    signInCallCount += 1;
    return _resolve<AuthSession>(
      signInResult,
      fallback: StateError('No sign-in result configured'),
    );
  }

  T _resolve<T>(Object? value, {required Object fallback}) {
    final result = value ?? fallback;
    if (result is Exception) {
      throw result;
    }
    if (result is Error) {
      throw result;
    }

    return result as T;
  }
}

Product createProduct({
  int id = 1,
  String title = 'Doc-friendly Desk Lamp',
  String description = 'A sample product for testing.',
  String category = 'home-decoration',
  double price = 49.99,
  double rating = 4.5,
  int stock = 12,
  String? brand = 'Origin',
  String? thumbnail = 'https://dummyjson.com/image/400x400',
}) {
  return Product(
    id: id,
    title: title,
    description: description,
    category: category,
    price: price,
    rating: rating,
    stock: stock,
    brand: brand,
    thumbnail: thumbnail,
  );
}

PageChunk<Product> createProductPage({
  List<Product>? items,
  int? total,
  int skip = 0,
  int limit = 20,
}) {
  final resolvedItems = items ?? <Product>[createProduct()];
  return PageChunk<Product>(
    items: resolvedItems,
    total: total ?? resolvedItems.length,
    skip: skip,
    limit: limit,
  );
}

class FakeProductsRepository implements ProductsRepository {
  Object? fetchProductsResult;
  Object? fetchProductDetailResult;
  int fetchProductsCallCount = 0;
  int fetchProductDetailCallCount = 0;
  int? lastLimit;
  int? lastSkip;
  int? lastProductId;

  @override
  Future<PageChunk<Product>> fetchProducts({
    required int limit,
    required int skip,
  }) async {
    fetchProductsCallCount += 1;
    lastLimit = limit;
    lastSkip = skip;
    return _resolve<PageChunk<Product>>(
      fetchProductsResult,
      fallback: createProductPage(limit: limit, skip: skip),
    );
  }

  @override
  Future<Product> fetchProductDetail({required int productId}) async {
    fetchProductDetailCallCount += 1;
    lastProductId = productId;
    return _resolve<Product>(
      fetchProductDetailResult,
      fallback: createProduct(id: productId),
    );
  }

  T _resolve<T>(Object? value, {required Object fallback}) {
    final result = value ?? fallback;
    if (result is Exception) {
      throw result;
    }
    if (result is Error) {
      throw result;
    }

    return result as T;
  }
}

Quote createQuote({
  int id = 1,
  String quote = 'Stay close to the architecture.',
  String author = 'Codex',
}) {
  return Quote(id: id, quote: quote, author: author);
}

PageChunk<Quote> createQuotePage({
  List<Quote>? items,
  int? total,
  int skip = 0,
  int limit = 20,
}) {
  final resolvedItems = items ?? <Quote>[createQuote()];
  return PageChunk<Quote>(
    items: resolvedItems,
    total: total ?? resolvedItems.length,
    skip: skip,
    limit: limit,
  );
}

class FakeQuotesRepository implements QuotesRepository {
  Object? fetchQuotesResult;
  int fetchQuotesCallCount = 0;
  int? lastLimit;
  int? lastSkip;

  @override
  Future<PageChunk<Quote>> fetchQuotes({
    required int limit,
    required int skip,
  }) async {
    fetchQuotesCallCount += 1;
    lastLimit = limit;
    lastSkip = skip;
    return _resolve<PageChunk<Quote>>(
      fetchQuotesResult,
      fallback: createQuotePage(limit: limit, skip: skip),
    );
  }

  T _resolve<T>(Object? value, {required Object fallback}) {
    final result = value ?? fallback;
    if (result is Exception) {
      throw result;
    }
    if (result is Error) {
      throw result;
    }

    return result as T;
  }
}

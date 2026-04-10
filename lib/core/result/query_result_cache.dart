class QueryResultCache<K, V extends Object> {
  final Map<K, V> _cache = <K, V>{};
  final Map<K, Future<V>> _inFlight = <K, Future<V>>{};

  Future<V> run(
    K key,
    Future<V> Function() loader, {
    bool Function(V value)? shouldCache,
  }) {
    final cachedValue = _cache[key];
    if (cachedValue != null) {
      return Future<V>.value(cachedValue);
    }

    final pendingValue = _inFlight[key];
    if (pendingValue != null) {
      return pendingValue;
    }

    final future = loader()
        .then((value) {
          if (shouldCache?.call(value) ?? true) {
            _cache[key] = value;
          }
          return value;
        })
        .whenComplete(() {
          _inFlight.remove(key);
        });

    _inFlight[key] = future;
    return future;
  }

  void invalidate(K key) {
    _cache.remove(key);
    _inFlight.remove(key);
  }

  void clear() {
    _cache.clear();
    _inFlight.clear();
  }
}

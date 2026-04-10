class PageChunk<T> {
  const PageChunk({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<T> items;
  final int total;
  final int skip;
  final int limit;
}

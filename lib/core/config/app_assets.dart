class AppAssets {
  const AppAssets._();

  static const String imagesDir = 'assets/images';
  static const String iconsDir = 'assets/icons';

  static String image(String fileName) => '$imagesDir/$fileName';

  static String icon(String fileName) => '$iconsDir/$fileName';
}

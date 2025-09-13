class Category {
  final String slug;
  final String name;
  final String url;

  Category({
    required this.slug,
    required this.name,
    required this.url,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class CategoryWithImage {
  final String name;
  final String image;
  final String slug;

  CategoryWithImage({
    required this.name,
    required this.image,
    required this.slug,
  });
}

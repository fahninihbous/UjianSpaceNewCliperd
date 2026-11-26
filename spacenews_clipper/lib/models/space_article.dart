class SpaceArticle {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;

  SpaceArticle({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
  });

  factory SpaceArticle.fromJson(Map<String, dynamic> json) {
    return SpaceArticle(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Tanpa Judul',
      url: json['url'] ?? '',
      imageUrl: json['image_url'] ?? '',
      newsSite: json['news_site'] ?? 'Unknown Source',
      summary: json['summary'] ?? 'Tidak ada ringkasan.',
      publishedAt: json['published_at'] ?? '',
    );
  }
}
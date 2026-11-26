import 'package:flutter/material.dart';
import '../models/space_article.dart';
import '../routes/app_routing.dart';
import '../services/public_api_service.dart';
import '../theme/space_theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<List<SpaceArticle>> _futureArticles;

  @override
  void initState() {
    super.initState();
    _futureArticles = PublicApiService().fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.rocket_launch, color: SpaceTheme.accentAmber, size: 22),
            SizedBox(width: 8),
            Text('Explore SpaceNews'),
          ],
        ),
      ),
      body: FutureBuilder<List<SpaceArticle>>(
        future: _futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: SpaceTheme.accentAmber));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada berita tersedia.'));
          }

          final articles = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final item = articles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, AppRouting.exploreDetail, arguments: item);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        item.imageUrl,
                        height: 175,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 175,
                          color: SpaceTheme.surfaceElevated,
                          child: const Center(
                            child: Icon(Icons.rocket, size: 50, color: SpaceTheme.accentAmber),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.newsSite.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                      color: SpaceTheme.accentAmber,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.publishedAt.split('T').first,
                                  style: const TextStyle(fontSize: 12, color: SpaceTheme.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
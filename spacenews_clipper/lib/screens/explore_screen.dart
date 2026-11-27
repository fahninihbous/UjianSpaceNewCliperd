import 'dart:async';
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
  Timer? _timer;
  int _index = 0;
  double _progress = 0.0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _futureArticles = PublicApiService().fetchArticles();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int total) {
    _timer?.cancel();
    if (total <= 0) return;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted || _paused) return;
      setState(() {
        _progress += 50 / 7000; // 7 detik per berita sekilas
        if (_progress >= 1.0) _next(total);
      });
    });
  }

  void _next(int total) {
    if (total <= 0) return;
    setState(() {
      _progress = 0.0;
      _index = (_index + 1) % total;
    });
  }

  void _prev(int total) {
    if (total <= 0) return;
    setState(() {
      _progress = 0.0;
      if (_index > 0) _index--;
    });
  }

  void _openDetail(SpaceArticle article) {
    Navigator.pushNamed(context, AppRouting.exploreDetail, arguments: article);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpaceTheme.spaceBg,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<SpaceArticle>>(
          future: _futureArticles,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: SpaceTheme.accentAmber),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final articles = snapshot.data ?? [];
            if (articles.isEmpty) {
              return const Center(child: Text('Tidak ada berita tersedia.'));
            }

            final safeIdx = _index.clamp(0, articles.length - 1);
            if (_timer == null || !_timer!.isActive) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _startTimer(articles.length));
            }

            final topItem = articles[safeIdx];
            const palette = SpaceTheme.pastelCards;
            final cardColor = palette[safeIdx % palette.length];

            return Column(
              children: [
                // HEADER RINGKAS
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.rocket_launch_rounded,
                          color: SpaceTheme.cardTextDark,
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'SpaceNews',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: SpaceTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${safeIdx + 1}/${articles.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          _timer?.cancel();
                          setState(() {
                            _index = 0;
                            _progress = 0.0;
                            _futureArticles = PublicApiService().fetchArticles();
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: SpaceTheme.surfaceCard,
                        ),
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ),

                // KOTAK PERSEGI PANJANG DI ATAS (SEKILAS SAJA, TIDAK BUKA DETAIL)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onLongPressStart: (_) => setState(() => _paused = true),
                    onLongPressEnd: (_) => setState(() => _paused = false),
                    onHorizontalDragEnd: (d) {
                      final v = d.primaryVelocity ?? 0;
                      if (v < -200) _next(articles.length);
                      if (v > 200) _prev(articles.length);
                    },
                    onTapUp: (d) {
                      final width = MediaQuery.of(context).size.width - 32;
                      final localX = d.localPosition.dx;
                      if (localX < width * 0.5) {
                        _prev(articles.length);
                      } else {
                        _next(articles.length);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 176,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildIndicators(articles.length, safeIdx),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE53935),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'SEKILAS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  topItem.newsSite,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: SpaceTheme.cardTextDark,
                                  ),
                                ),
                              ),
                              Text(
                                topItem.publishedAt.split('T').first,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: SpaceTheme.cardTextDark
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        topItem.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: SpaceTheme.cardTextDark,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Expanded(
                                        child: Text(
                                          topItem.summary,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.35,
                                            color: SpaceTheme.cardTextDark
                                                .withValues(alpha: 0.82),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    topItem.imageUrl,
                                    width: 96,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 96,
                                      color: SpaceTheme.cardTextDark
                                          .withValues(alpha: 0.08),
                                      child: const Icon(
                                        Icons.rocket_launch,
                                        color: SpaceTheme.cardTextDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // JUDUL BAGIAN BERITA BERBARIS DI BAWAH
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Berita Terbaru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // DAFTAR BERITA BERBARIS (BISA DIKLIK DETAILNYA)
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: articles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final article = articles[idx];
                      final isCurrentTop = idx == safeIdx;

                      return InkWell(
                        onTap: () => _openDetail(article),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: SpaceTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCurrentTop
                                  ? SpaceTheme.accentAmber
                                  : Colors.white10,
                              width: isCurrentTop ? 1.2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  article.imageUrl,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 72,
                                    height: 72,
                                    color: Colors.white10,
                                    child: const Icon(
                                      Icons.rocket_launch,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            article.newsSite.toUpperCase(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: SpaceTheme.accentAmber,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          article.publishedAt.split('T').first,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      article.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      article.summary,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white54,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildIndicators(int total, int safeIdx) {
    const window = 10;
    final start = (safeIdx ~/ window) * window;
    final count = (start + window).clamp(0, total) - start;

    return Row(
      children: List.generate(count, (i) {
        final idx = start + i;
        final val = idx < safeIdx
            ? 1.0
            : (idx == safeIdx ? _progress.clamp(0.0, 1.0) : 0.0);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == count - 1 ? 0 : 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: val,
                minHeight: 3.5,
                backgroundColor:
                    SpaceTheme.cardTextDark.withValues(alpha: 0.18),
                valueColor:
                    const AlwaysStoppedAnimation(SpaceTheme.cardTextDark),
              ),
            ),
          ),
        );
      }),
    );
  }
}
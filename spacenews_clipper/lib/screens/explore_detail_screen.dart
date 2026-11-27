import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../models/space_article.dart';
import '../services/crud_service.dart';
import '../theme/space_theme.dart';

class ExploreDetailScreen extends StatelessWidget {
  final SpaceArticle article;
  const ExploreDetailScreen({super.key, required this.article});

  Future<void> _showSaveDialog(BuildContext context) async {
    final crudService = CrudService();
    List<MissionModel> missions = [];
    try {
      missions = await crudService.getMissions();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat kategori misi')),
      );
      return;
    }

    if (!context.mounted) return;
    if (missions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buat kategori misi terlebih dahulu di tab Koleksi!'),
        ),
      );
      return;
    }

    int selectedMissionId = missions.first.id;
    final notesCtrl = TextEditingController(text: article.summary);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: SpaceTheme.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: SpaceTheme.borderSubtle),
          ),
          title: const Text(
            'Simpan ke Koleksi',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedMissionId,
                  dropdownColor: SpaceTheme.surfaceElevated,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Kategori Misi',
                  ),
                  items: missions
                      .map(
                        (m) => DropdownMenuItem(value: m.id, child: Text(m.name)),
                      )
                      .toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedMissionId = val!),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ringkasan / Catatan',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Batal',
                style: TextStyle(color: SpaceTheme.textMuted),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SpaceTheme.accentAmber,
                foregroundColor: SpaceTheme.cardTextDark,
              ),
              onPressed: () async {
                final ok = await crudService.createClippedNews(
                  missionId: selectedMissionId,
                  title: article.title,
                  newsSite: article.newsSite,
                  imageUrl: article.imageUrl,
                  notes: notesCtrl.text,
                );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Berhasil disimpan ke Koleksi!'
                          : 'Gagal menyimpan berita',
                    ),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = article.imageUrl.trim().isNotEmpty;
    final publishedDate = article.publishedAt.split('T').first;

    return Scaffold(
      backgroundColor: SpaceTheme.spaceBg,
      body: SafeArea(
        bottom: false,
        child: Container(
          margin: const EdgeInsets.only(top: 6),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: SpaceTheme.accentAmber,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tombol Kembali (Back Arrow)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: SpaceTheme.cardTextDark,
                        size: 26,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 16),

                    // Judul Besar Berita
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: SpaceTheme.cardTextDark,
                        height: 1.22,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Timestamp
                    Text(
                      'Updated $publishedDate',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: SpaceTheme.cardTextDark.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Penerbit
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 19,
                          backgroundColor: SpaceTheme.cardTextDark,
                          child: Text(
                            article.newsSite.isNotEmpty
                                ? article.newsSite[0].toUpperCase()
                                : 'S',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Published by',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: SpaceTheme.cardTextDark
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              Text(
                                article.newsSite,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: SpaceTheme.cardTextDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _showSaveDialog(context),
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Isi Ringkasan Berita
                    Text(
                      article.summary,
                      style: TextStyle(
                        fontSize: 15.5,
                        height: 1.55,
                        color: SpaceTheme.cardTextDark.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Blok Catatan & Sumber agar halaman terasa padat dan terstruktur
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SpaceTheme.cardTextDark.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RINGKASAN KLIPING',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: SpaceTheme.cardTextDark
                                  .withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Media: ${article.newsSite} • Tanggal terbit: $publishedDate',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: SpaceTheme.cardTextDark
                                  .withValues(alpha: 0.85),
                            ),
                          ),
                          if (article.url.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Sumber: ${article.url}',
                              style: TextStyle(
                                fontSize: 12,
                                color: SpaceTheme.cardTextDark
                                    .withValues(alpha: 0.7),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Tampilkan foto hanya jika imageUrl tersedia
                    if (hasImage) ...[
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          article.imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Floating Action Pill di pojok kanan bawah
              Positioned(
                right: 24,
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: SpaceTheme.cardTextDark,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 18),
                      InkWell(
                        onTap: () => _showSaveDialog(context),
                        child: const Icon(
                          Icons.bookmark_add_rounded,
                          color: SpaceTheme.accentAmber,
                          size: 21,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
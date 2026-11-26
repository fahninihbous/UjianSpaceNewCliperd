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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat kategori misi')));
      return;
    }

    if (!context.mounted) return;
    if (missions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buat kategori misi terlebih dahulu di tab Koleksi!')),
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
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: SpaceTheme.borderSubtle),
          ),
          title: const Text('Simpan ke Koleksi', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedMissionId,
                  dropdownColor: SpaceTheme.surfaceElevated,
                  decoration: const InputDecoration(labelText: 'Pilih Kategori Misi'),
                  items: missions.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                  onChanged: (val) => setDialogState(() => selectedMissionId = val!),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Ringkasan / Catatan'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: SpaceTheme.textMuted)),
            ),
            ElevatedButton(
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
                  SnackBar(content: Text(ok ? 'Berhasil disimpan ke Koleksi!' : 'Gagal menyimpan berita')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Berita')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              article.imageUrl,
              height: 235,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 170,
                color: SpaceTheme.surfaceCard,
                child: const Center(child: Icon(Icons.rocket, size: 60, color: SpaceTheme.accentAmber)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sumber: ${article.newsSite} • Rilis: ${article.publishedAt.split('T').first}',
                    style: const TextStyle(color: SpaceTheme.accentAmber, fontSize: 13),
                  ),
                  const Divider(height: 24, color: SpaceTheme.borderSubtle),
                  const Text(
                    'Ringkasan Berita:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.summary,
                    style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFFE2E8F0)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'URL Sumber: ${article.url}',
                    style: const TextStyle(color: SpaceTheme.accentCyan, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.bookmark_add),
                      label: const Text('Simpan ke Koleksi'),
                      onPressed: () => _showSaveDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/mission_model.dart';
import '../models/clipped_news_model.dart';
import '../services/crud_service.dart';
import '../theme/space_theme.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final CrudService _crud = CrudService();
  final ImagePicker _picker = ImagePicker();
  List<MissionModel> _missions = [];
  List<ClippedNewsModel> _newsList = [];
  int? _filterMissionId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _loading = true);
    try {
      final missions = await _crud.getMissions();
      final news = await _crud.getClippedNews(missionId: _filterMissionId);
      if (!mounted) return;
      setState(() {
        _missions = missions;
        _newsList = news;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Dialog Tambah/Edit Tabel 1 (Missions)
  void _showMissionDialog({MissionModel? mission}) {
    final ctrl = TextEditingController(text: mission?.name ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SpaceTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SpaceTheme.borderSubtle),
        ),
        title: Text(
          mission == null ? 'Tambah Kategori Misi' : 'Edit Kategori Misi',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Nama Kategori (mis: Roket, Planet)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: SpaceTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              if (mission == null) {
                await _crud.createMission(ctrl.text.trim());
              } else {
                await _crud.updateMission(mission.id, ctrl.text.trim());
              }
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              _refreshData();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  String _mimeFromFileName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  Uint8List? _bytesFromImageValue(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('data:image')) {
      final commaIdx = value.indexOf(',');
      if (commaIdx == -1) return null;
      try {
        return base64Decode(value.substring(commaIdx + 1));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Dialog Tambah/Edit Tabel 2 (Clipped News) dengan Pilih File Foto
  void _showNewsDialog({ClippedNewsModel? news}) {
    if (_missions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi tab Kategori Misi terlebih dahulu!')),
      );
      return;
    }

    int selectedMission = news?.missionId ?? _missions.first.id;
    final titleCtrl = TextEditingController(text: news?.title ?? '');
    final siteCtrl = TextEditingController(text: news?.newsSite ?? '');
    final notesCtrl = TextEditingController(text: news?.notes ?? '');

    String imageValue = news?.imageUrl ?? '';
    Uint8List? previewBytes = _bytesFromImageValue(imageValue);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> pickPhoto() async {
            try {
              final XFile? picked = await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 75,
                maxWidth: 1024,
              );
              if (picked == null) return;
              final bytes = await picked.readAsBytes();
              final mime = _mimeFromFileName(picked.name);
              if (!ctx.mounted) return;
              setDialogState(() {
                previewBytes = bytes;
                imageValue = 'data:$mime;base64,${base64Encode(bytes)}';
              });
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal membuka file foto: $e')),
              );
            }
          }

          return AlertDialog(
            backgroundColor: SpaceTheme.surfaceCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: SpaceTheme.borderSubtle),
            ),
            title: Text(
              news == null ? 'Tambah Berita Manual' : 'Edit Koleksi Berita',
              style: const TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedMission,
                    dropdownColor: SpaceTheme.surfaceElevated,
                    decoration: const InputDecoration(labelText: 'Kategori Misi'),
                    items: _missions.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                    onChanged: (v) => setDialogState(() => selectedMission = v!),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Berita')),
                  const SizedBox(height: 10),
                  TextField(controller: siteCtrl, decoration: const InputDecoration(labelText: 'Sumber Berita')),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: SpaceTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SpaceTheme.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        if (previewBytes != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              previewBytes!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ] else if (imageValue.startsWith('http')) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageValue,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: pickPhoto,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: SpaceTheme.accentAmber,
                                  side: const BorderSide(color: SpaceTheme.accentAmber),
                                ),
                                icon: const Icon(Icons.photo_library_outlined, size: 18),
                                label: Text(previewBytes != null || imageValue.isNotEmpty ? 'Ganti Foto' : 'Pilih Foto'),
                              ),
                            ),
                            if (previewBytes != null || imageValue.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Hapus foto',
                                icon: const Icon(Icons.close, color: Color(0xFFF87171)),
                                onPressed: () => setDialogState(() {
                                  previewBytes = null;
                                  imageValue = '';
                                }),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: notesCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Catatan / Ringkasan')),
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
                  if (titleCtrl.text.trim().isEmpty) return;
                  if (news == null) {
                    await _crud.createClippedNews(
                      missionId: selectedMission,
                      title: titleCtrl.text.trim(),
                      newsSite: siteCtrl.text.trim(),
                      imageUrl: imageValue,
                      notes: notesCtrl.text.trim(),
                    );
                  } else {
                    await _crud.updateClippedNews(
                      id: news.id,
                      missionId: selectedMission,
                      title: titleCtrl.text.trim(),
                      newsSite: siteCtrl.text.trim(),
                      imageUrl: imageValue,
                      notes: notesCtrl.text.trim(),
                    );
                  }
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  _refreshData();
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Koleksi Saya'),
          bottom: const TabBar(
            indicatorColor: SpaceTheme.accentAmber,
            indicatorWeight: 3,
            labelColor: SpaceTheme.accentAmber,
            unselectedLabelColor: SpaceTheme.textMuted,
            tabs: [
              Tab(text: 'Berita Tersimpan'),
              Tab(text: 'Kategori Misi'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: SpaceTheme.accentAmber))
            : TabBarView(
                children: [
                  // TAB 1: ITEM BERITA (TABEL 2)
                  Scaffold(
                    floatingActionButton: FloatingActionButton(
                      onPressed: () => _showNewsDialog(),
                      child: const Icon(Icons.add),
                    ),
                    body: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: DropdownButtonFormField<int?>(
                            value: _filterMissionId,
                            dropdownColor: SpaceTheme.surfaceElevated,
                            decoration: const InputDecoration(
                              labelText: 'Filter Kategori Misi',
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(value: null, child: Text('Semua Kategori')),
                              ..._missions.map((m) => DropdownMenuItem<int?>(value: m.id, child: Text(m.name))),
                            ],
                            onChanged: (val) {
                              setState(() => _filterMissionId = val);
                              _refreshData();
                            },
                          ),
                        ),
                        Expanded(
                          child: _newsList.isEmpty
                              ? const Center(
                                  child: Text('Belum ada berita tersimpan.', style: TextStyle(color: SpaceTheme.textMuted)),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: _newsList.length,
                                  itemBuilder: (ctx, i) {
                                    final item = _newsList[i];
                                    final bytes = _bytesFromImageValue(item.imageUrl);
                                    return Card(
                                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        leading: bytes != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.memory(bytes, width: 52, height: 52, fit: BoxFit.cover),
                                              )
                                            : (item.imageUrl != null && item.imageUrl!.startsWith('http')
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.network(
                                                      item.imageUrl!,
                                                      width: 52,
                                                      height: 52,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => const Icon(
                                                        Icons.image_not_supported_outlined,
                                                        color: SpaceTheme.textMuted,
                                                      ),
                                                    ),
                                                  )
                                                : null),
                                        title: Text(
                                          item.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            '${item.mission?.name ?? '-'} • ${item.notes ?? ''}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: SpaceTheme.textMuted, fontSize: 12),
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: SpaceTheme.accentCyan),
                                              onPressed: () => _showNewsDialog(news: item),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Color(0xFFF87171)),
                                              onPressed: () async {
                                                await _crud.deleteClippedNews(item.id);
                                                _refreshData();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),

                  // TAB 2: KATEGORI MISI (TABEL 1)
                  Scaffold(
                    floatingActionButton: FloatingActionButton(
                      onPressed: () => _showMissionDialog(),
                      child: const Icon(Icons.add),
                    ),
                    body: _missions.isEmpty
                        ? const Center(
                            child: Text('Belum ada kategori misi.', style: TextStyle(color: SpaceTheme.textMuted)),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                            itemCount: _missions.length,
                            itemBuilder: (ctx, i) {
                              final m = _missions[i];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.folder_special, color: SpaceTheme.accentAmber),
                                  title: Text(m.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: SpaceTheme.accentCyan),
                                        onPressed: () => _showMissionDialog(mission: m),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Color(0xFFF87171)),
                                        onPressed: () async {
                                          await _crud.deleteMission(m.id);
                                          if (_filterMissionId == m.id) _filterMissionId = null;
                                          _refreshData();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
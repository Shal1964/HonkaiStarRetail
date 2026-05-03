import 'package:flutter/material.dart';
import 'package:honkai_star_retail/pages/admin_galacticResources.dart';
import 'package:provider/provider.dart';
import '../provider/item_provider.dart';
import 'admin_lightCones.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  static const Color _boxColor = Color(0xFF918EA1);
  static const double _boxOpacity = 0.37;

  // ── Navigasi ke lightcones page ───────────────────────────────────────────
  void _goToLightCones(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminLightCones()),
    ).then((_) {
      context.read<ItemProvider>().loadItems();
    });
  }

  // ── Navigasi ke galactic resources page ──────────────────────────────────
  void _goToGalacticResources(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminGalacticResources()),
    ).then((_) {
      context.read<ItemProvider>().loadItems();
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // EDIT DIALOG — Light Cone (punya rarity int)
  // ════════════════════════════════════════════════════════════════════════════
  void _showEditLightCone(BuildContext context, LightConeModel item) {
    final provider        = context.read<ItemProvider>();
    final nameController  = TextEditingController(text: item.name);
    final stockController = TextEditingController(text: item.stock.toString());
    int selectedRarity    = item.rarity; // 3, 4, atau 5

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1433),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              title: const Text(
                'Edit Light Cone',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field Nama
                    const Text('Nama', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Nama light cone...',
                        hintStyle: const TextStyle(color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field Stock
                    const Text('Stock', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: stockController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Jumlah stock...',
                        hintStyle: const TextStyle(color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rarity Bintang (3/4/5 saja)
                    const Text('Rarity', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (i) {
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedRarity = i + 1),
                          child: Icon(
                            i < selectedRarity ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFFCC00),
                            size: 28,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB57BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final newName  = nameController.text.trim();
                    final newStock = int.tryParse(stockController.text.trim());
                    if (newName.isEmpty || newStock == null) return;

                    Navigator.pop(ctx);

                    await provider.editLightCone(
                      item.id,
                      name:   newName,
                      stock:  newStock,
                      rarity: selectedRarity,
                    );
                  },
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // EDIT DIALOG — Galactic Resource (tidak punya rarity)
  // ════════════════════════════════════════════════════════════════════════════
  void _showEditGalacticResource(BuildContext context, GalacticResourceModel item) {
    final provider        = context.read<ItemProvider>();
    final nameController  = TextEditingController(text: item.name);
    final stockController = TextEditingController(text: item.stock.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1433),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Text(
            'Edit Galactic Resource',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Field Nama
                const Text('Nama', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Nama resource...',
                    hintStyle: const TextStyle(color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 16),

                // Field Stock
                const Text('Stock', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: stockController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Jumlah stock...',
                    hintStyle: const TextStyle(color: Colors.white38),
                  ),
                ),
                // tidak ada rarity di sini
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB57BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final newName  = nameController.text.trim();
                final newStock = int.tryParse(stockController.text.trim());
                if (newName.isEmpty || newStock == null) return;

                Navigator.pop(ctx);

                await provider.editGalacticResource(
                  item.id,
                  name:  newName,
                  stock: newStock,
                );
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DELETE DIALOG — Light Cone
  // ════════════════════════════════════════════════════════════════════════════
  void _showDeleteLightCone(BuildContext context, LightConeModel item) {
    final provider = context.read<ItemProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1433),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Hapus Light Cone?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Yakin ingin menghapus "${item.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB57BFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteLightCone(item.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DELETE DIALOG — Galactic Resource
  // ════════════════════════════════════════════════════════════════════════════
  void _showDeleteGalacticResource(BuildContext context, GalacticResourceModel item) {
    final provider = context.read<ItemProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1433),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Hapus Galactic Resource?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Yakin ingin menghapus "${item.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB57BFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteGalacticResource(item.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<ItemProvider>(
      builder: (context, provider, _) {
        // Muat data pertama kali jika kedua list masih kosong dan tidak loading
        if (provider.lightCones.isEmpty &&
            provider.galacticResources.isEmpty &&
            !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.loadItems();
          });
        }

        // Gabungkan 5 terbaru dari masing-masing kategori untuk ditampilkan
        // di section RECENTS — diurutkan berdasarkan id terbesar
        final recentLC = provider.recentLightCones;
        final recentGR = provider.recentGalacticResources;

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/galaxy_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF1A1333),
                          Color(0xFF2D1B69),
                          Color(0xFF0D0820),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // --- Top Bar ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // --- Dashboard Title ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _boxColor.withValues(alpha: _boxOpacity),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.dashboard,
                                color: Colors.white.withValues(alpha: 0.8), size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'DASHBOARD',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- Tombol Kategori ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _CategoryButton(
                              onTap: () => _goToLightCones(context),
                              count: provider.lightConeCount,
                              label: 'Light Cones',
                              fallbackIcon: Icons.style_outlined,
                              icon: Image.asset(
                                'assets/images/lightConesIcon.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _CategoryButton(
                              onTap: () => _goToGalacticResources(context),
                              count: provider.galacticResourceCount,
                              label: 'Galactic Resources',
                              fallbackIcon: Icons.inventory_2_outlined,
                              icon: Image.asset('assets/images/GalacticResourcesIcon.png'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- Recents ---
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Header Recents ──────────────────────────────
                            Row(
                              children: [
                                const Text(
                                  'RECENTS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7B5EA7).withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${recentLC.length + recentGR.length} terbaru',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Expanded(
                              child: provider.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFB57BFF),
                                      ),
                                    )
                                  : provider.error != null
                                      ? Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.wifi_off,
                                                  color: Colors.white30, size: 40),
                                              const SizedBox(height: 8),
                                              Text(
                                                provider.error!,
                                                style: const TextStyle(
                                                    color: Colors.white38,
                                                    fontSize: 13),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 12),
                                              TextButton(
                                                onPressed: () => provider.loadItems(),
                                                child: const Text('Coba lagi',
                                                    style: TextStyle(
                                                        color: Color(0xFFB57BFF))),
                                              ),
                                            ],
                                          ),
                                        )
                                      : (recentLC.isEmpty && recentGR.isEmpty)
                                          ? Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.inbox_outlined,
                                                      color: Colors.white30,
                                                      size: 48),
                                                  const SizedBox(height: 12),
                                                  const Text(
                                                    'Belum ada item.\nTambahkan via Light Cones\natau Galactic Resources.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white38,
                                                        fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : ListView(
                                              children: [
                                                // ── Section: Light Cones ──
                                                if (recentLC.isNotEmpty) ...[
                                                  _SectionLabel(
                                                    icon: Icons.style_outlined,
                                                    label: 'Light Cones',
                                                  ),
                                                  const SizedBox(height: 8),
                                                  ...recentLC.map((item) =>
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 12),
                                                      child: _RecentLightConeCard(
                                                        item: item,
                                                        onEdit: () => _showEditLightCone(context, item),
                                                        onDelete: () => _showDeleteLightCone(context, item),
                                                      ),
                                                    ),
                                                  ),
                                                ],

                                                // ── Section: Galactic Resources ──
                                                if (recentGR.isNotEmpty) ...[
                                                  _SectionLabel(
                                                    icon: Icons.inventory_2_outlined,
                                                    label: 'Galactic Resources',
                                                  ),
                                                  const SizedBox(height: 8),
                                                  ...recentGR.map((item) =>
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 12),
                                                      child: _RecentGalacticResourceCard(
                                                        item: item,
                                                        onEdit: () => _showEditGalacticResource(context, item),
                                                        onDelete: () => _showDeleteGalacticResource(context, item),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// WIDGET: Label section pemisah di Recents
// ============================================================
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 14),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// WIDGET: Kartu Recent — Light Cone (tampilkan rarity bintang)
// ============================================================
class _RecentLightConeCard extends StatelessWidget {
  final LightConeModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const Color _boxColor = Color(0xFF918EA1);
  static const double _boxOpacity = 0.37;

  const _RecentLightConeCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _boxColor.withValues(alpha: _boxOpacity),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          // Thumbnail
          Stack(
            children: [
              Container(
                width: 70,
                height: 85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF6B4FA0),
                ),
                child: item.imagePath != null && item.imagePath!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          item.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image_outlined,
                                color: Colors.white54, size: 28),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image_outlined,
                            color: Colors.white54, size: 28),
                      ),
              ),
              // Badge kategori
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.style_outlined,
                      color: Colors.white70, size: 12),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Rarity bintang (int: 3/4/5)
                _RarityStars(rarity: item.rarity),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ActionButton(
                        icon: Icons.edit_outlined, label: 'Edit', onTap: onEdit),
                    const SizedBox(width: 8),
                    _ActionButton(
                        icon: Icons.delete_outline, label: 'Delete', onTap: onDelete),
                    const Spacer(),
                    Text(
                      'Stock : ${item.stock}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET: Kartu Recent — Galactic Resource (TANPA rarity)
// ============================================================
class _RecentGalacticResourceCard extends StatelessWidget {
  final GalacticResourceModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const Color _boxColor = Color(0xFF918EA1);
  static const double _boxOpacity = 0.37;

  const _RecentGalacticResourceCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _boxColor.withValues(alpha: _boxOpacity),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          // Thumbnail
          Stack(
            children: [
              Container(
                width: 70,
                height: 85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF6B4FA0),
                ),
                child: item.imagePath != null && item.imagePath!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          item.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image_outlined,
                                color: Colors.white54, size: 28),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image_outlined,
                            color: Colors.white54, size: 28),
                      ),
              ),
              // Badge kategori
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: Colors.white70, size: 12),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Tipe resource sebagai badge pengganti bintang
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B5EA7).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.type,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ActionButton(
                        icon: Icons.edit_outlined, label: 'Edit', onTap: onEdit),
                    const SizedBox(width: 8),
                    _ActionButton(
                        icon: Icons.delete_outline, label: 'Delete', onTap: onDelete),
                    const Spacer(),
                    Text(
                      'Stock : ${item.stock}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET: Rarity Bintang — pakai int (3/4/5), bukan double
// ============================================================
class _RarityStars extends StatelessWidget {
  final int rarity;
  const _RarityStars({required this.rarity});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < rarity ? Icons.star : Icons.star_border,
          color: const Color(0xFFFFCC00),
          size: 16,
        );
      }),
    );
  }
}

// ============================================================
// WIDGET: Tombol Kategori — tidak berubah
// ============================================================
class _CategoryButton extends StatelessWidget {
  final VoidCallback onTap;
  final int count;
  final String label;
  final Widget? icon;
  final IconData fallbackIcon;

  static const Color _boxColor = Color(0xFF918EA1);
  static const double _boxOpacity = 0.37;

  const _CategoryButton({
    required this.onTap,
    required this.count,
    required this.label,
    required this.fallbackIcon,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _boxColor.withValues(alpha: _boxOpacity),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: icon ?? Icon(fallbackIcon, color: Colors.white, size: 40),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B5EA7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: Tombol Aksi kecil — tidak berubah
// ============================================================
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF7B5EA7).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF9B7EC8).withValues(alpha: 0.6), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 13),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
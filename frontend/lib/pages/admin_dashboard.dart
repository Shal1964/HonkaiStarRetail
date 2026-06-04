import 'package:flutter/material.dart';
import 'package:honkai_star_retail/pages/admin_galacticResources.dart';
import 'package:provider/provider.dart';
import '../provider/item_provider.dart';
import 'admin_lightCones.dart';
import 'login_page.dart';
import '../provider/theme_provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  static const Color _boxColor = Color(0xFF918EA1);
  static const double _boxOpacity = 0.37;

  void _logout(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
}

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

  // EDIT DIALOG — Light Cone 
  void _showEditLightCone(BuildContext context, LightConeModel item) {
    final TextEditingController controller = TextEditingController(text: item.stock.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Stock',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Stock',
            labelStyle: const TextStyle(color: Colors.white60),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white30),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFB57BFF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ctx.watch<ThemeProvider>().actionButtonColor,
              //backgroundColor: const Color(0xFF7B4FD4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final newStock = int.tryParse(controller.text);
              if (newStock != null) {
                // Update ke Database Backend secara permanen
                final success = await context.read<ItemProvider>().editLightCone(
                  item.id, 
                  stock: newStock
                );
                
                if (success && ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Stock Light Cone berhasil diupdate!')),
                  );
                }
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


  // ════════════════════════════════════════════════════════════════════════════
  // EDIT DIALOG — Galactic Resource (Sama persis dengan admin_galacticResources)
  // ════════════════════════════════════════════════════════════════════════════
  void _showEditGalacticResource(BuildContext context, GalacticResourceModel item) {
    final TextEditingController controller = TextEditingController(text: item.stock.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Stock',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Stock',
            labelStyle: const TextStyle(color: Colors.white60),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white30),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFB57BFF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ctx.watch<ThemeProvider>().actionButtonColor,
              //backgroundColor: const Color(0xFF7B4FD4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final newStock = int.tryParse(controller.text);
              if (newStock != null) {
                // Update ke Database Backend secara permanen
                final success = await context.read<ItemProvider>().editGalacticResource(
                  item.id, 
                  stock: newStock
                );

                if (success && ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Stock Galactic Resource berhasil diupdate!')),
                  );
                }
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
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
              backgroundColor: ctx.watch<ThemeProvider>().actionButtonColor,
              //backgroundColor: const Color(0xFFB57BFF),
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
              backgroundColor: ctx.watch<ThemeProvider>().actionButtonColor,
              //backgroundColor: const Color(0xFFB57BFF),
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
                  context.watch<ThemeProvider>().backgroundImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/galaxy_bg.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Positioned.fill(
              //   child: Image.asset(
              //     'assets/images/galaxy_bg.png',
              //     fit: BoxFit.cover,
              //     errorBuilder: (_, __, ___) => Container(
              //       decoration: const BoxDecoration(
              //         gradient: LinearGradient(
              //           begin: Alignment.topCenter,
              //           end: Alignment.bottomCenter,
              //           colors: [
              //             Color(0xFF1A1333),
              //             Color(0xFF2D1B69),
              //             Color(0xFF0D0820),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // Positioned.fill(
              //   child: Image.asset(
              //     'assets/images/galaxy_bg.png',
              //     fit: BoxFit.cover,
              //     errorBuilder: (_, __, ___) => Container(
              //       decoration: const BoxDecoration(
              //         gradient: LinearGradient(
              //           begin: Alignment.topCenter,
              //           end: Alignment.bottomCenter,
              //           colors: [
              //             Color(0xFF1A1333),
              //             Color(0xFF2D1B69),
              //             Color(0xFF0D0820),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              SafeArea(
                child: Column(
                  children: [
                    // --- Top Bar ---
                    // --- Top Bar ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, _) {
                              return PopupMenuButton<String>(
                                icon: const Icon(Icons.menu, color: Colors.white),
                                color: const Color(0xFF1E1A3A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onSelected: (value) {
                                  if (value == 'dark_mode') {
                                    themeProvider.toggleTheme();
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'dark_mode',
                                    child: Row(
                                      children: [
                                        Icon(
                                          themeProvider.isDarkMode
                                              ? Icons.light_mode
                                              : Icons.dark_mode,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          // IconButton(
                          //   icon: const Icon(Icons.menu, color: Colors.white),
                          //   onPressed: () {},
                          // ),

                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                                (route) => false,
                              );
                            },
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
                          color: context.watch<ThemeProvider>().boxColor.withValues(alpha: _boxOpacity),
                          //color: _boxColor.withValues(alpha: _boxOpacity),
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
        color: context.watch<ThemeProvider>().boxColor.withValues(alpha: _boxOpacity),
        // color: _boxColor.withValues(alpha: _boxOpacity),
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
                  color: context.watch<ThemeProvider>().thumbnailBoxColor,
                ),
              // Container(
              //   width: 70,
              //   height: 85,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(10),
              //     color: const Color(0xFF6B4FA0),
              //   ),
               child: item.imagePath != null && item.imagePath!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: item.imagePath!.startsWith('http')
                            ? Image.network(
                                item.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.image_outlined, color: Colors.white54, size: 28),
                                ),
                              )
                            : Image.asset(
                                item.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.image_outlined, color: Colors.white54, size: 28),
                                ),
                              ),
                      )
                    : const Center(
                        child: Icon(Icons.image_outlined, color: Colors.white54, size: 28),
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
        color: context.watch<ThemeProvider>().boxColor.withValues(alpha: _boxOpacity),
        //color: _boxColor.withValues(alpha: _boxOpacity),
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
                  color: context.watch<ThemeProvider>().thumbnailBoxColor,
                  //color: const Color(0xFF6B4FA0),
                ),
                child: item.imagePath != null && item.imagePath!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: item.imagePath!.startsWith('http')
                            ? Image.network(
                                item.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.image_outlined, color: Colors.white54, size: 28),
                                ),
                              )
                            : Image.asset(
                                item.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.image_outlined, color: Colors.white54, size: 28),
                                ),
                              ),
                      )
                    : const Center(
                        child: Icon(Icons.image_outlined, color: Colors.white54, size: 28),
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
                    color:  const Color(0xFF49369E).withValues(alpha: 0.5),
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
          color: context.watch<ThemeProvider>().boxColor.withValues(alpha: _boxOpacity),
          //color: _boxColor.withValues(alpha: _boxOpacity),
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
                  color: context.watch<ThemeProvider>().isDarkMode
                      ? const Color(0xFF2854C3).withValues(alpha : 0.8)
                      : const Color(0xFF7B5EA7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                // Container(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFF7B5EA7),
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                  // child: Text(
                  //   '$count',
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
          color: context.watch<ThemeProvider>().actionButtonColor,
          //color: const Color(0xFF49369E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all( 
            color: context.watch<ThemeProvider>().actionButtonColor, width: 1,),
          // border: Border.all(
          //     color:  const Color(0xFF49369E), width: 1),
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
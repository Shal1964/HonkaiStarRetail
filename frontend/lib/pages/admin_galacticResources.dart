import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/item_provider.dart'; 
import 'admin_addGalacticResources.dart';
import '../provider/theme_provider.dart';

class AdminGalacticResources extends StatefulWidget {
  const AdminGalacticResources({super.key});

  @override
  State<AdminGalacticResources> createState() => _AdminGalacticResourcesState();
}

class _AdminGalacticResourcesState extends State<AdminGalacticResources> {
  void _showEditDialog(GalacticResourceModel item) {
    final TextEditingController controller =
        TextEditingController(text: item.stock.toString());

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
              backgroundColor: context.watch<ThemeProvider>().actionButtonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final newStock = int.tryParse(controller.text);
              if (newStock != null) {
                final success = await context.read<ItemProvider>().editGalacticResource(
                  item.id, 
                  stock: newStock
                );

                if (success && ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Stock berhasil diupdate di database!')),
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

  void _confirmDelete(GalacticResourceModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.watch<ThemeProvider>().actionButtonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              context.read<ItemProvider>().deleteGalacticResource(item.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _goToAddItems() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminAddGalacticResources()),
    );
  }

  Widget _buildGalacticResourceCard(GalacticResourceModel item) {
     final themeProvider = context.watch<ThemeProvider>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: themeProvider.boxColor.withValues(alpha: 0.20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color : themeProvider.boxColor.withValues(alpha: 0.20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                  width: 1,
                ),
              ),
              child: item.imagePath != null && item.imagePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: item.imagePath!.startsWith('http')
                          ? Image.network(
                              item.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 28),
                              ),
                            )
                          : Image.asset(
                              item.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 28),
                              ),
                            ),
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 28),
                    ),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
              
                  Row(
                    children: [
                      _buildSmallButton(
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                        color: themeProvider.actionButtonColor,//const Color(0xFF49369E),
                        onPressed: () => _showEditDialog(item),
                      ),
                      const SizedBox(width: 8),
                      _buildSmallButton(
                        label: 'Delete',
                        icon: Icons.delete_outline,
                        color: themeProvider.actionButtonColor,//const Color(0xFF49369E),
                        onPressed: () => _confirmDelete(item),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Stock : ${item.stock}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 13),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.37),
            width: 1,
          ),
        ),
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
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

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: themeProvider.boxColor.withValues(alpha: 0.20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.37),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            'assets/images/GalacticResourcesIcon.png',
                            width: 24,
                            height: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Galactic Resources',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Consumer<ItemProvider>(
                    builder: (context, provider, child) {
                      final items = provider.galacticResources;

                      if (items.isEmpty) {
                        return const Center(
                          child: Text(
                            'No galactic resources found.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: items.length,
                        itemBuilder: (_, i) => _buildGalacticResourceCard(items[i]),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _goToAddItems,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                              themeProvider.boxColor.withValues(alpha: 0.20),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.37),
                          ),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'ADD ITEMS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class AddGalacticResourcePage extends StatefulWidget {
  const AddGalacticResourcePage({super.key});

  @override
  State<AddGalacticResourcePage> createState() => _AddGalacticResourcePageState();
}

class _AddGalacticResourcePageState extends State<AddGalacticResourcePage> {
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  double _selectedRating = 5.0;

  Widget _buildTextField(TextEditingController ctrl, String hint, {bool isNumber = false}) {
    final themeProvider = context.watch<ThemeProvider>();
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: themeProvider.boxColor.withValues(alpha: 0.20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB57BFF)),
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF1A1333), 
      appBar: AppBar(
        title: const Text('Add Galactic Resource', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1433),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Name', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            _buildTextField(_nameController, 'Galactic Resource Name...'),
            const SizedBox(height: 24),

            const Text('Stock', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            _buildTextField(_stockController, 'Amount of stock...', isNumber: true),
            const SizedBox(height: 24),

            const Text('Rating / Rarity', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = i + 1.0;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      i < _selectedRating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFD700),
                      size: 36,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  final stock = int.tryParse(_stockController.text.trim());
                  
                  if (name.isEmpty || stock == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields correctly')),
                    );
                    return;
                  }

                  final provider = context.read<ItemProvider>();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.watch<ThemeProvider>().actionButtonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'SAVE ITEM',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
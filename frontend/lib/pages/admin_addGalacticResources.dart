import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../session.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';

// ============================================================
// ADMIN ADD GALACTIC RESOURCES PAGE
// ============================================================
class AdminAddGalacticResources extends StatefulWidget {
  const AdminAddGalacticResources({super.key});

  @override
  State<AdminAddGalacticResources> createState() => _AdminAddGalacticResourcesState();
}

class _AdminAddGalacticResourcesState extends State<AdminAddGalacticResources>
    with SingleTickerProviderStateMixin {

  // ── Controllers — masing-masing field punya controller sendiri ───────────
  final _nameController            = TextEditingController();
  final _resourceTypeController    = TextEditingController(); // sub-type
  final _descriptionController     = TextEditingController();
  final _stockController           = TextEditingController();
  final _priceController           = TextEditingController();
  final _imageController           = TextEditingController();

  // ── State ───────────────────────────────────────────────────────────────
  double _selectedStar = 5.0;
  bool   _isLoading    = false;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameController.dispose();
    _resourceTypeController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  // ── Kirim data ke Node.js → MySQL ────────────────────────────────────────
  Future<void> _saveItem() async {
    final name        = _nameController.text.trim();
    final subType     = _resourceTypeController.text.trim();
    final description = _descriptionController.text.trim();
    final stock       = int.tryParse(_stockController.text.trim());
    final price       = double.tryParse(_priceController.text.trim());
    final image       = _imageController.text.trim();

    if (name.isEmpty) {
      _showSnack('Item name is required.', isError: true); return;
    }
    if (stock == null) {
      _showSnack('Stock must be a valid number.', isError: true); return;
    }
    if (price == null || price <= 0) {
      _showSnack('Price must be greater than 0.', isError: true); return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${Session.baseUrl}/galactic-resources'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Session.token}',
        },
        body: jsonEncode({
            'name':        name,
            'type':        'Galactic Resources', 
            'description': subType.isNotEmpty
                ? '$subType${description.isNotEmpty ? ' — $description' : ''}'
                : description,
            'stock':       stock,
            'image':       image.isNotEmpty ? image : null,
            'price':       price,
          }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack('Item saved successfully!');
        if (mounted) Navigator.pop(context, true);
      } else {
        final body = jsonDecode(response.body);
        _showSnack(body['error'] ?? 'Failed to save item.', isError: true);
      }
    } catch (e) {
      _showSnack('Cannot connect to server. Is it running?', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? const Color(0xFF8B2A2A) : const Color(0xFF2A4A2A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── UI Helpers ───────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 13, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    bool isNumber = false,
    bool isMultiline = false,
  }) {
    final themeProvider = context.watch<ThemeProvider>();
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      keyboardType: isNumber
          ? TextInputType.number
          : isMultiline
              ? TextInputType.multiline
              : TextInputType.text,
      maxLines: isMultiline ? 3 : 1,
      decoration: InputDecoration(
        filled: true,
        // fillColor: themeProvider.boxColor.withValues(alpha: 0.37),
        //fillColor: const Color(0xFF918EA1).withValues(alpha: 0.20),
        fillColor: themeProvider.boxColor.withValues(alpha: 0.20),
        hintText: hint,
        hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.18), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              const BorderSide(color: Color(0xFFB57BFF), width: 1.5),
        ),
      ),
    );
  }

  // ── Section divider ──────────────────────────────────────────────────────
  Widget _buildSectionDivider(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
                color: Colors.white.withValues(alpha: 0.12), thickness: 1),
          ),
        ],
      ),
    );
  }

  // ── Bintang rarity interaktif ────────────────────────────────────────────
  Widget _buildStarPicker() {
    return Row(
      children: List.generate(5, (i) {
        return GestureDetector(
          onTap: () => setState(() => _selectedStar = i + 1.0),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              i < _selectedStar
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: const Color(0xFFFFD700),
              size: 36,
            ),
          ),
        );
      }),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // ── Background Image ────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              themeProvider.backgroundImage,
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

          // ── Konten ─────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Header ───────────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      margin: const EdgeInsets.only(bottom: 28),
                      decoration: BoxDecoration(
                        color: themeProvider.boxColor.withValues(alpha: 0.20),
                        //color: const Color(0xFF918EA1).withValues(alpha: 0.37),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.37)),
                      ),
                      child: const Text(
                        'ADD ITEMS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),

                    // ── Items Name ───────────────────────────────────────
                    _buildLabel('Items Name'),
                    _buildTextField(_nameController, 'Enter item name...'),
                    const SizedBox(height: 20),

                    // ── Item Type (Read-Only) ────────────────────────────
                    _buildLabel('Item Type'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10), 
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10), 
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Galactic Resources', // Teks otomatis untuk halaman ini
                        style: TextStyle(
                          color: Colors.white, // Diubah menjadi putih sesuai request sebelumnya
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Resource Type ────────────────────────────────────
                    _buildLabel('Resource Type'),
                    _buildTextField(
                      _resourceTypeController, 
                      'e.g. Ascension Material, Consumable...',
                    ),
                    const SizedBox(height: 20),

                    // ── Star / Rarity ────────────────────────────────────
                    _buildLabel('Star / Rarity'),
                    _buildStarPicker(),
                    const SizedBox(height: 20),

                    // ── Stock ────────────────────────────────────────────
                    _buildLabel('Stock'),
                    _buildTextField(_stockController, 'e.g. 10', isNumber: true),
                    const SizedBox(height: 20),

                    // ── Price ────────────────────────────────────────────
                    _buildLabel('Price'),
                    _buildTextField(_priceController, 'e.g. 15000', isNumber: true),
                    const SizedBox(height: 20),

                    // ── Description ──────────────────────────────────────
                    _buildLabel('Description'),
                    _buildTextField(
                      _descriptionController,
                      'Enter description...',
                      isMultiline: true,
                    ),
                    const SizedBox(height: 20),

                    // ── Image URL ────────────────────────────────────────────
                    _buildLabel('Image URL (Opsional)'),
                    _buildTextField(_imageController, 'Paste image link here (https://...)'),
                    const SizedBox(height: 20),

                    // ── Tombol Save ──────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              // const Color(0xFF918EA1).withValues(alpha: 0.37),
                              themeProvider.boxColor.withValues(alpha: 0.20),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              //const Color(0xFF918EA1).withValues(alpha: 0.15),
                              themeProvider.boxColor.withValues(alpha: 0.20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.37)),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'SAVE ITEM',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../session.dart';

// class DetailPage extends StatefulWidget {
//   final int itemId;
//   const DetailPage({super.key, required this.itemId});

//   @override
//   State<DetailPage> createState() => _DetailPageState();
// }

// class _DetailPageState extends State<DetailPage> {
//   Map<String, dynamic>? item;
//   bool isLoading = true;
//   final quantityController = TextEditingController(text: '1');
//   String message = '';
//   bool isError = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchItem();
//   }

//   // GET /resources/:id - Get single resource
//   Future<void> fetchItem() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${Session.baseUrl}/resources/${widget.itemId}'),
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           item = jsonDecode(response.body);
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }

//   // =============================================
//   // VALIDATION 3: Ensure buy quantity > 0
//   // =============================================
//   Future<void> buyItem() async {
//     final qty = int.tryParse(quantityController.text.trim());

//     if (qty == null || qty <= 0) {
//       setState(() {
//         message = 'Quantity must be a number greater than 0';
//         isError = true;
//       });
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('${Session.baseUrl}/resources/${widget.itemId}/buy'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${Session.token}',
//         },
//         body: jsonEncode({'quantity': qty}),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         setState(() {
//           message = '${data['message']} (Total: ${data['totalCost']} Credits)';
//           isError = false;
//         });
//         fetchItem(); // Refresh stock
//       } else {
//         setState(() {
//           message = data['error'] ?? 'Purchase failed';
//           isError = true;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         message = 'Cannot connect to server';
//         isError = true;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Loading...')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (item == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Error')),
//         body: const Center(child: Text('Item not found', style: TextStyle(color: Colors.white))),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: Text(item!['name'] ?? '')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Item image
//             Center(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Image.network(
//                   item!['image'] ?? '',
//                   width: 200,
//                   height: 200,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     width: 200,
//                     height: 200,
//                     color: Colors.grey[800],
//                     child: const Icon(Icons.image, size: 60, color: Colors.grey),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Type badge
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.primary.withAlpha(40),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 item!['type'] ?? '',
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.primary,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),

//             // Name
//             Text(
//               item!['name'] ?? '',
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 8),

//             // Description
//             Text(
//               item!['description'] ?? '',
//               style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
//             ),
//             const SizedBox(height: 16),

//             // Price and Stock
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '${item!['price']} Credits',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Theme.of(context).colorScheme.secondary,
//                   ),
//                 ),
//                 Text(
//                   'Stock: ${item!['stock']}',
//                   style: TextStyle(color: Colors.grey[400], fontSize: 16),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),

//             const Divider(color: Colors.grey),
//             const SizedBox(height: 16),

//             // Buy section
//             const Text(
//               'Purchase',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//             const SizedBox(height: 12),

//             // Message
//             if (message.isNotEmpty)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 margin: const EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(
//                   color: isError ? Colors.red.withAlpha(30) : Colors.green.withAlpha(30),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   message,
//                   style: TextStyle(
//                     color: isError ? Colors.redAccent : Colors.greenAccent,
//                   ),
//                 ),
//               ),

//             Row(
//               children: [
//                 // Quantity input
//                 Expanded(
//                   child: TextField(
//                     controller: quantityController,
//                     keyboardType: TextInputType.number,
//                     style: const TextStyle(color: Colors.white),
//                     decoration: const InputDecoration(hintText: 'Quantity'),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 // Buy button
//                 ElevatedButton(
//                   onPressed: buyItem,
//                   child: const Text('Buy Now'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

 
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../provider/item_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════

const _kPurple      = Color(0xFF49369E);
const _kBlack25     = Color(0x40000000);   // 000000 @ 25%
const _kFooterBg    = Color(0x40000000);   // 000000 @ 25% — footer container
const _kDescBg      = Color(0x5E918EA1);   // 918EA1 @ 37% — description box
const _kPurpleGlass = Color(0x406D6598);   // 6D6598 @ 25% — container utama
const _kPurple80    = Color(0xCC49369E);   // 49369E @ 80%
const _kGold        = Color(0xFFFFD700);
const _kLabelGold   = Color(0xFFEDC531);

// ═══════════════════════════════════════════════════════════════════════════════
// DETAIL PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class DetailPage extends StatefulWidget {
  final int itemId;
  const DetailPage({super.key, required this.itemId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _qty = 1;

  _ResolvedItem? _resolve(ItemProvider p) {
    try {
      return _ResolvedItem.lc(p.lightCones.firstWhere((e) => e.id == widget.itemId));
    } catch (_) {}
    try {
      return _ResolvedItem.gr(p.galacticResources.firstWhere((e) => e.id == widget.itemId));
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/Explore_bg.png', fit: BoxFit.cover),
          ),
          Consumer<ItemProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              final resolved = _resolve(provider);
              if (resolved == null) {
                return const Center(
                    child: Text('Item not found', style: TextStyle(color: Colors.white)));
              }
              return resolved.isLc
                  ? _LightConeDetail(
                      item: resolved.lc!,
                      provider: provider,
                      qty: _qty,
                      onQtyChanged: (v) => setState(() => _qty = v),
                      currentId: widget.itemId,
                    )
                  : _GalacticDetail(
                      item: resolved.gr!,
                      provider: provider,
                      qty: _qty,
                      onQtyChanged: (v) => setState(() => _qty = v),
                      currentId: widget.itemId,
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _ResolvedItem {
  final LightConeModel? lc;
  final GalacticResourceModel? gr;
  bool get isLc => lc != null;
  const _ResolvedItem.lc(LightConeModel m) : lc = m, gr = null;
  const _ResolvedItem.gr(GalacticResourceModel m) : lc = null, gr = m;
}

// ═══════════════════════════════════════════════════════════════════════════════
// LIGHT CONE DETAIL
// ═══════════════════════════════════════════════════════════════════════════════

class _LightConeDetail extends StatelessWidget {
  final LightConeModel item;
  final ItemProvider provider;
  final int qty;
  final ValueChanged<int> onQtyChanged;
  final int currentId;

  const _LightConeDetail({
    required this.item,
    required this.provider,
    required this.qty,
    required this.onQtyChanged,
    required this.currentId,
  });

  static const _iconMap = {
    'the hunt':     'assets/images/TheHunt.png',
    'destruction':  'assets/images/Destruction.png',
    'erudition':    'assets/images/Erudition.png',
    'harmony':      'assets/images/Harmony.png',
    'nihility':     'assets/images/Nihility.png',
    'preservation': 'assets/images/Preservation.png',
    'abundance':    'assets/images/Abundance.png',
  };

  Widget _typeIcon(String type, {double size = 20}) {
    final asset = _iconMap[type.toLowerCase()];
    if (asset != null) {
      return Image.asset(asset, width: size, height: size, color: Colors.white,
          errorBuilder: (_, __, ___) => Icon(Icons.category, color: Colors.white, size: size));
    }
    return Icon(Icons.category, color: Colors.white, size: size);
  }

  List<LightConeModel> get _others =>
      provider.lightCones.where((e) => e.id != currentId).take(6).toList();

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final total  = item.price * qty;

    return Padding(
      padding: EdgeInsets.fromLTRB(14, top + 10, 14, bottom + 14),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _kPurpleGlass,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
        ),
        child: Column(
          children: [

            // ── HEADER (dalam container) ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _TopBar(label: 'Light Cone Details'),
            ),

            // ── KONTEN SCROLLABLE ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Nama
                      Center(
                        child: Text(
                          item.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Gambar + Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SleeveCardImage(imagePath: item.imagePath),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                // Type + icon
                                Row(
                                  children: [
                                    _typeIcon(item.type, size: 22),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.type,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Rarity
                                Row(
                                  children: [
                                    const Text('Rarity : ',
                                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                                    ...List.generate(
                                      item.rarity.clamp(1, 5),
                                      (_) => const Icon(Icons.star, color: _kGold, size: 15),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                // Qty +/-
                                _QtyControl(qty: qty, stock: item.stock, onChanged: onQtyChanged),
                                const SizedBox(height: 10),
                                // Price
                                Text(
                                  'Price : \$${item.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),
                      _DescriptionBox(description: item.description),
                      const SizedBox(height: 22),

                      // Other Light Cones
                      if (_others.isNotEmpty) ...[
                        const Text('Other Light Cones',
                            style: TextStyle(
                                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 178,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _others.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (ctx, i) => _OtherLCCard(item: _others[i]),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // ── FOOTER (dalam container) ─────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: _kFooterBg,
                border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.10), width: 1)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'US \$${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  GestureDetector(
                    onTap: () => _onCheckout(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: _kPurple80,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/Galatic.png',
                            width: 20,
                            height: 20,
                            color: Colors.white,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Checkout',
                            style: TextStyle(
                                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
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

  void _onCheckout(BuildContext context) {
    if (item.stock < qty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout failed. Insufficient stock.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => _CheckoutDialog(
        name: item.name,
        qty: qty,
        total: item.price * qty,
        onConfirm: () async {
          Navigator.pop(context); // Tutup dialog konfirmasi
          
          // Mengurangi stok secara permanen di database
          final ok = await provider.editLightCone(item.id, stock: item.stock - qty);
          
          if (context.mounted) {
            if (ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checkout successful! Stock updated.')),
              );
              Navigator.pop(context); // Kembali ke halaman Home setelah sukses
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checkout failed. Please try again.')),
              );
            }
          }
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GALACTIC RESOURCE DETAIL
// ═══════════════════════════════════════════════════════════════════════════════

class _GalacticDetail extends StatelessWidget {
  final GalacticResourceModel item;
  final ItemProvider provider;
  final int qty;
  final ValueChanged<int> onQtyChanged;
  final int currentId;

  const _GalacticDetail({
    required this.item,
    required this.provider,
    required this.qty,
    required this.onQtyChanged,
    required this.currentId,
  });

  List<GalacticResourceModel> get _others =>
      provider.galacticResources.where((e) => e.id != currentId).take(6).toList();

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final total  = item.price * qty;

    return Padding(
      padding: EdgeInsets.fromLTRB(14, top + 10, 14, bottom + 14),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _kPurpleGlass,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
        ),
        child: Column(
          children: [

            // ── HEADER (dalam container) ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _TopBar(label: 'Galactic Resources Details'),
            ),

            // ── KONTEN SCROLLABLE ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Nama
                      Center(
                        child: Text(
                          item.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Gambar + Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _GalacticImage(imagePath: item.imagePath),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  'Price : \$${item.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 12),
                                _QtyControl(qty: qty, stock: item.stock, onChanged: onQtyChanged),
                                const SizedBox(height: 10),
                                Text('Stock: ${item.stock}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),
                      _DescriptionBox(description: item.description),
                      const SizedBox(height: 22),

                      // Other Galactic Resources
                      if (_others.isNotEmpty) ...[
                        const Text('Other Galactic Resources',
                            style: TextStyle(
                                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _others.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (ctx, i) => _OtherGalacticCard(item: _others[i]),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // ── FOOTER (dalam container) ─────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: _kFooterBg,
                border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.10), width: 1)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'US \$${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  GestureDetector(
                    onTap: () => _onCheckout(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: _kPurple80,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/Galatic.png',
                            width: 20,
                            height: 20,
                            color: Colors.white,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Checkout',
                            style: TextStyle(
                                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
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
  void _onCheckout(BuildContext context) {
    if (item.stock < qty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout failed. Insufficient stock.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => _CheckoutDialog(
        name: item.name,
        qty: qty,
        total: item.price * qty,
        onConfirm: () async {
          Navigator.pop(context); // Tutup dialog konfirmasi
          
          // Mengurangi stok secara permanen di database
          final ok = await provider.editGalacticResource(item.id, stock: item.stock - qty);
          
          if (context.mounted) {
            if (ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checkout successful! Stock updated.')),
              );
              Navigator.pop(context); // Kembali ke halaman Home setelah sukses
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checkout failed. Please try again.')),
              );
            }
          }
        },
      ),
    );
  }
  
  
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Top Bar ────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String label;
  const _TopBar({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 13),
              const SizedBox(width: 4),
              Text('Back',
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
            ],
          ),
        ),
        Text(label,
            style: const TextStyle(
                color: _kLabelGold, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Sleeve Card Image — double frame, tegak ─────────────────────────────────────
class _SleeveCardImage extends StatelessWidget {
  final String? imagePath;
  const _SleeveCardImage({this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 195,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 140,
              height: 182,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.30), width: 1.5),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 140,
              height: 182,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.70), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.55),
                    blurRadius: 18,
                    offset: const Offset(3, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.5),
                child: _buildImage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath == null || imagePath!.isEmpty) {
      return _ph();
    }

    // ✅ SAMA PERSIS DENGAN HOME
    if (imagePath!.startsWith('http')) {
      return Image.network(
        imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ph(),
      );
    } else {
      return Image.asset(
        imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ph(),
      );
    }
  }

  Widget _ph() {
    return Container(
      color: Colors.white.withOpacity(0.07),
      child: const Center(
        child: Icon(Icons.image, color: Colors.white24, size: 40),
      ),
    );
  }
}

// ── Galactic Image ─────────────────────────────────────────────────────────────
class _GalacticImage extends StatelessWidget {
  final String? imagePath;
  const _GalacticImage({this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x40000000),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.50),
            blurRadius: 16,
            offset: const Offset(3, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath == null || imagePath!.isEmpty) {
      return _ph();
    }

    // ✅ SAMA DENGAN HOME
    if (imagePath!.startsWith('http')) {
      return Image.network(
        imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ph(),
      );
    } else {
      return Image.asset(
        imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ph(),
      );
    }
  }

  Widget _ph() {
    return Container(
      color: Colors.white.withOpacity(0.07),
      child: const Center(
        child: Icon(Icons.image, color: Colors.white24, size: 40),
      ),
    );
  }
}

// ── Qty Control +/- ────────────────────────────────────────────────────────────
class _QtyControl extends StatelessWidget {
  final int qty;
  final int stock;
  final ValueChanged<int> onChanged;
  const _QtyControl({required this.qty, required this.stock, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // + tombol
        _QtyBtn(
          label: '+',
          active: qty < stock,
          onTap: qty < stock ? () => onChanged(qty + 1) : null,
        ),
        // Angka tengah
        Container(
          width: 40,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _kBlack25,
            border: Border.symmetric(
              horizontal: BorderSide(color: Colors.white.withOpacity(0.15), width: 1),
            ),
          ),
          child: Text(
            '$qty',
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        // - tombol
        _QtyBtn(
          label: '−',
          active: qty > 1,
          onTap: qty > 1 ? () => onChanged(qty - 1) : null,
        ),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;
  const _QtyBtn({required this.label, required this.active, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? _kPurple80 : _kBlack25,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? _kPurple80 : Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white.withOpacity(0.30),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ── Description Box ────────────────────────────────────────────────────────────
class _DescriptionBox extends StatelessWidget {
  final String? description;
  const _DescriptionBox({this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: _kDescBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.22))),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('Description',
                    style: TextStyle(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.22))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description ?? 'No description available.',
            style:
                TextStyle(color: Colors.white.withOpacity(0.80), fontSize: 13, height: 1.65),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OTHER LIGHT CONE CARD — SAMA PERSIS dengan home page card, ukuran diperbesar
// ═══════════════════════════════════════════════════════════════════════════════

class _OtherLCCard extends StatelessWidget {
  final LightConeModel item;
  const _OtherLCCard({required this.item});

  static const _iconMap = {
    'the hunt':           'assets/images/TheHunt.png',
    'destruction':        'assets/images/Destruction.png',
    'erudition':          'assets/images/Erudition.png',
    'harmony':            'assets/images/Harmony.png',
    'nihility':           'assets/images/Nihility.png',
    'preservation':       'assets/images/Preservation.png',
    'abundance':          'assets/images/Abundance.png',
    'galactic resources': 'assets/images/Galatic.png',
  };

  Widget _typeIconWidget(String type) {
    final asset = _iconMap[type.toLowerCase()];
    if (asset != null) {
      return Image.asset(asset, width: 14, height: 14, color: Colors.white,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.category, color: Colors.white, size: 12));
    }
    return const Icon(Icons.category, color: Colors.white, size: 12);
  }

  Widget _placeholder() => Container(
        color: Colors.white.withOpacity(0.08),
        child: const Center(child: Icon(Icons.person, size: 40, color: Colors.white24)),
      );

  @override
  Widget build(BuildContext context) {
    // Gradient & bottomBar warna SAMA dengan home page (_purpleTheme)
    const gradientColors = [
      Color(0xFFA13BCA),
      Color(0xFFA13BCA),
      Color(0xFFA13BCA),
    ];

    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DetailPage(itemId: item.id)),
      ),
      child: Container(
        // Lebih besar dari home (home: ~W=?, H=?), di sini W=137, H=178
        width: 137,
        height: 178,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFA13BCA).withOpacity(0.05),
              const Color(0xFFA13BCA).withOpacity(0.05),
              const Color(0xFFA13BCA).withOpacity(0.60),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.30),
                blurRadius: 14,
                offset: const Offset(0, 5)),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.10), width: 0.8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // ── Bottom glow bar (sama dengan home) ──────────────
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 9,
                  color: const Color(0xFFA13BCA).withOpacity(0.65),
                ),
              ),

              // ── Top shimmer (sama dengan home) ──────────────────
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Konten (Column sama persis dengan home) ──────────
              Column(
                children: [
                  // Type icon di kiri atas
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: _typeIconWidget(item.type)),
                        ),
                      ],
                    ),
                  ),

                  // Gambar miring (sama dengan home, diperbesar)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 4, 6, 25),
                      child: Center(
                        child: Transform.rotate(
                          angle: 0.08 * math.pi / 2,
                          child: Container(
                            width: 78,   // home: 55 → diperbesar
                            height: 100, // home: 70 → diperbesar
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.22),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 0.8,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: item.imagePath != null && item.imagePath!.isNotEmpty
                                  ? (item.imagePath!.startsWith('http')
                                      ? Image.network(
                                          item.imagePath!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _placeholder(),
                                        )
                                      : Image.asset(
                                          item.imagePath!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _placeholder(),
                                        ))
                                  : _placeholder(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Nama
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Text(
                      item.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),

                  // Bintang rarity
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        item.rarity.clamp(1, 5),
                        (_) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.5),
                          child: Icon(Icons.star, color: _kGold, size: 11),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OTHER GALACTIC CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _OtherGalacticCard extends StatelessWidget {
  final GalacticResourceModel item;
  const _OtherGalacticCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DetailPage(itemId: item.id)),
      ),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _kBlack25,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.imagePath != null && item.imagePath!.isNotEmpty
                  ? Image.network(item.imagePath!, width: 65, height: 65, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          width: 65, height: 65, color: Colors.white.withOpacity(0.08)))
                  : Container(width: 65, height: 65, color: Colors.white.withOpacity(0.08)),
            ),
            const SizedBox(height: 6),
            Text(item.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('\$${item.price.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: _kLabelGold, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CHECKOUT DIALOG
// ═══════════════════════════════════════════════════════════════════════════════

class _CheckoutDialog extends StatelessWidget {
  final String name;
  final int qty;
  final double total;
  final VoidCallback onConfirm;

  const _CheckoutDialog({
    required this.name,
    required this.qty,
    required this.total,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1335),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined, color: _kPurple, size: 40),
            const SizedBox(height: 12),
            const Text('Confirm Purchase',
                style: TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text('${qty}x $name',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
            const SizedBox(height: 6),
            Text('Total: US \$${total.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: _kLabelGold, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.30)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child:
                        const Text('Cancel', style: TextStyle(color: Colors.white70)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPurple80,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Buy',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
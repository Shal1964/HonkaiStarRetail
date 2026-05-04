// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../session.dart';
// import 'detail_page.dart';
// import 'admin_dashboard.dart';
// import 'login_page.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   List<dynamic> resources = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchResources();
//   }

//   // GET /resources - Retrieve all resources
//   Future<void> fetchResources() async {
//     setState(() => isLoading = true);
//     try {
//       final response = await http.get(Uri.parse('${Session.baseUrl}/resources'));
//       if (response.statusCode == 200) {
//         setState(() {
//           resources = jsonDecode(response.body);
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }

//   void logout() {
//     Session.token = '';
//     Session.role = '';
//     Session.name = '';
//     Session.email = '';
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Honkai Star Retail'),
//         automaticallyImplyLeading: false,
//         actions: [
//           // Show admin button if admin
//           if (Session.role == 'admin')
//             IconButton(
//               icon: const Icon(Icons.admin_panel_settings),
//               tooltip: 'Admin Panel',
//               onPressed: () async {
//                 await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const AdminDashboard()),
//                 );
//                 fetchResources(); // Refresh after admin changes
//               },
//             ),
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: 'Logout',
//             onPressed: logout,
//           ),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Welcome message
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome, ${Session.name}!',
//                   style: const TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Browse galactic resources & light cones',
//                   style: TextStyle(color: Colors.grey[400], fontSize: 14),
//                 ),
//               ],
//             ),
//           ),

//           // Resource list
//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : RefreshIndicator(
//                     onRefresh: fetchResources,
//                     // UI COMPONENT: ListView
//                     child: ListView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       itemCount: resources.length,
//                       itemBuilder: (context, index) {
//                         final item = resources[index];
//                         return Card(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.all(12),
//                             // UI COMPONENT: Image
//                             leading: ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.network(
//                                 item['image'] ?? '',
//                                 width: 60,
//                                 height: 60,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (_, __, ___) => Container(
//                                   width: 60,
//                                   height: 60,
//                                   color: Colors.grey[800],
//                                   child: const Icon(Icons.image, color: Colors.grey),
//                                 ),
//                               ),
//                             ),
//                             // UI COMPONENT: Text
//                             title: Text(
//                               item['name'] ?? '',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   item['type'] ?? '',
//                                   style: TextStyle(color: Colors.grey[400], fontSize: 12),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   '${item['price']} Credits',
//                                   style: TextStyle(
//                                     color: Theme.of(context).colorScheme.secondary,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             trailing: Text(
//                               'Stock: ${item['stock']}',
//                               style: TextStyle(color: Colors.grey[400]),
//                             ),
//                             onTap: () async {
//                               await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => DetailPage(itemId: item['id']),
//                                 ),
//                               );
//                               fetchResources(); // Refresh after buying
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../session.dart';
// import 'login_page.dart';
// import 'detail_page.dart';
// import 'admin_dashboard.dart';

// // ═══════════════════════════════════════════════════════════════════════════════
// // APP COLORS
// // ═══════════════════════════════════════════════════════════════════════════════

// class AppColors {
//   static const starGold = Color(0xFFFFD700);
//   static const navBar   = Color(0xFF07071A);
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // CARD COLOR THEME — semua kuning
// // ═══════════════════════════════════════════════════════════════════════════════

// class _CardTheme {
//   final List<Color> gradient;
//   final Color bottomBar;
//   const _CardTheme({required this.gradient, required this.bottomBar});
// }

// _CardTheme get _yellowTheme => _CardTheme(
//   gradient: [
//     Color(0XFFF3DD8A).withOpacity(0.05),
//     Color(0XFFF3DD8A).withOpacity(0.05),
//     Color(0XFFF3DD8A).withOpacity(0.6),
//   ],
//   bottomBar: Color(0xFFF3DD8A).withOpacity(0.8),
// );

// // ═══════════════════════════════════════════════════════════════════════════════
// // TYPE CATEGORY — hardcode 9 type, tidak dari DB
// // ═══════════════════════════════════════════════════════════════════════════════

// class _PathCategory {
//   final String label;
//   final String? iconAsset; // null = pakai Icons.grid_view
//   const _PathCategory({required this.label, this.iconAsset});
// }

// // 9 type hardcode — tidak boleh dikurangi
// const List<_PathCategory> kCategories = [
//   _PathCategory(label: 'All',                iconAsset: null),
//   _PathCategory(label: 'The Hunt',           iconAsset: 'assets/images/TheHunt.png'),
//   _PathCategory(label: 'Destruction',        iconAsset: 'assets/images/Destruction.png'),
//   _PathCategory(label: 'Erudition',          iconAsset: 'assets/images/Erudition.png'),
//   _PathCategory(label: 'Harmony',            iconAsset: 'assets/images/Harmony.png'),
//   _PathCategory(label: 'Nihility',           iconAsset: 'assets/images/Nihility.png'),
//   _PathCategory(label: 'Preservation',       iconAsset: 'assets/images/Preservation.png'),
//   _PathCategory(label: 'Abundance',          iconAsset: 'assets/images/Abundance.png'),
//   _PathCategory(label: 'Galactic Resources', iconAsset: 'assets/images/Galatic.png'),
// ];

// // ═══════════════════════════════════════════════════════════════════════════════
// // HOME PAGE
// // ═══════════════════════════════════════════════════════════════════════════════

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   List<Map<String, dynamic>> _allResources = [];
//   String _selectedType = 'All';
//   bool _isLoading = true;
//   int _navIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchResources();
//   }

//   Future<void> _fetchResources() async {
//     setState(() => _isLoading = true);
//     try {
//       final response = await http.get(
//         Uri.parse('${Session.baseUrl}/resources'),
//         headers: {
//           'Content-Type': 'application/json',
//           if (Session.token.isNotEmpty)
//             'Authorization': 'Bearer ${Session.token}',
//         },
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           _allResources = data.cast<Map<String, dynamic>>();
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//     }
//   }

//   // Filter card berdasarkan type yang dipilih
//   List<Map<String, dynamic>> get _filtered {
//     if (_selectedType == 'All') return _allResources;
//     return _allResources
//         .where((r) =>
//             (r['type'] ?? '').toString().toLowerCase() ==
//             _selectedType.toLowerCase())
//         .toList();
//   }

//   void _logout() {
//     Session.token = '';
//     Session.role  = '';
//     Session.name  = '';
//     Session.email = '';
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

//     return Scaffold(
//       extendBody: true,
//       backgroundColor: Colors.transparent,
//       body: Stack(
//         children: [
//           // ── Background galaxy — WAJIB ADA ──────────────────
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/Explore_bg.png',
//               fit: BoxFit.cover,
//             ),
//           ),

//           // ── Konten utama ───────────────────────────────────
//           Column(
//             children: [
//               // ── HEADER ─────────────────────────────────────
//               _Header(
//                 onLogout: _logout,
//                 onAdmin: () async {
//                   if (Session.role == 'admin') {
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const AdminDashboard ()),
//                     );
//                     _fetchResources();
//                   }
//                 },
//               ),

//               const SizedBox(height: 12),

//               // ── LOGO BANNER ────────────────────────────────
//               const _LogoBanner(),

//               const SizedBox(height: 20),

//               // ── PANEL CARDS ────────────────────────────────
//               SizedBox(
//                 width: 400,
//                 height: 560,
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF6D6598).withOpacity(0.22),
//                       borderRadius: BorderRadius.circular(30),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.10),
//                         width: 1.0,
//                       ),
//                     ),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF6D6598).withOpacity(0.22),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.10),
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           const SizedBox(height: 0),

//                           // ── PATH CHIPS — hardcode 9 type ───
//                           _PathChipsSection(
//                             selected: _selectedType,
//                             onSelect: (t) =>
//                                 setState(() => _selectedType = t),
//                           ),

//                           const SizedBox(height: 8),

//                           // ── CARDS GRID — dynamic dari DB ───
//                           Expanded(
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(19),
//                               child: _isLoading
//                                   ? const Center(
//                                       child: CircularProgressIndicator(
//                                           color: Colors.white),
//                                     )
//                                   : RefreshIndicator(
//                                       onRefresh: _fetchResources,
//                                       child: _CardsGrid(items: _filtered),
//                                     ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),

//       bottomNavigationBar: _BottomNav(
//         currentIndex: _navIndex,
//         onTap: (i) => setState(() => _navIndex = i),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // HEADER
// // ═══════════════════════════════════════════════════════════════════════════════

// class _Header extends StatelessWidget {
//   final VoidCallback onLogout;
//   final VoidCallback onAdmin;
//   const _Header({required this.onLogout, required this.onAdmin});

//   @override
//   Widget build(BuildContext context) {
//     final top = MediaQuery.of(context).padding.top;
//     return Container(
//       padding: EdgeInsets.fromLTRB(10, top + 2, 10, 4),
//       constraints: const BoxConstraints(minHeight: 52),
//       decoration: BoxDecoration(
//         color: Color(0XFF918EA1).withOpacity(0.37),
//         border: Border(
//           bottom: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
//         ),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.store_rounded, color: Color(0XFFEDC531), size: 26),
//           const SizedBox(width: 11),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Store',
//                 style: TextStyle(
//                   color: Color(0xFFEDC531),
//                   fontSize: 13,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//               Text(
//                 'Honkai Star Retail',
//                 style: TextStyle(
//                     color: Colors.white.withOpacity(0.85), fontSize: 11),
//               ),
//             ],
//           ),
//           const Spacer(),

//           if (Session.role == 'admin')
//             GestureDetector(
//               onTap: onAdmin,
//               child: Container(
//                 width: 30,
//                 height: 30,
//                 margin: const EdgeInsets.only(right: 8),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                       color: Colors.white.withOpacity(0.55), width: 1.4),
//                   color: Colors.white.withOpacity(0.08),
//                 ),
//                 child: const Icon(Icons.admin_panel_settings,
//                     color: Colors.white, size: 17),
//               ),
//             ),

//           GestureDetector(
//             onTap: onLogout,
//             child: Container(
//               width: 30,
//               height: 30,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                     color: Colors.white.withOpacity(0.55), width: 1.4),
//                 color: Colors.white.withOpacity(0.08),
//               ),
//               child: const Icon(Icons.logout, color: Colors.white, size: 17),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // LOGO BANNER
// // ═══════════════════════════════════════════════════════════════════════════════

// class _LogoBanner extends StatelessWidget {
//   const _LogoBanner();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Image.asset(
//           'assets/images/honkai_logo.png',
//           height: 139,
//           width: 282,
//           fit: BoxFit.contain,
//         ),
//         Transform.translate(
//           offset: const Offset(0, -27),
//           child: Text(
//           'Acquire powerful weapons and rare galactic resources.\nFuel your journey across the cosmos.',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.55),
//             fontSize: 11,
//             height: 1.4,
//           ),
//         ),
//         ),
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // PATH CHIPS SECTION — 9 type HARDCODE, tidak dari DB
// // ═══════════════════════════════════════════════════════════════════════════════

// class _PathChipsSection extends StatelessWidget {
//   final String selected;
//   final ValueChanged<String> onSelect;
//   const _PathChipsSection({required this.selected, required this.onSelect});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: const BorderRadius.only(
//         topLeft: Radius.circular(20),
//         topRight: Radius.circular(20),
//       ),
//       child: Container(
//         margin: EdgeInsets.zero,
//         padding: const EdgeInsets.symmetric(vertical: 6),
//         decoration: BoxDecoration(
//           color: Color(0xFF918EA1).withOpacity(0.37),
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//           border: Border.all(color: Colors.white.withOpacity(0.25)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.30),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: SizedBox(
//           height: 36,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             itemCount: kCategories.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 6),
//             itemBuilder: (_, i) {
//               final cat = kCategories[i];
//               final isSel = cat.label == selected;

//               return GestureDetector(
//                 onTap: () => onSelect(cat.label),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Color(0xFF918EA1).withOpacity(0.37),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: isSel
//                           ? Colors.white.withOpacity(0.65)
//                           : Colors.white.withOpacity(0.18),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Icon: grid_view untuk All, asset image untuk lainnya
//                       cat.iconAsset == null
//                           ? const Icon(Icons.grid_view,
//                               size: 14, color: Colors.white)
//                           : Image.asset(
//                               cat.iconAsset!,
//                               width: 20,
//                               height: 20,
//                               color: Colors.white,
//                               errorBuilder: (_, __, ___) => const Icon(
//                                   Icons.category,
//                                   size: 14,
//                                   color: Colors.white),
//                             ),
//                       const SizedBox(width: 5),
//                       Text(
//                         cat.label,
//                         style: TextStyle(
//                           color: Colors.white
//                               .withOpacity(isSel ? 1.0 : 0.65),
//                           fontSize: 11.5,
//                           fontWeight: isSel
//                               ? FontWeight.w700
//                               : FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // CARDS GRID — dynamic dari DB
// // ═══════════════════════════════════════════════════════════════════════════════

// class _CardsGrid extends StatelessWidget {
//   final List<Map<String, dynamic>> items;
//   const _CardsGrid({required this.items});

//   @override
//   Widget build(BuildContext context) {
//     if (items.isEmpty) {
//       return const Center(
//         child: Text('No items found',
//             style: TextStyle(color: Colors.white54)),
//       );
//     }
//     return GridView.builder(
//       padding: const EdgeInsets.fromLTRB(10, 12, 10, 60),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 8,
//         mainAxisSpacing: 14,
//         childAspectRatio: 0.775,
//       ),
//       itemCount: items.length,
//       itemBuilder: (_, i) => _LightConeCard(item: items[i], index: i),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // LIGHT CONE CARD — name, rarity, type, image dari DB
// // ═══════════════════════════════════════════════════════════════════════════════

// class _LightConeCard extends StatelessWidget {
//   final Map<String, dynamic> item;
//   final int index;
//   const _LightConeCard({required this.item, required this.index});

//   // Icon di sudut card pakai asset sama seperti chips
//   Widget _typeIconWidget(String type) {
//     const assetMap = {
//       'the hunt':           'assets/images/TheHunt.png',
//       'destruction':        'assets/images/Destruction.png',
//       'erudition':          'assets/images/Erudition.png',
//       'harmony':            'assets/images/Harmony.png',
//       'nihility':           'assets/images/Nihility.png',
//       'preservation':       'assets/images/Preservation.png',
//       'abundance':          'assets/images/Abundance.png',
//       'galactic resources': 'assets/images/Galatic.png',
//     };
//     final asset = assetMap[type.toLowerCase()];
//     if (asset != null) {
//       return Image.asset(
//         asset,
//         width: 14,
//         height: 14,
//         color: Colors.white,
//         errorBuilder: (_, __, ___) =>
//             const Icon(Icons.category, color: Colors.white, size: 12),
//       );
//     }
//     return const Icon(Icons.category, color: Colors.white, size: 12);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = _yellowTheme;

//     final String name   = (item['name']   ?? 'Unknown').toString();
//     final int    rarity = int.tryParse(item['rarity'].toString()) ?? 3;
//     final String type   = (item['type']   ?? '').toString();
//     final String? image = item['image']?.toString();

//     return GestureDetector(
//       onTap: () async {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (_) => DetailPage(itemId: item['id'])),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: theme.gradient,
//             stops: const [0.0, 0.5, 1.0],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 14,
//               offset: const Offset(0, 5),
//             ),
//           ],
//           border: Border.all(
//               color: Colors.white.withOpacity(0.10), width: 0.8),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: Stack(
//             children: [
//               // Bottom glow bar
//               Positioned(
//                 bottom: 0, left: 0, right: 0,
//                 child: Container(
//                   height: 9,
//                   color: theme.bottomBar.withOpacity(0.65),
//                 ),
//               ),

//               // Top shimmer
//               Positioned(
//                 top: 0, left: 0, right: 0,
//                 child: Container(
//                   height: 55,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.white.withOpacity(0.14),
//                         Colors.transparent,
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               Column(
//                 children: [
//                   // ── Type icon di sudut kiri atas ─────────────
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                           width: 22,
//                           height: 22,
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.18),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Center(child: _typeIconWidget(type)),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // ── Gambar card (miring) ──────────────────────
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(6, 4, 6, 25),
//                       child: Center(
//                         child: Transform.rotate(
//                           angle: 0.08 * math.pi / 2,
//                           child: Container(
//                             width: 55,
//                             height: 70,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               gradient: LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   Colors.white.withOpacity(0.22),
//                                   Colors.white.withOpacity(0.05),
//                                 ],
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.35),
//                                   blurRadius: 8,
//                                   offset: const Offset(2, 4),
//                                 ),
//                               ],
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.25),
//                                 width: 0.8,
//                               ),
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: image != null && image.isNotEmpty
//                                   ? Image.network(
//                                       image,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (_, __, ___) =>
//                                           _placeholder(),
//                                     )
//                                   : _placeholder(),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   // ── Name dari DB ──────────────────────────────
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
//                     child: Text(
//                       name,
//                       textAlign: TextAlign.center,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 8.0,
//                         fontWeight: FontWeight.w600,
//                         height: 1.3,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 0),

//                   // ── Rarity (bintang dari DB) ──────────────────
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 15),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(
//                         rarity.clamp(1, 5),
//                         (_) => const Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 0.5),
//                           child: Icon(Icons.star,
//                               color: AppColors.starGold, size: 9),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _placeholder() {
//     return Container(
//       color: Colors.white.withOpacity(0.08),
//       child: const Center(
//         child: Icon(Icons.person,
//             size: 40, color: Colors.white24),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // BOTTOM NAV — tidak ada perubahan
// // ═══════════════════════════════════════════════════════════════════════════════

// class _BottomNav extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//   const _BottomNav({required this.currentIndex, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     const items = [
//       (Icons.home_outlined,          Icons.home_rounded),
//       (Icons.search_outlined,        Icons.search_rounded),
//       (Icons.shopping_cart_outlined, Icons.shopping_cart_rounded),
//       (Icons.person_outline,         Icons.person_rounded),
//     ];

//     return Container(
//       height: 47,
//       decoration: BoxDecoration(
//         color: Color(0XFF918EA1).withOpacity(0.37),
//         border: Border(
//           top: BorderSide(
//               color: Colors.white.withOpacity(0.08), width: 0.8),
//         ),
//       ),
//       child: SafeArea(
//         top: false,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: List.generate(items.length, (i) {
//             final isActive = i == currentIndex;
//             return GestureDetector(
//               onTap: () => onTap(i),
//               behavior: HitTestBehavior.opaque,
//               child: SizedBox(
//                 width: 64,
//                 child: Center(
//                   child: Icon(
//                     isActive ? items[i].$2 : items[i].$1,
//                     color: isActive
//                         ? Colors.white
//                         : Colors.white.withOpacity(0.38),
//                     size: 32,
//                   ),
//                 ),
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../session.dart';
import '../provider/item_provider.dart';
import 'login_page.dart';
import 'detail_page.dart';
import 'admin_dashboard.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// APP COLORS
// ═══════════════════════════════════════════════════════════════════════════════

class AppColors {
  static const starGold = Color(0xFFFFD700);
  static const navBar   = Color(0xFF07071A);
}

// ═══════════════════════════════════════════════════════════════════════════════
// CARD COLOR THEME — ungu
// ═══════════════════════════════════════════════════════════════════════════════

class _CardTheme {
  final List<Color> gradient;
  final Color bottomBar;
  const _CardTheme({required this.gradient, required this.bottomBar});
}

_CardTheme get _purpleTheme => _CardTheme(
  gradient: [
    Color(0xFFA13BCA).withOpacity(0.05),
    Color(0xFFA13BCA).withOpacity(0.05),
    Color(0xFFA13BCA).withOpacity(0.6),
  ],
  bottomBar: Color(0xFFA13BCA).withOpacity(0.8),
);

// ═══════════════════════════════════════════════════════════════════════════════
// TYPE CATEGORY — hardcode 9 type, tidak dari DB
// ═══════════════════════════════════════════════════════════════════════════════

class _PathCategory {
  final String label;
  final String? iconAsset; // null = pakai Icons.grid_view
  const _PathCategory({required this.label, this.iconAsset});
}

// 9 type hardcode — tidak boleh dikurangi
const List<_PathCategory> kCategories = [
  _PathCategory(label: 'All',                iconAsset: null),
  _PathCategory(label: 'The Hunt',           iconAsset: 'assets/images/TheHunt.png'),
  _PathCategory(label: 'Destruction',        iconAsset: 'assets/images/Destruction.png'),
  _PathCategory(label: 'Erudition',          iconAsset: 'assets/images/Erudition.png'),
  _PathCategory(label: 'Harmony',            iconAsset: 'assets/images/Harmony.png'),
  _PathCategory(label: 'Nihility',           iconAsset: 'assets/images/Nihility.png'),
  _PathCategory(label: 'Preservation',       iconAsset: 'assets/images/Preservation.png'),
  _PathCategory(label: 'Abundance',          iconAsset: 'assets/images/Abundance.png'),
  _PathCategory(label: 'Galactic Resources', iconAsset: 'assets/images/Galatic.png'),
];

// ─── Enum sederhana untuk menandai jenis item di grid ─────────────────────────
enum _ItemKind { lightCone, galacticResource }

class _GridItem {
  final _ItemKind kind;
  final int       id;
  final String    name;
  final String    type;
  final String?   image;
  final int       rarity; // hanya relevan untuk lightCone
  const _GridItem({
    required this.kind,
    required this.id,
    required this.name,
    required this.type,
    this.image,
    this.rarity = 3,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// HOME PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedType = 'All';
  int    _navIndex     = 0;

  @override
  void initState() {
    super.initState();
    // Load data via provider setelah frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().loadItems();
    });
  }

  // ─── Gabungkan light cones + galactic resources menjadi satu list flat ──────
  List<_GridItem> _buildFilteredItems(ItemProvider provider) {
    final List<_GridItem> result = [];

    if (_selectedType == 'All') {
      // Semua light cone
      for (final lc in provider.lightCones) {
        result.add(_GridItem(
          kind:   _ItemKind.lightCone,
          id:     lc.id,
          name:   lc.name,
          type:   lc.type,
          image:  lc.imagePath,
          rarity: lc.rarity,
        ));
      }
      // Semua galactic resource
      for (final gr in provider.galacticResources) {
        result.add(_GridItem(
          kind:  _ItemKind.galacticResource,
          id:    gr.id,
          name:  gr.name,
          type:  gr.type,
          image: gr.imagePath,
        ));
      }
    } else if (_selectedType == 'Galactic Resources') {
      // Hanya galactic resources
      for (final gr in provider.galacticResources) {
        result.add(_GridItem(
          kind:  _ItemKind.galacticResource,
          id:    gr.id,
          name:  gr.name,
          type:  gr.type,
          image: gr.imagePath,
        ));
      }
    } else {
      // Filter light cone berdasarkan type (case-insensitive)
      for (final lc in provider.lightCones) {
        if (lc.type.toLowerCase() == _selectedType.toLowerCase()) {
          result.add(_GridItem(
            kind:   _ItemKind.lightCone,
            id:     lc.id,
            name:   lc.name,
            type:   lc.type,
            image:  lc.imagePath,
            rarity: lc.rarity,
          ));
        }
      }
    }

    return result;
  }

  void _logout() {
    Session.token = '';
    Session.role  = '';
    Session.name  = '';
    Session.email = '';
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Background galaxy — WAJIB ADA ──────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/Explore_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── Konten utama ───────────────────────────────────
          Column(
            children: [
              // ── HEADER ─────────────────────────────────────
              _Header(
                onLogout: _logout,
                onAdmin: () async {
                  if (Session.role == 'admin') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminDashboard()),
                    );
                    // Refresh data setelah admin melakukan perubahan
                    if (mounted) context.read<ItemProvider>().loadItems();
                  }
                },
              ),

              const SizedBox(height: 12),

              // ── LOGO BANNER ────────────────────────────────
              const _LogoBanner(),

              const SizedBox(height: 20),

              // ── PANEL CARDS ────────────────────────────────
              SizedBox(
                width: 400,
                height: 560,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6D6598).withOpacity(0.22),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.10),
                        width: 1.0,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6D6598).withOpacity(0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.10),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 0),

                          // ── PATH CHIPS — hardcode 9 type ───
                          _PathChipsSection(
                            selected: _selectedType,
                            onSelect: (t) =>
                                setState(() => _selectedType = t),
                          ),

                          const SizedBox(height: 8),

                          // ── CARDS GRID — via provider ──────
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(19),
                              child: Consumer<ItemProvider>(
                                builder: (context, provider, _) {
                                  if (provider.isLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.white),
                                    );
                                  }
                                  if (provider.error != null) {
                                    return Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            provider.error!,
                                            style: const TextStyle(
                                                color: Colors.white54),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                          TextButton(
                                            onPressed: () =>
                                                provider.loadItems(),
                                            child: const Text('Retry',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  final items = _buildFilteredItems(provider);
                                  return RefreshIndicator(
                                    onRefresh: provider.loadItems,
                                    child: _CardsGrid(items: items),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onAdmin;
  const _Header({required this.onLogout, required this.onAdmin});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(10, top + 2, 10, 4),
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        color: Color(0XFF918EA1).withOpacity(0.37),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.store_rounded, color: Color(0XFFEDC531), size: 26),
          const SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Store',
                style: TextStyle(
                  color: Color(0xFFEDC531),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Honkai Star Retail',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.85), fontSize: 11),
              ),
            ],
          ),
          const Spacer(),

          if (Session.role == 'admin')
            GestureDetector(
              onTap: onAdmin,
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withOpacity(0.55), width: 1.4),
                  color: Colors.white.withOpacity(0.08),
                ),
                child: const Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 17),
              ),
            ),

          GestureDetector(
            onTap: onLogout,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.55), width: 1.4),
                color: Colors.white.withOpacity(0.08),
              ),
              child: const Icon(Icons.logout, color: Colors.white, size: 17),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LOGO BANNER
// ═══════════════════════════════════════════════════════════════════════════════

class _LogoBanner extends StatelessWidget {
  const _LogoBanner();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/honkai_logo.png',
          height: 139,
          width: 282,
          fit: BoxFit.contain,
        ),
        Transform.translate(
          offset: const Offset(0, -27),
          child: Text(
            'Acquire powerful weapons and rare galactic resources.\nFuel your journey across the cosmos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PATH CHIPS SECTION — 9 type HARDCODE, tidak dari DB
// ═══════════════════════════════════════════════════════════════════════════════

class _PathChipsSection extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _PathChipsSection({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF918EA1).withOpacity(0.37),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: kCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final cat = kCategories[i];
              final isSel = cat.label == selected;

              return GestureDetector(
                onTap: () => onSelect(cat.label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF918EA1).withOpacity(0.37),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSel
                          ? Colors.white.withOpacity(0.65)
                          : Colors.white.withOpacity(0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon: grid_view untuk All, asset image untuk lainnya
                      cat.iconAsset == null
                          ? const Icon(Icons.grid_view,
                              size: 14, color: Colors.white)
                          : Image.asset(
                              cat.iconAsset!,
                              width: 20,
                              height: 20,
                              color: Colors.white,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.category,
                                  size: 14,
                                  color: Colors.white),
                            ),
                      const SizedBox(width: 5),
                      Text(
                        cat.label,
                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(isSel ? 1.0 : 0.65),
                          fontSize: 11.5,
                          fontWeight: isSel
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CARDS GRID — menerima list _GridItem (sudah terfilter)
// ═══════════════════════════════════════════════════════════════════════════════

class _CardsGrid extends StatelessWidget {
  final List<_GridItem> items;
  const _CardsGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No items found',
            style: TextStyle(color: Colors.white54)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 60),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 14,
        childAspectRatio: 0.775,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _LightConeCard(item: items[i], index: i),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LIGHT CONE CARD — mendukung dua jenis item
// ═══════════════════════════════════════════════════════════════════════════════

class _LightConeCard extends StatelessWidget {
  final _GridItem item;
  final int index;
  const _LightConeCard({required this.item, required this.index});

  // Icon di sudut card pakai asset sama seperti chips
  Widget _typeIconWidget(String type) {
    const assetMap = {
      'the hunt':           'assets/images/TheHunt.png',
      'destruction':        'assets/images/Destruction.png',
      'erudition':          'assets/images/Erudition.png',
      'harmony':            'assets/images/Harmony.png',
      'nihility':           'assets/images/Nihility.png',
      'preservation':       'assets/images/Preservation.png',
      'abundance':          'assets/images/Abundance.png',
      'galactic resources': 'assets/images/Galatic.png',
    };
    final asset = assetMap[type.toLowerCase()];
    if (asset != null) {
      return Image.asset(
        asset,
        width: 14,
        height: 14,
        color: Colors.white,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.category, color: Colors.white, size: 12),
      );
    }
    return const Icon(Icons.category, color: Colors.white, size: 12);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _purpleTheme;

    final bool isGalactic = item.kind == _ItemKind.galacticResource;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DetailPage(itemId: item.id)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.gradient,
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
              color: Colors.white.withOpacity(0.10), width: 0.8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // Bottom glow bar
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 9,
                  color: theme.bottomBar.withOpacity(0.65),
                ),
              ),

              // Top shimmer
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

              Column(
                children: [
                  // ── Type icon di sudut kiri atas ─────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: _typeIconWidget(item.type)),
                        ),
                      ],
                    ),
                  ),

                  // ── Gambar card (miring) ──────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 4, 6, 25),
                      child: Center(
                        child: Transform.rotate(
                          angle: 0.08 * math.pi / 2,
                          child: Container(
                            width: 55,
                            height: 70,
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
                              child: item.image != null &&
                                      item.image!.isNotEmpty
                                  ? item.image != null && item.image!.isNotEmpty
                                    ? (item.image!.startsWith('http')
                                      ? Image.network(
                                          item.image!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _placeholder(),
                                        )
                                      : Image.asset(
                                          item.image!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _placeholder(),
                                        ))
                                    : _placeholder()
                                  : _placeholder(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Name dari DB ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Text(
                      item.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.0,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 0),

                  // ── Bawah card: bintang untuk LightCone, type label untuk GalacticResource
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: isGalactic
                        ? Text(
                            item.type,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.70),
                              fontSize: 7.5,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              item.rarity.clamp(1, 5),
                              (_) => const Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 0.5),
                                child: Icon(Icons.star,
                                    color: AppColors.starGold, size: 9),
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

  Widget _placeholder() {
    return Container(
      color: Colors.white.withOpacity(0.08),
      child: const Center(
        child: Icon(Icons.person, size: 40, color: Colors.white24),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOTTOM NAV — tidak ada perubahan
// ═══════════════════════════════════════════════════════════════════════════════

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined,          Icons.home_rounded),
      (Icons.search_outlined,        Icons.search_rounded),
      (Icons.shopping_cart_outlined, Icons.shopping_cart_rounded),
      (Icons.person_outline,         Icons.person_rounded),
    ];

    return Container(
      height: 47,
      decoration: BoxDecoration(
        color: Color(0XFF918EA1).withOpacity(0.37),
        border: Border(
          top: BorderSide(
              color: Colors.white.withOpacity(0.08), width: 0.8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (i) {
            final isActive = i == currentIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 64,
                child: Center(
                  child: Icon(
                    isActive ? items[i].$2 : items[i].$1,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.38),
                    size: 32,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
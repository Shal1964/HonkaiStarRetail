
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../session.dart';
import '../provider/item_provider.dart';
import 'login_page.dart';
import 'detail_page.dart';
import 'admin_dashboard.dart';
import '../provider/theme_provider.dart';

class AppColors {
  static const starGold = Color(0xFFFFD700);
  static const navBar   = Color(0xFF07071A);
}

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


class _PathCategory {
  final String label;
  final String? iconAsset; 
  const _PathCategory({required this.label, this.iconAsset});
}
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

enum _ItemKind { lightCone, galacticResource }

class _GridItem {
  final _ItemKind kind;
  final int       id;
  final String    name;
  final String    type;
  final String?   image;
  final int       rarity; 
  const _GridItem({
    required this.kind,
    required this.id,
    required this.name,
    required this.type,
    this.image,
    this.rarity = 3,
  });
}

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().loadItems();
    });
  }

  List<_GridItem> _buildFilteredItems(ItemProvider provider) {
    final List<_GridItem> result = [];

    if (_selectedType == 'All') {
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
        
          Column(
            children: [
              _Header(
                onLogout: _logout,
                onAdmin: () async {
                  if (Session.role == 'admin') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminDashboard()),
                    );
                    
                    if (mounted) context.read<ItemProvider>().loadItems();
                  }
                },
              ),

              const SizedBox(height: 6),

              const _ThemeToggleButton(),

              const SizedBox(height: 6),

              const _LogoBanner(),

              const SizedBox(height: 20),

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
                          _PathChipsSection(
                            selected: _selectedType,
                            onSelect: (t) =>
                                setState(() => _selectedType = t),
                          ),

                          const SizedBox(height: 8),

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
        color: context.watch<ThemeProvider>().boxColor.withOpacity(0.37),
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

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 18),
        child: GestureDetector(
          onTap: () {
            context.read<ThemeProvider>().toggleTheme();
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeProvider.boxColor.withOpacity(0.45),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1,
              ),
            ),
            child: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode_rounded
                  : Icons.wb_sunny_rounded,
              color: themeProvider.isDarkMode
                  ? Colors.white
                  : const Color(0xFFFFD66B),
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}



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
          color: context.watch<ThemeProvider>().boxColor.withOpacity(0.37),
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
                    color : context.watch<ThemeProvider>().boxColor.withOpacity(0.37),
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


class _LightConeCard extends StatelessWidget {
  final _GridItem item;
  final int index;
  const _LightConeCard({required this.item, required this.index});

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
    final themeProvider = context.watch<ThemeProvider>();

    final bool isGalactic = item.kind == _ItemKind.galacticResource;

    return GestureDetector(

      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(
              itemId: item.id,
              itemType: item.kind == _ItemKind.galacticResource
                  ? 'galactic'
                  : 'lightcone',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors : themeProvider.cardGradient,
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
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 9,
                  color: themeProvider.cardBottomBar.withOpacity(0.65),
                ),
              ),

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
        color: context.watch<ThemeProvider>().boxColor.withOpacity(0.37),
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
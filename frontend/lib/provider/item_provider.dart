import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../session.dart';

// ============================================================
// MODEL: Light Cone — dari tabel 'light_cones' di MySQL
// Punya field 'rarity' (int, nilai 3 / 4 / 5)
// ============================================================
class LightConeModel {
  final int id;
  String name;
  String type;          // Path: The Hunt, Erudition, Harmony, dll
  String? description;
  int stock;
  String? imagePath;    // kolom 'image' di DB
  double price;
  int rarity;           // kolom 'rarity' di DB — bintang 3/4/5

  LightConeModel({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.stock,
    this.imagePath,
    required this.price,
    required this.rarity,
  });

  // ── Dari JSON (respons API) → LightConeModel ─────────────
  factory LightConeModel.fromJson(Map<String, dynamic> json) {
    return LightConeModel(
      id:          json['id'] as int,
      name:        json['name'] ?? '',
      type:        json['type'] ?? '',
      description: json['description'],
      stock:       json['stock'] ?? 0,
      imagePath:   json['image'],
      price:       (json['price'] as num).toDouble(),
      rarity:      json['rarity'] != null
                       ? (json['rarity'] as num).toInt()
                       : 3, // default 3 bintang jika null
    );
  }

  // ── LightConeModel → JSON (untuk kirim ke API) ───────────
  Map<String, dynamic> toJson() => {
    'name':        name,
    'type':        type,
    'description': description ?? '',
    'stock':       stock,
    'image':       imagePath ?? '',
    'price':       price,
    'rarity':      rarity,  // selalu ikut dikirim
  };
}

// ============================================================
// MODEL: Galactic Resource — dari tabel 'galactic_resources'
// TIDAK punya rarity
// ============================================================
class GalacticResourceModel {
  final int id;
  String name;
  String type;          // Currency, Material, dll
  String? description;
  int stock;
  String? imagePath;    // kolom 'image' di DB
  double price;

  GalacticResourceModel({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.stock,
    this.imagePath,
    required this.price,
  });

  // ── Dari JSON (respons API) → GalacticResourceModel ──────
  factory GalacticResourceModel.fromJson(Map<String, dynamic> json) {
    return GalacticResourceModel(
      id:          json['id'] as int,
      name:        json['name'] ?? '',
      type:        json['type'] ?? '',
      description: json['description'],
      stock:       json['stock'] ?? 0,
      imagePath:   json['image'],
      price:       (json['price'] as num).toDouble(),
    );
  }

  // ── GalacticResourceModel → JSON (untuk kirim ke API) ────
  Map<String, dynamic> toJson() => {
    'name':        name,
    'type':        type,
    'description': description ?? '',
    'stock':       stock,
    'image':       imagePath ?? '',
    'price':       price,
    // tidak ada 'rarity' karena tabel ini tidak punya kolom itu
  };
}

// ============================================================
// PROVIDER: Sumber data terpusat
// Mengelola dua list terpisah: lightCones & galacticResources
// Semua HTTP menuju Node.js → MySQL
// ============================================================
class ItemProvider extends ChangeNotifier {
  List<LightConeModel>        _lightCones        = [];
  List<GalacticResourceModel> _galacticResources = [];

  bool    _isLoading = false;
  String? _error;

  // ── Getters ─────────────────────────────────────────────────────────────

  List<LightConeModel>        get lightCones        => List.unmodifiable(_lightCones);
  List<GalacticResourceModel> get galacticResources => List.unmodifiable(_galacticResources);

  bool    get isLoading => _isLoading;
  String? get error     => _error;

  int get lightConeCount        => _lightCones.length;
  int get galacticResourceCount => _galacticResources.length;

  /// 5 Light Cone terbaru berdasarkan id terbesar (= paling baru di DB)
  List<LightConeModel> get recentLightCones {
    final sorted = [..._lightCones]..sort((a, b) => b.id.compareTo(a.id));
    return sorted.take(5).toList();
  }

  /// 5 Galactic Resource terbaru berdasarkan id terbesar
  List<GalacticResourceModel> get recentGalacticResources {
    final sorted = [..._galacticResources]..sort((a, b) => b.id.compareTo(a.id));
    return sorted.take(5).toList();
  }

  // ── LOAD: Ambil semua data dari DB ──────────────────────────────────────
  // Memanggil dua endpoint sekaligus secara paralel agar lebih cepat
  Future<void> loadItems() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final results = await Future.wait([
      http.get(Uri.parse('${Session.baseUrl}/light-cones')),
      http.get(Uri.parse('${Session.baseUrl}/galactic-resources')),
    ]);

    final lcResponse  = results[0];
    final grResponse  = results[1];

    // ✅ TAMBAHAN DEBUG (TIDAK MENGUBAH LOGIC)
    print("LIGHT STATUS: ${lcResponse.statusCode}");
    print("LIGHT BODY: ${lcResponse.body}");
    print("GALACTIC STATUS: ${grResponse.statusCode}");
    print("GALACTIC BODY: ${grResponse.body}");

    // Parse Light Cones
    if (lcResponse.statusCode == 200) {
      final List<dynamic> data = jsonDecode(lcResponse.body);
      _lightCones = data.map((e) => LightConeModel.fromJson(e)).toList();

      // ✅ TAMBAHAN DEBUG
      print("LIGHT COUNT: ${_lightCones.length}");
    } else {
      _error = 'Gagal memuat Light Cones (${lcResponse.statusCode})';
    }

    // Parse Galactic Resources
    if (grResponse.statusCode == 200) {
      final List<dynamic> data = jsonDecode(grResponse.body);
      _galacticResources = data.map((e) => GalacticResourceModel.fromJson(e)).toList();

      // ✅ TAMBAHAN DEBUG
      print("GALACTIC COUNT: ${_galacticResources.length}");
    } else {
      _error = (_error != null ? '$_error | ' : '') +
          'Gagal memuat Galactic Resources (${grResponse.statusCode})';
    }

  } catch (e) {
    print("ERROR CONNECT: $e");

    _error = 'Tidak dapat terhubung ke server.';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // ════════════════════════════════════════════════════════════════════════════
  // LIGHT CONE — CRUD
  // ════════════════════════════════════════════════════════════════════════════

  /// Tambah Light Cone baru → POST /light-cones
  Future<bool> addLightCone(LightConeModel item) async {
    try {
      final response = await http.post(
        Uri.parse('${Session.baseUrl}/light-cones'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Session.token}',
        },
        body: jsonEncode(item.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Reload dari server supaya id dari DB (auto_increment) ikut masuk
        await loadItems();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Edit Light Cone → PUT /light-cones/:id
  Future<bool> editLightCone(
    int id, {
    String? name,
    String? type,
    String? description,
    int? stock,
    String? imagePath,
    double? price,
    int? rarity,
  }) async {
    final index = _lightCones.indexWhere((e) => e.id == id);
    if (index == -1) return false;

    final updated = LightConeModel(
      id:          id,
      name:        name        ?? _lightCones[index].name,
      type:        type        ?? _lightCones[index].type,
      description: description ?? _lightCones[index].description,
      stock:       stock       ?? _lightCones[index].stock,
      imagePath:   imagePath   ?? _lightCones[index].imagePath,
      price:       price       ?? _lightCones[index].price,
      rarity:      rarity      ?? _lightCones[index].rarity,
    );

    try {
      final response = await http.put(
        Uri.parse('${Session.baseUrl}/light-cones/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Session.token}',
        },
        body: jsonEncode(updated.toJson()),
      );

      if (response.statusCode == 200) {
        // Update lokal langsung → UI lebih responsif tanpa reload penuh
        _lightCones[index] = updated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Hapus Light Cone → DELETE /light-cones/:id
  Future<bool> deleteLightCone(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${Session.baseUrl}/light-cones/$id'),
        headers: {'Authorization': 'Bearer ${Session.token}'},
      );

      if (response.statusCode == 200) {
        _lightCones.removeWhere((e) => e.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // GALACTIC RESOURCE — CRUD
  // ════════════════════════════════════════════════════════════════════════════

  /// Tambah Galactic Resource baru → POST /galactic-resources
  Future<bool> addGalacticResource(GalacticResourceModel item) async {
    try {
      final response = await http.post(
        Uri.parse('${Session.baseUrl}/galactic-resources'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Session.token}',
        },
        body: jsonEncode(item.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadItems();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Edit Galactic Resource → PUT /galactic-resources/:id
  Future<bool> editGalacticResource(
    int id, {
    String? name,
    String? type,
    String? description,
    int? stock,
    String? imagePath,
    double? price,
  }) async {
    final index = _galacticResources.indexWhere((e) => e.id == id);
    if (index == -1) return false;

    final updated = GalacticResourceModel(
      id:          id,
      name:        name        ?? _galacticResources[index].name,
      type:        type        ?? _galacticResources[index].type,
      description: description ?? _galacticResources[index].description,
      stock:       stock       ?? _galacticResources[index].stock,
      imagePath:   imagePath   ?? _galacticResources[index].imagePath,
      price:       price       ?? _galacticResources[index].price,
    );

    try {
      final response = await http.put(
        Uri.parse('${Session.baseUrl}/galactic-resources/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Session.token}',
        },
        body: jsonEncode(updated.toJson()),
      );

      if (response.statusCode == 200) {
        _galacticResources[index] = updated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Hapus Galactic Resource → DELETE /galactic-resources/:id
  Future<bool> deleteGalacticResource(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${Session.baseUrl}/galactic-resources/$id'),
        headers: {'Authorization': 'Bearer ${Session.token}'},
      );

      if (response.statusCode == 200) {
        _galacticResources.removeWhere((e) => e.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
// ════════════════════════════════════════════════════════════════════════════
// CHECKOUT - CARA CEPAT (Kalkulasi di Frontend)
// ════════════════════════════════════════════════════════════════════════════

Future<bool> checkoutSingleItem(int id, String itemKind, int quantityBought) async {
  if (itemKind == 'lightCone') {
    // Cari item saat ini
    final index = _lightCones.indexWhere((e) => e.id == id);
    if (index == -1) return false;
    
    // Hitung stok baru
    final currentStock = _lightCones[index].stock;
    if (currentStock < quantityBought) return false; // Stok tidak cukup
    
    final newStock = currentStock - quantityBought;
    
    // Gunakan fungsi edit yang sudah ada
    return await editLightCone(id, stock: newStock);

  } else if (itemKind == 'galacticResource') {
    final index = _galacticResources.indexWhere((e) => e.id == id);
    if (index == -1) return false;

    final currentStock = _galacticResources[index].stock;
    if (currentStock < quantityBought) return false; 
    
    final newStock = currentStock - quantityBought;
    
    return await editGalacticResource(id, stock: newStock);
  }
  
  return false;
}





}
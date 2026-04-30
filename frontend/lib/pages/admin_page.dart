import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../session.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<dynamic> resources = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchResources();
  }

  Future<void> fetchResources() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('${Session.baseUrl}/resources'));
      if (response.statusCode == 200) {
        setState(() {
          resources = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // Show dialog to add or edit a resource
  void showResourceDialog({Map<String, dynamic>? existing}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final typeCtrl = TextEditingController(text: existing?['type'] ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] ?? '');
    final stockCtrl = TextEditingController(text: existing?['stock']?.toString() ?? '0');
    final imageCtrl = TextEditingController(text: existing?['image'] ?? '');
    final priceCtrl = TextEditingController(text: existing?['price']?.toString() ?? '');
    String errorMsg = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2E),
              title: Text(
                existing == null ? 'Add Resource' : 'Edit Resource',
                style: const TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (errorMsg.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(errorMsg, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                      ),
                    _buildField(nameCtrl, 'Name'),
                    _buildField(typeCtrl, 'Type (e.g. Currency, Material, Light Cone)'),
                    _buildField(descCtrl, 'Description'),
                    _buildField(stockCtrl, 'Stock'),
                    _buildField(imageCtrl, 'Image URL'),
                    _buildField(priceCtrl, 'Price'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // =============================================
                    // VALIDATION 2: Price must be a number > 0
                    // =============================================
                    final price = double.tryParse(priceCtrl.text.trim());
                    if (price == null || price <= 0) {
                      setDialogState(() {
                        errorMsg = 'Price must be a number greater than 0';
                      });
                      return;
                    }

                    if (nameCtrl.text.trim().isEmpty || typeCtrl.text.trim().isEmpty) {
                      setDialogState(() {
                        errorMsg = 'Name and Type are required';
                      });
                      return;
                    }

                    final body = {
                      'name': nameCtrl.text.trim(),
                      'type': typeCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                      'stock': int.tryParse(stockCtrl.text.trim()) ?? 0,
                      'image': imageCtrl.text.trim(),
                      'price': price,
                    };

                    try {
                      http.Response response;
                      if (existing == null) {
                        // CREATE - POST /resources (token required)
                        response = await http.post(
                          Uri.parse('${Session.baseUrl}/resources'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer ${Session.token}',
                          },
                          body: jsonEncode(body),
                        );
                      } else {
                        // UPDATE - PUT /resources/:id (token required)
                        response = await http.put(
                          Uri.parse('${Session.baseUrl}/resources/${existing['id']}'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer ${Session.token}',
                          },
                          body: jsonEncode(body),
                        );
                      }

                      if (response.statusCode == 200) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        fetchResources();
                      } else {
                        final data = jsonDecode(response.body);
                        setDialogState(() {
                          errorMsg = data['error'] ?? 'Operation failed';
                        });
                      }
                    } catch (e) {
                      setDialogState(() => errorMsg = 'Cannot connect to server');
                    }
                  },
                  child: Text(existing == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // DELETE resource
  Future<void> deleteResource(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Delete Resource', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse('${Session.baseUrl}/resources/$id'),
        headers: {'Authorization': 'Bearer ${Session.token}'},
      );
      if (response.statusCode == 200) {
        fetchResources();
      }
    } catch (e) {
      // handle error silently
    }
  }

  Widget _buildField(TextEditingController ctrl, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: resources.length,
              itemBuilder: (context, index) {
                final item = resources[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['image'] ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[800],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    ),
                    title: Text(
                      item['name'] ?? '',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${item['type']} • ${item['price']} Credits • Stock: ${item['stock']}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button
                        IconButton(
                          icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary),
                          onPressed: () => showResourceDialog(existing: item),
                        ),
                        // Delete button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => deleteResource(item['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      // Floating Action Button to add new resource
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => showResourceDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

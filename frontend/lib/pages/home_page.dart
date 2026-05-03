import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../session.dart';
import 'detail_page.dart';
import 'admin_dashboard.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> resources = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchResources();
  }

  // GET /resources - Retrieve all resources
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

  void logout() {
    Session.token = '';
    Session.role = '';
    Session.name = '';
    Session.email = '';
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Honkai Star Retail'),
        automaticallyImplyLeading: false,
        actions: [
          // Show admin button if admin
          if (Session.role == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboard()),
                );
                fetchResources(); // Refresh after admin changes
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${Session.name}!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Browse galactic resources & light cones',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),

          // Resource list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchResources,
                    // UI COMPONENT: ListView
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: resources.length,
                      itemBuilder: (context, index) {
                        final item = resources[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            // UI COMPONENT: Image
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item['image'] ?? '',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.image, color: Colors.grey),
                                ),
                              ),
                            ),
                            // UI COMPONENT: Text
                            title: Text(
                              item['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['type'] ?? '',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item['price']} Credits',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              'Stock: ${item['stock']}',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailPage(itemId: item['id']),
                                ),
                              );
                              fetchResources(); // Refresh after buying
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

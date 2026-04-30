import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../session.dart';

class DetailPage extends StatefulWidget {
  final int itemId;
  const DetailPage({super.key, required this.itemId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic>? item;
  bool isLoading = true;
  final quantityController = TextEditingController(text: '1');
  String message = '';
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchItem();
  }

  // GET /resources/:id - Get single resource
  Future<void> fetchItem() async {
    try {
      final response = await http.get(
        Uri.parse('${Session.baseUrl}/resources/${widget.itemId}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          item = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // =============================================
  // VALIDATION 3: Ensure buy quantity > 0
  // =============================================
  Future<void> buyItem() async {
    final qty = int.tryParse(quantityController.text.trim());

    if (qty == null || qty <= 0) {
      setState(() {
        message = 'Quantity must be a number greater than 0';
        isError = true;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Session.baseUrl}/resources/${widget.itemId}/buy'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Session.token}',
        },
        body: jsonEncode({'quantity': qty}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          message = '${data['message']} (Total: ${data['totalCost']} Credits)';
          isError = false;
        });
        fetchItem(); // Refresh stock
      } else {
        setState(() {
          message = data['error'] ?? 'Purchase failed';
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        message = 'Cannot connect to server';
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Item not found', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(item!['name'] ?? '')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  item!['image'] ?? '',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image, size: 60, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item!['type'] ?? '',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Name
            Text(
              item!['name'] ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              item!['description'] ?? '',
              style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),

            // Price and Stock
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item!['price']} Credits',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  'Stock: ${item!['stock']}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Divider(color: Colors.grey),
            const SizedBox(height: 16),

            // Buy section
            const Text(
              'Purchase',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),

            // Message
            if (message.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isError ? Colors.red.withAlpha(30) : Colors.green.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: isError ? Colors.redAccent : Colors.greenAccent,
                  ),
                ),
              ),

            Row(
              children: [
                // Quantity input
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(hintText: 'Quantity'),
                  ),
                ),
                const SizedBox(width: 16),
                // Buy button
                ElevatedButton(
                  onPressed: buyItem,
                  child: const Text('Buy Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

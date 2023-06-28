import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void updateFavoriteError(newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final webUrl = Uri.parse(
      'https://shopapp-315b8-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$token',
    );
    try {
      final response = await http.put(
        webUrl,
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        updateFavoriteError(oldStatus);
      }
    } catch (error) {
      updateFavoriteError(oldStatus);
    }
  }
}

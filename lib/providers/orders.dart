import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';

class OrderItem {
  final double amount;
  final DateTime date;
  final String id;
  final List<CartItem> items;

  OrderItem({
    required this.id,
    required this.amount,
    required this.date,
    required this.items,
  });
}

class Order with ChangeNotifier {
  String? token;
  List<OrderItem> _orders = [];
  String? userId;

  void updateOrders(token, userId, order) {
    token = token;
    _orders = order;
    userId = userId;
    notifyListeners();
  }

  List<OrderItem> get orderItems {
    return [..._orders];
  }

  Future<void> fetchAndSetUpOrder() async {
    final webUrl = Uri.parse(
        'https://shopapp-315b8-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$token');
    try {
      final response = await http.get(webUrl);
      final ordersData = json.decode(response.body) as Map<String, dynamic>;
      List<OrderItem> _loadedOrders = [];
      if (ordersData.isEmpty || ordersData['error'] != null) {
        return;
      }
      ordersData.forEach(
        (orderId, orderData) {
          _loadedOrders.add(
            OrderItem(
              id: orderId,
              date: DateTime.parse(orderData['date']),
              amount: orderData['amount'],
              items: (orderData['itemList'] as List<dynamic>)
                  .map(
                    (item) => CartItem(
                      id: item['id'],
                      price: item['price'],
                      title: item['title'],
                      quantity: item['quantity'],
                    ),
                  )
                  .toList(),
            ),
          );
        },
      );
      _orders = _loadedOrders.reversed.toList();
    } catch (error) {
      throw error;
    }

    notifyListeners();
  }

  Future<void> placeOrder(double total, List<CartItem> products) async {
    final webUrl = Uri.parse(
        'https://shopapp-315b8-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json');
    final dateTime = DateTime.now();
    try {
      final response = await http.post(
        webUrl,
        body: json.encode(
          {
            'amount': total,
            'itemList': products
                .map((item) => {
                      'id': item.id,
                      'quantity': item.quantity,
                      'title': item.title,
                      'price': item.price,
                    })
                .toList(),
            'date': dateTime.toIso8601String(),
          },
        ),
      );
      _orders.insert(
        0,
        OrderItem(
          amount: total,
          id: json.decode(response.body)['name'],
          date: dateTime,
          items: products,
        ),
      );
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
}

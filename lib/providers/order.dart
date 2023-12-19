import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './cart.dart';
import '../config/endpoints.dart';

class OrderItem {
  final String id;
  final List<CartItem> products;
  final double amount;
  final DateTime datetime;

  OrderItem({
    required this.id,
    required this.products,
    required this.amount,
    required this.datetime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String token;
  final String userId;

  Orders(this.token, this.userId, this._orders);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final response = await http.get(
      Uri.parse('${EndPoints.baseUrl}/orders/$userId.json?auth=$token'),
    );
    List<OrderItem> loadedOrders = [];
    final extractedOrders = json.decode(response.body) as Map<String, dynamic>?;
    if (extractedOrders == null) {
      return;
    }
    extractedOrders.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: orderData['amount'],
        datetime: DateTime.parse(orderData['datetime']),
        products: (orderData['products'] as List<dynamic>).map((prod) {
          return CartItem(
            id: prod['id'],
            title: prod['title'],
            price: prod['price'],
            quantity: prod['quantity'],
          );
        }).toList(),
      ));
    });
    _orders = loadedOrders;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double amount) async {
    final timestamp = DateTime.now();
    final response = await http.post(
        Uri.parse('${EndPoints.baseUrl}/orders/$userId.json?auth=$token'),
        body: json.encode({
          'amount': amount,
          'datetime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((cartProd) => {
                    'id': cartProd.id,
                    'price': cartProd.price,
                    'quantity': cartProd.quantity,
                    'title': cartProd.title,
                  })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        products: cartProducts,
        amount: amount,
        datetime: timestamp,
      ),
    );
    notifyListeners();
  }
}

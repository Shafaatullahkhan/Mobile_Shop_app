import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_model.dart';

class Order {
  final String id;
  final String userId;
  final String? userName;
  final List<Product> items;
  final double totalAmount;
  final String status;
  final DateTime timestamp;
  final String? expectedDeliveryTime;

  Order({
    required this.id,
    required this.userId,
    this.userName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.timestamp,
    this.expectedDeliveryTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'items': items.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'timestamp': timestamp,
      'expectedDeliveryTime': expectedDeliveryTime,
    };
  }

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    return Order(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'],
      items: List<Product>.from(map['items']?.map((x) => Product.fromMap(x, x['id'] ?? '')) ?? []),
      totalAmount: (map['totalAmount'] ?? map['totalPrice'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] as Timestamp).toDate()
          : (map['createdAt'] != null 
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.now()),
      expectedDeliveryTime: map['expectedDeliveryTime'],
    );
  }
}

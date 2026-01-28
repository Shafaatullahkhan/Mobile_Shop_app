import 'package:hive/hive.dart';
import 'product_local.dart';

part 'order_local.g.dart';

@HiveType(typeId: 1)
class OrderLocal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String userName;

  @HiveField(3)
  final List<ProductLocal> items;

  @HiveField(4)
  final double totalAmount;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final DateTime timestamp;

  @HiveField(7)
  final DateTime? expectedDeliveryTime;

  @HiveField(8)
  final DateTime lastSynced;

  @HiveField(9)
  final bool isPendingSync;

  OrderLocal({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.timestamp,
    this.expectedDeliveryTime,
    required this.lastSynced,
    this.isPendingSync = false,
  });

  // Convert from Firebase Order model
  factory OrderLocal.fromRemote(Map<String, dynamic> remoteOrder, String id, List<ProductLocal> products) {
    return OrderLocal(
      id: id,
      userId: remoteOrder['userId'] ?? '',
      userName: remoteOrder['userName'] ?? '',
      items: products,
      totalAmount: (remoteOrder['totalAmount'] ?? remoteOrder['totalPrice'] ?? 0.0).toDouble(),
      status: remoteOrder['status'] ?? 'pending',
      timestamp: remoteOrder['timestamp'] != null
          ? (remoteOrder['timestamp'] as DateTime)
          : (remoteOrder['createdAt'] != null
              ? (remoteOrder['createdAt'] as DateTime)
              : DateTime.now()),
      expectedDeliveryTime: remoteOrder['expectedDeliveryTime'],
      lastSynced: DateTime.now(),
      isPendingSync: false,
    );
  }

  // Convert to Firebase Order model format
  Map<String, dynamic> toRemote() {
    return {
      'userId': userId,
      'userName': userName,
      'items': items.map((product) => product.toRemote()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'timestamp': timestamp,
      'expectedDeliveryTime': expectedDeliveryTime,
    };
  }

  // Create copy with updated fields
  OrderLocal copyWith({
    String? id,
    String? userId,
    String? userName,
    List<ProductLocal>? items,
    double? totalAmount,
    String? status,
    DateTime? timestamp,
    DateTime? expectedDeliveryTime,
    DateTime? lastSynced,
    bool? isPendingSync,
  }) {
    return OrderLocal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      expectedDeliveryTime: expectedDeliveryTime ?? this.expectedDeliveryTime,
      lastSynced: lastSynced ?? this.lastSynced,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }
}

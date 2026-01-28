import 'package:hive/hive.dart';

part 'favorite_local.g.dart';

@HiveType(typeId: 3)
class FavoriteLocal extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final DateTime addedAt;

  @HiveField(3)
  final DateTime lastSynced;

  @HiveField(4)
  final bool isPendingSync;

  FavoriteLocal({
    required this.userId,
    required this.productId,
    required this.addedAt,
    required this.lastSynced,
    this.isPendingSync = false,
  });

  // Create copy with updated fields
  FavoriteLocal copyWith({
    String? userId,
    String? productId,
    DateTime? addedAt,
    DateTime? lastSynced,
    bool? isPendingSync,
  }) {
    return FavoriteLocal(
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      addedAt: addedAt ?? this.addedAt,
      lastSynced: lastSynced ?? this.lastSynced,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }
}

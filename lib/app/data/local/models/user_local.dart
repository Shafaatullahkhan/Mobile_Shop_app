import 'package:hive/hive.dart';

part 'user_local.g.dart';

@HiveType(typeId: 2)
class UserLocal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? photoURL;

  @HiveField(4)
  final String role;

  @HiveField(5)
  final DateTime lastSynced;

  @HiveField(6)
  final bool isLoggedIn;

  UserLocal({
    required this.id,
    required this.name,
    required this.email,
    this.photoURL,
    this.role = 'user',
    required this.lastSynced,
    this.isLoggedIn = false,
  });

  // Convert from Firebase User
  factory UserLocal.fromFirebaseUser(dynamic firebaseUser, {String role = 'user'}) {
    return UserLocal(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      photoURL: firebaseUser.photoURL,
      role: role,
      lastSynced: DateTime.now(),
      isLoggedIn: true,
    );
  }

  // Create copy with updated fields
  UserLocal copyWith({
    String? name,
    String? email,
    String? photoURL,
    String? role,
    DateTime? lastSynced,
    bool? isLoggedIn,
  }) {
    return UserLocal(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      lastSynced: lastSynced ?? this.lastSynced,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

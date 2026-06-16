import 'package:equatable/equatable.dart';

/// User entity following Single Responsibility Principle
/// Represents core business object - pure, immutable
class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Copy with method for immutable updates
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, createdAt, lastLoginAt];
}
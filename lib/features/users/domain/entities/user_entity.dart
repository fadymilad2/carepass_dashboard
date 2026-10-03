import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String phoneNumber;
  final String? email;
  final String? city;
  final String? emergencyContact;
  final String? bloodType;
  final String selectedArea;

  final String subscriptionStatus;
  final String planName;
  final String memberId;
  final String cardExpiryDate;
  final String createdAt;
  final String? fcmToken;

  const UserEntity({
    required this.id,
    required this.username,
    required this.phoneNumber,
    this.email,
    this.city,
    this.emergencyContact,
    this.bloodType,
    required this.subscriptionStatus,
    required this.planName,
    required this.memberId,
    required this.cardExpiryDate,
    required this.createdAt,
    required this.selectedArea,
    this.fcmToken,
  });

  bool get isActive => subscriptionStatus == 'active';
  bool get isExpired => subscriptionStatus == 'expired';
  bool get isSuspended => subscriptionStatus == 'suspended';
  bool get hasNoPlan => subscriptionStatus == 'none';

  String get displayName => username.isNotEmpty ? username : phoneNumber;

  String get avatarLetter =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

  String get planLabel => planName.isEmpty || planName == '—'
      ? 'No Plan'
      : planName[0].toUpperCase() + planName.substring(1);

  @override
  List<Object?> get props => [
    id,
    username,
    phoneNumber,
    email,
    city,
    emergencyContact,
    bloodType,
    selectedArea,
    subscriptionStatus,
    planName,
    memberId,
    cardExpiryDate,
    createdAt,
    fcmToken,
  ];
}

class UserStats {
  final int total;
  final int active;
  final int expired;
  final int suspended;
  final int noPlan;

  const UserStats({
    required this.total,
    required this.active,
    required this.expired,
    required this.suspended,
    required this.noPlan,
  });
}

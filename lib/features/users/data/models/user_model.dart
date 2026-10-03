import '../../../../core/utils/reporting.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.phoneNumber,
    required super.subscriptionStatus,
    required super.planName,
    required super.memberId,
    required super.cardExpiryDate,
    required super.createdAt,
    required super.selectedArea,
    super.fcmToken,
    super.email,
    super.city,
    super.emergencyContact,
    super.bloodType,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      username: data['username'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      subscriptionStatus: effectiveStatus(data, DateTime.now().toUtc()),
      planName: data['planName'] as String? ?? '',
      memberId: data['memberId'] as String? ?? '—',
      cardExpiryDate: reportDateString(data['cardExpiryDate']),
      createdAt: reportDateString(data['createdAt']),
      selectedArea: data['selectedArea'] as String? ?? '',
      fcmToken: data['fcmToken'] as String?,
      // ✅ New fields
      email: data['email'] as String?,
      city: data['city'] as String?,
      emergencyContact: data['emergencyContact'] as String?,
      bloodType: data['bloodType'] as String?,
    );
  }
}

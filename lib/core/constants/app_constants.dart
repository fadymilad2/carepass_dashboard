class DConstants {
  DConstants._();

  // Firestore collections
  static const users = 'users';
  static const providers = 'providers';
  static const services = 'services';
  static const payments = 'payments';
  static const banners = 'home_banners';
  static const notifications = 'notifications';
  static const discountCodes = 'discount_codes';
  static const adminUsers = 'admin_users';

  // Subscription statuses
  static const active = 'active';
  static const expired = 'expired';
  static const suspended = 'suspended';
  static const none = 'none';

  // Admin roles
  static const roleSuperAdmin = 'super_admin';
  static const roleAdmin = 'admin';
  static const roleSupport = 'support';
  static const roleFinance = 'finance';
}

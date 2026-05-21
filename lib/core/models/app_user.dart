class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    required this.isActive,
    required this.emailVerified,
    this.kycSubmittedAt,
    this.kycReviewStatus = 'none',
    this.trustedForCommerce = false,
  });

  final int id;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final bool isActive;
  final bool emailVerified;
  final DateTime? kycSubmittedAt;
  final String kycReviewStatus;
  final bool trustedForCommerce;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    DateTime? kycAt;
    final raw = json['kyc_submitted_at'];
    if (raw is String && raw.isNotEmpty) {
      kycAt = DateTime.tryParse(raw);
    }
    final idRaw = json['id'];
    final id = idRaw is int ? idRaw : (idRaw is num ? idRaw.toInt() : int.parse('$idRaw'));
    final roleRaw = json['role'];
    final role = roleRaw is String ? roleRaw : (roleRaw?.toString() ?? 'tenant');

    return AppUser(
      id: id,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      role: role,
      isActive: json['is_active'] as bool? ?? true,
      emailVerified: json['email_verified'] as bool? ?? false,
      kycSubmittedAt: kycAt,
      kycReviewStatus: json['kyc_review_status'] as String? ?? 'none',
      trustedForCommerce: json['trusted_for_commerce'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'role': role,
        'is_active': isActive,
        'email_verified': emailVerified,
        'kyc_submitted_at': kycSubmittedAt?.toIso8601String(),
        'kyc_review_status': kycReviewStatus,
        'trusted_for_commerce': trustedForCommerce,
      };

  AppUser copyWith({
    String? fullName,
    String? phone,
    String? role,
    DateTime? kycSubmittedAt,
    String? kycReviewStatus,
    bool? trustedForCommerce,
    bool? emailVerified,
  }) {
    return AppUser(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      kycSubmittedAt: kycSubmittedAt ?? this.kycSubmittedAt,
      kycReviewStatus: kycReviewStatus ?? this.kycReviewStatus,
      trustedForCommerce: trustedForCommerce ?? this.trustedForCommerce,
    );
  }
}

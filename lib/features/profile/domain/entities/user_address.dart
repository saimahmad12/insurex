class UserAddress {
  const UserAddress({
    required this.residentialAddress,
    required this.city,
    required this.country,
  });

  final String residentialAddress;
  final String city;
  final String country;

  UserAddress copyWith({
    String? residentialAddress,
    String? city,
    String? country,
  }) {
    return UserAddress(
      residentialAddress: residentialAddress ?? this.residentialAddress,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }
}

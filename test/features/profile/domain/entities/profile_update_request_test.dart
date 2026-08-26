import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/profile/domain/entities/profile_update_request.dart';
import 'package:insurancex/features/profile/domain/entities/user_address.dart';

void main() {
  test('normal profile update contains only directly editable data', () {
    const ProfileUpdateRequest request = ProfileUpdateRequest(
      address: UserAddress(
        residentialAddress: 'House 24, Street 8',
        city: 'Islamabad',
        country: 'Pakistan',
      ),
    );

    expect(request.address.city, 'Islamabad');
    expect(request.fullName, isNull);
    expect(request.dateOfBirth, isNull);
    expect(request.gender, isNull);
    expect(request.containsLegalIdentityChanges, isFalse);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/payments/domain/entities/payout_method.dart';

void main() {
  test('bank and wallet masking expose only the final four characters', () {
    const String bank = 'PK36SCBL0000001123456702';
    const String mobile = '+923001234567';

    final String maskedBank = maskBankAccount(bank);
    final String maskedMobile = maskPakistaniMobile(mobile);

    expect(maskedBank, '**** **** **** 6702');
    expect(maskedBank, isNot(contains(bank)));
    expect(maskedMobile, '03** *** 4567');
    expect(maskedMobile, isNot(contains('03001234567')));
  });
}

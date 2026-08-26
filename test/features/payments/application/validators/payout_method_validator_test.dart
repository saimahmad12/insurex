import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/payments/application/validators/payout_method_validator.dart';
import 'package:insurancex/features/payments/domain/entities/payout_method.dart';

void main() {
  group('PayoutMethodValidator', () {
    test('accepts valid Pakistani bank and wallet details', () {
      expect(
        PayoutMethodValidator.validate(
          const PayoutMethodRequest(
            type: PayoutMethodType.bankTransfer,
            accountHolderName: 'Ayesha Khan',
            destination: 'PK36SCBL0000001123456702',
            bankName: 'Standard Chartered',
          ),
        ),
        isEmpty,
      );
      expect(
        PayoutMethodValidator.validate(
          const PayoutMethodRequest(
            type: PayoutMethodType.easypaisa,
            accountHolderName: 'Ayesha Khan',
            destination: '+923001234567',
          ),
        ),
        isEmpty,
      );
    });

    test('rejects malformed holder, bank, account, and mobile values', () {
      expect(PayoutMethodValidator.validateAccountHolderName('1'), isNotNull);
      expect(PayoutMethodValidator.validateBankName(''), isNotNull);
      expect(PayoutMethodValidator.validateBankDestination('PK12'), isNotNull);
      expect(PayoutMethodValidator.validatePakistaniMobile('03123'), isNotNull);
    });
  });
}

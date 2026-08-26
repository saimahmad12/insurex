import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/validators/payout_method_validator.dart';
import '../../domain/entities/payout_method.dart';
import 'payout_method_card.dart';

class PayoutMethodForm extends StatefulWidget {
  const PayoutMethodForm({
    required this.type,
    required this.onSubmit,
    required this.isLoading,
    super.key,
  });

  final PayoutMethodType type;
  final ValueChanged<PayoutMethodRequest> onSubmit;
  final bool isLoading;

  @override
  State<PayoutMethodForm> createState() => _PayoutMethodFormState();
}

class _PayoutMethodFormState extends State<PayoutMethodForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _holderController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();

  bool get _isBank => widget.type == PayoutMethodType.bankTransfer;

  @override
  void dispose() {
    _holderController.dispose();
    _bankController.dispose();
    _destinationController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      key: ValueKey<String>('payout_method_form_${widget.type.name}'),
      padding: const EdgeInsets.all(17),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${payoutMethodTypeLabel(widget.type)} details',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            _field(
              key: const Key('payout_account_holder_field'),
              controller: _holderController,
              label: 'Account holder name',
              validator: PayoutMethodValidator.validateAccountHolderName,
              textInputAction: TextInputAction.next,
            ),
            if (_isBank) ...<Widget>[
              const SizedBox(height: 12),
              _field(
                key: const Key('payout_bank_name_field'),
                controller: _bankController,
                label: 'Bank name',
                validator: PayoutMethodValidator.validateBankName,
                textInputAction: TextInputAction.next,
              ),
            ],
            const SizedBox(height: 12),
            _field(
              key: const Key('payout_destination_field'),
              controller: _destinationController,
              label: _isBank
                  ? 'IBAN or account number'
                  : 'Registered mobile number',
              keyboardType: _isBank ? TextInputType.text : TextInputType.phone,
              validator: _isBank
                  ? PayoutMethodValidator.validateBankDestination
                  : PayoutMethodValidator.validatePakistaniMobile,
              textInputAction: _isBank
                  ? TextInputAction.next
                  : TextInputAction.done,
            ),
            if (_isBank) ...<Widget>[
              const SizedBox(height: 12),
              _field(
                key: const Key('payout_branch_field'),
                controller: _branchController,
                label: 'Branch information (optional)',
                textInputAction: TextInputAction.done,
              ),
            ],
            const SizedBox(height: 17),
            GlassActionButton(
              key: const Key('verify_payout_method_button'),
              label: 'Verify and Continue',
              icon: Icons.verified_user_outlined,
              isLoading: widget.isLoading,
              onPressed: widget.isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required Key key,
    required TextEditingController controller,
    required String label,
    required TextInputAction textInputAction,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(color: AppColors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: AppColors.white.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.blue),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    widget.onSubmit(
      PayoutMethodRequest(
        type: widget.type,
        accountHolderName: _holderController.text.trim(),
        destination: _destinationController.text.trim(),
        bankName: _isBank ? _bankController.text.trim() : null,
        branchInformation: _isBank ? _branchController.text.trim() : null,
      ),
    );
  }
}

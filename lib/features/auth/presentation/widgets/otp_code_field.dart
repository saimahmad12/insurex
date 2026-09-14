import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    required this.onChanged,
    super.key,
  });

  final ValueChanged<String> onChanged;

  @override
  State<OtpCodeField> createState() {
    return _OtpCodeFieldState();
  }
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  static const int _otpLength = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();

    _controllers = List<TextEditingController>.generate(
      _otpLength,
          (_) => TextEditingController(),
    );

    _focusNodes = List<FocusNode>.generate(
      _otpLength,
          (_) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (final TextEditingController controller
    in _controllers) {
      controller.dispose();
    }

    for (final FocusNode node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  String get _otp {
    return _controllers
        .map(
          (TextEditingController controller) =>
      controller.text,
    )
        .join();
  }

  void _handleChanged(
      String value,
      int index,
      ) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    widget.onChanged(_otp);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(
        _otpLength,
            (int index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right:
                index == _otpLength - 1 ? 0 : 7,
              ),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],

                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,

                // Hide OTP digit
                obscureText: true,
                obscuringCharacter: '●',

                textInputAction:
                index == _otpLength - 1
                    ? TextInputAction.done
                    : TextInputAction.next,

                maxLength: 1,

                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],

                cursorColor: AppColors.blue,

                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),

                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.white.withValues(
                    alpha: 0.08,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  enabledBorder: _border(
                    AppColors.white.withValues(
                      alpha: 0.28,
                    ),
                  ),
                  focusedBorder: _border(
                    AppColors.blue,
                    width: 1.4,
                  ),
                ),

                onChanged: (String value) {
                  _handleChanged(
                    value,
                    index,
                  );
                },
              )
            ),
          );
        },
      ),
    );
  }

  OutlineInputBorder _border(
      Color color, {
        double width = 1,
      }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}

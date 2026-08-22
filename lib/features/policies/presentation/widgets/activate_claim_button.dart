import 'package:flutter/material.dart';

class ActivateClaimButton extends StatelessWidget {
  const ActivateClaimButton({
    required this.onPressed,
    required this.enabled,
    super.key,
  });

  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[
              Color(0xFF4F74FF),
              Color(0xFF815CFF),
              Color(0xFFE25AF5),
            ],
          ),
          borderRadius:
          BorderRadius.circular(18),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
            enabled ? onPressed : null,
            borderRadius:
            BorderRadius.circular(18),
            child: const SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 21,
                  ),

                  SizedBox(width: 9),

                  Text(
                    'Activate for Claim',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
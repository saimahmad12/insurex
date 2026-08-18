import 'package:flutter/material.dart';

class BuyPolicyButton extends StatelessWidget {
  const BuyPolicyButton({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF4F74FF),
            Color(0xFF815CFF),
            Color(0xFFE25AF5),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF815CFF)
                .withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: const SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),

                SizedBox(width: 9),

                Text(
                  'Buy New Policy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
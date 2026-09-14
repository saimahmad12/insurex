import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        key: const Key('logout_confirmation_dialog'),
        backgroundColor: const Color(0xFF151E42),
        title: const Text('Logout', style: TextStyle(color: AppColors.white)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('confirm_logout_button'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFFFFB3BE)),
            ),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

import 'package:flutter/material.dart';

import 'app.dart';
import 'core/storage/auth_token_storage.dart';
import 'features/auth/data/repositories/api_auth_repository.dart';

void main() {
  final SecureAuthTokenStorage tokenStorage =
  SecureAuthTokenStorage();

  final ApiAuthRepository authRepository =
  ApiAuthRepository(
    tokenStorage: tokenStorage,
  );

  runApp(
    InsureXApp(
      authRepository: authRepository,
    ),
  );
}
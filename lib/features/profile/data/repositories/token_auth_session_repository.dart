import '../../../../core/storage/auth_token_storage.dart';
import '../../domain/repositories/auth_session_repository.dart';

class TokenAuthSessionRepository implements AuthSessionRepository {
  TokenAuthSessionRepository({required AuthTokenStorage tokenStorage})
    : _tokenStorage = tokenStorage;

  final AuthTokenStorage _tokenStorage;

  @override
  Future<void> logout() => _tokenStorage.clearTokens();
}

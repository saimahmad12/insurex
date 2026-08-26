abstract interface class ContactChangeRepository {
  Future<void> requestEmailChange(String newEmail);

  Future<void> requestMobileChange(String newMobile);
}

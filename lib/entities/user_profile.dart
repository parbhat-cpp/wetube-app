class UserProfile {
  String id;
  String fullname;
  String? username;
  String? avatarUrl;
  String token;
  bool premiumAccount;

  UserProfile({
    this.id = '',
    this.fullname = '',
    this.username = '',
    this.avatarUrl = '',
    this.token = '',
    this.premiumAccount = false,
  });

  void setUserProfile(String id, String fullname, String username,
      String avatarUrl, bool premiumAccount, String token) {
    this.id = id;
    this.fullname = fullname;
    this.username = username;
    this.avatarUrl = avatarUrl;
    this.token = token;
    this.premiumAccount = premiumAccount;
  }

  Map<String, dynamic> getUserProfile() {
    return {
      'id': id,
      'fullname': fullname,
      'username': username ?? '',
      'avatarUrl': avatarUrl ?? '',
      'token': token,
      'premiumAccount': premiumAccount,
    };
  }
}

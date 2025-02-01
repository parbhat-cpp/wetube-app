class UserProfile {
  String id;
  String fullname;
  String? username;
  String? avatarUrl;
  String token;

  UserProfile(
      {this.id = '',
      this.fullname = '',
      this.username = '',
      this.avatarUrl = '',
      this.token = ''});
  
  void setUserProfile(String id, String fullname, String username, String avatarUrl, String token) {
    this.id = id;
    this.fullname = fullname;
    this.username = username;
    this.avatarUrl = avatarUrl;
    this.token = token;
  }

  Map<String, String> getUserProfile() {
    return {
      'id': id,
      'fullname': fullname,
      'username': username ?? '',
      'avatarUrl': avatarUrl ?? '',
      'token': token,
    };
  }
}

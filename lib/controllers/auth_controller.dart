import 'package:get/get.dart';
import 'package:wetube/entities/user_profile.dart';

class AuthController extends GetxController {
  final Rxn<UserProfile?> userProfile = Rxn<UserProfile>(UserProfile());

  void setUserProfile(String id, String fullname, String? username, String? avatarUrl, bool premiumAccount, String token) {
    userProfile.value!.id = id;
    userProfile.value!.fullname = fullname;
    userProfile.value!.username = username;
    userProfile.value!.avatarUrl = avatarUrl;
    userProfile.value!.token = token;
  }
}

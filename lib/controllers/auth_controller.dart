import 'dart:developer';

import 'package:get/get.dart';
import 'package:wetube/entities/user_profile.dart';

class AuthController extends GetxController {
  final Rxn<UserProfile?> userProfile = Rxn<UserProfile>(UserProfile());

  void setUserProfile(String id, String fullname, String? username, String? avatarUrl, String token) {
    log('$id $fullname $username $avatarUrl $token');
    userProfile.value!.id = id;
    userProfile.value!.fullname = fullname;
    userProfile.value!.username = username;
    userProfile.value!.avatarUrl = avatarUrl;
    userProfile.value!.token = token;
  }
}

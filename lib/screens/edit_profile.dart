import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wetube/controllers/auth_controller.dart';
import 'package:wetube/services/user_service.dart';
import 'package:flutter_regex/flutter_regex.dart';
import 'package:wetube/widgets/update_avatar.dart';
import 'package:wetube/main.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController fullnameController = TextEditingController();

  final TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put<AuthController>(AuthController());
    final UserService userService = Get.find<UserService>();

    void handleUserUpdate() {
      Map userData = {};

      if (fullnameController.text.isNotEmpty) {
        userData['full_name'] = fullnameController.text;
      }

      if (usernameController.text.isNotEmpty) {
        if (!usernameController.text.isUsernameGoogle()) {
          Fluttertoast.showToast(msg: 'Invalid username');
          return;
        }

        userData['username'] = usernameController.text;
      }

      userService.updateUser(
        authController.userProfile.value!.id,
        authController.userProfile.value!.token,
        userData,
      );

      Navigator.of(context).pop();
    }

    Future<void> onUpload(String imageUrl) async {
      try {
        final userId = supabase.auth.currentUser!.id;
        await supabase.from('profiles').update({
          'avatar_url': imageUrl,
        }).eq('id', userId);
        if (mounted) {
          Fluttertoast.showToast(msg: 'Updated your profile image!');
        }
      } on PostgrestException catch (error) {
        Fluttertoast.showToast(msg: error.message);
      } catch (error) {
        if (mounted) {
          Fluttertoast.showToast(msg: 'Unexpected error occurred');
        }
      }
      if (!mounted) {
        return;
      }

      authController.setAvatarUrl(imageUrl);
    }

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(
                    () => Column(
                      children: [
                        UpdateAvatar(
                            imageUrl:
                                authController.userProfile.value!.avatarUrl,
                            onUpload: onUpload),
                      ],
                    ),
                  ),
                  TextField(
                    controller: fullnameController,
                    decoration: InputDecoration(
                      label: const Text('Full Name'),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      label: const Text('Username'),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: handleUserUpdate,
                    child: const Text('Update'),
                  ),
                ],
              ),
            )));
  }
}

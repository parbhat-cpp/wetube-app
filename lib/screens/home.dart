import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wetube/controllers/auth_controller.dart';
import 'package:wetube/entities/user_profile.dart';
import 'package:wetube/screens/auth.dart';
import 'package:wetube/screens/settings.dart';
import 'package:wetube/services/socket_service.dart';
import 'package:wetube/services/user_service.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';

final supabaseClient = Supabase.instance.client;

class HomeStateManager extends GetxController {
  // Tab state
  RxBool createTab = true.obs;

  // Form state
  RxString roomName = ''.obs;
  RxString roomId = ''.obs;
  RxBool isRoomPublic = true.obs;

  void handleChangetab() {
    createTab.value = !createTab.value;
  }

  void handleRoomStateChange(bool value) {
    isRoomPublic.value = value;
  }

  void handleRoomNameChange(String value) {
    roomName.value = value;
  }

  void handleRoomIdChange(String value) {
    roomId.value = value;
  }
}

class Home extends StatelessWidget {
  Home({super.key});

  final Session? session = supabaseClient.auth.currentSession;
  final TextEditingController roomIdText = TextEditingController();

  final createRoomForm = GlobalKey<FormState>();
  final joinRoomForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AuthController authController =
        Get.put<AuthController>(AuthController());

    final HomeStateManager homeStateController =
        Get.put<HomeStateManager>(HomeStateManager());

    final UserService userService = Get.find<UserService>();
    final SocketService socketService = Get.find<SocketService>();

    void handleCreateRoom() {
      if (!createRoomForm.currentState!.validate()) {
        return;
      }

      UserProfile user = UserProfile(
        id: authController.userProfile.value!.id,
        avatarUrl: authController.userProfile.value!.avatarUrl,
        fullname: authController.userProfile.value!.fullname,
        premiumAccount: authController.userProfile.value!.premiumAccount,
        username: authController.userProfile.value!.username,
      );

      var uuid = Uuid();
      String roomId = uuid.v4().substring(0, 8);

      roomIdText.text = roomId;

      String shareRoomText =
          'Hey there! What are you doing?\nLet\'s watch something together.\n\nRoom ID: $roomId';

      showDialog<String>(
        context: context,
        builder: (BuildContext context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Confirm creation',
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  readOnly: true,
                  controller: roomIdText,
                  decoration: InputDecoration(
                    label: const Text('Room ID'),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: roomId),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                OutlinedButton.icon(
                  onPressed: () => Share.share(
                    shareRoomText,
                    subject: 'Share Room',
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
                const SizedBox(
                  width: 10,
                ),
                OutlinedButton(
                  onPressed: () => socketService.createRoom(
                    isPublic: homeStateController.isRoomPublic.value,
                    roomId: roomId,
                    roomName: homeStateController.roomName.value,
                    user: user,
                  ),
                  child: const Text('Create Room'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    void handleJoinRoom() {
      if (!joinRoomForm.currentState!.validate()) {
        return;
      }

      UserProfile user = UserProfile(
        id: authController.userProfile.value!.id,
        avatarUrl: authController.userProfile.value!.avatarUrl,
        fullname: authController.userProfile.value!.fullname,
        premiumAccount: authController.userProfile.value!.premiumAccount,
        username: authController.userProfile.value!.username,
      );

      socketService.joinRoom(
        roomId: homeStateController.roomId.value,
        user: user,
      );
    }

    return SafeArea(
      child: (session != null
          ? Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome",
                      style: TextStyle(fontSize: 12.0),
                    ),
                    Obx(() {
                      return Text(authController.userProfile.value!.fullname);
                    }),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.group),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Settings(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      child: authController.userProfile.value!.avatarUrl != null
                          ? CachedNetworkImage(
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: 80.0,
                                height: 80.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              imageUrl:
                                  authController.userProfile.value!.avatarUrl!,
                            )
                          : Text(authController.userProfile.value!.fullname
                              .split('')[0][0]),
                    ),
                  )
                ],
              ),
              body: Center(
                child: FutureBuilder<void>(
                  future: userService.getUserProfile(
                    session!.user.id,
                    session!.accessToken,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Obx(() {
                                  return GestureDetector(
                                    onTap: () {
                                      homeStateController.handleChangetab();
                                    },
                                    child: Container(
                                      width:
                                          ((MediaQuery.of(context).size.width *
                                                  0.8) /
                                              2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12.0),
                                          bottomLeft: Radius.circular(12.0),
                                        ),
                                        color: homeStateController
                                                    .createTab.value ==
                                                true
                                            ? Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHigh
                                            : null,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHigh,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: const Text(
                                          'Create',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                Obx(() {
                                  return GestureDetector(
                                    onTap: () {
                                      homeStateController.handleChangetab();
                                    },
                                    child: Container(
                                      width:
                                          ((MediaQuery.of(context).size.width *
                                                  0.8) /
                                              2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(12.0),
                                          bottomRight: Radius.circular(12.0),
                                        ),
                                        color: homeStateController
                                                    .createTab.value ==
                                                false
                                            ? Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHigh
                                            : null,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHigh,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: const Text(
                                          'Join',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                              borderRadius: BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Obx(() {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18.0, vertical: 5.0),
                                    child: homeStateController
                                                .createTab.value ==
                                            true
                                        ? Form(
                                            key: createRoomForm,
                                            child: Column(
                                              children: [
                                                TextFormField(
                                                  validator: (value) =>
                                                      value!.isEmpty
                                                          ? 'Enter room name'
                                                          : null,
                                                  onChanged: homeStateController
                                                      .handleRoomNameChange,
                                                  decoration: InputDecoration(
                                                    label: const Text(
                                                      'Room Name',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Form(
                                            key: joinRoomForm,
                                            child: Column(
                                              children: [
                                                TextFormField(
                                                  validator: (value) =>
                                                      value!.isEmpty
                                                          ? 'Enter room id'
                                                          : null,
                                                  onChanged: homeStateController
                                                      .handleRoomIdChange,
                                                  decoration: InputDecoration(
                                                    label: const Text(
                                                      'Room ID',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  );
                                }),
                                Obx(() {
                                  if (homeStateController.createTab.value) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Public',
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                          Switch(
                                            value: homeStateController
                                                .isRoomPublic.value,
                                            onChanged: homeStateController
                                                .handleRoomStateChange,
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Obx(() {
                                    return OutlinedButton(
                                      onPressed:
                                          homeStateController.createTab.value
                                              ? handleCreateRoom
                                              : handleJoinRoom,
                                      child: Text(
                                        homeStateController.createTab.value
                                            ? 'Create Room'
                                            : 'Join Room',
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            )
          : Auth()),
    );
  }
}

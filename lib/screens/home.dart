import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wetube/controllers/auth_controller.dart';
import 'package:wetube/screens/auth.dart';
import 'package:wetube/screens/settings.dart';
import 'package:wetube/services/user_service.dart';

final supabase = Supabase.instance.client;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Session? session = supabase.auth.currentSession;

  bool createTab = true;

  @override
  Widget build(BuildContext context) {
    final AuthController authController =
        Get.put<AuthController>(AuthController());

    final UserService userService = Get.find<UserService>();

    void handleCreateRoom() {}

    void handleJoinRoom() {}

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
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      createTab = true;
                                    });
                                  },
                                  child: Container(
                                    width: ((MediaQuery.of(context).size.width *
                                            0.8) /
                                        2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12.0),
                                        bottomLeft: Radius.circular(12.0),
                                      ),
                                      color: createTab == true
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
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      createTab = false;
                                    });
                                  },
                                  child: Container(
                                    width: ((MediaQuery.of(context).size.width *
                                            0.8) /
                                        2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(12.0),
                                        bottomRight: Radius.circular(12.0),
                                      ),
                                      color: createTab == false
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
                                ),
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0, vertical: 5.0),
                                  child: createTab == true
                                      ? Form(
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                decoration: InputDecoration(
                                                  label: const Text(
                                                    'Admin Name',
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              TextFormField(
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
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                decoration: InputDecoration(
                                                  label: const Text(
                                                    'Room ID',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: OutlinedButton(
                                    onPressed: createTab
                                        ? handleCreateRoom
                                        : handleJoinRoom,
                                    child: Text(
                                      createTab ? 'Create Room' : 'Join Room',
                                    ),
                                  ),
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

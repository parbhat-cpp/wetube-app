import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wetube/controllers/auth_controller.dart';
import 'package:wetube/entities/user_profile.dart';
import 'package:wetube/services/rooms_service.dart';
import 'package:wetube/services/socket_service.dart';

class PublicRooms extends StatelessWidget {
  const PublicRooms({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController =
        Get.put<AuthController>(AuthController());

    final RoomService roomService = Get.find<RoomService>();
    final SocketService socketService = Get.find<SocketService>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Public Rooms'),
        ),
        body: FutureBuilder(
            future: roomService
                .getPublicRooms(authController.userProfile.value!.token),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: const CircularProgressIndicator(),
                );
              } else {
                if (roomService.publicRooms.isEmpty) {
                  return Center(
                    child: const Text('No Public Rooms'),
                  );
                }

                return Obx(
                  () => ListView.builder(
                      itemCount: roomService.publicRooms.length + 1,
                      itemBuilder: (context, index) {
                        if (index == roomService.publicRooms.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  roomService.getPublicRooms(
                                      authController.userProfile.value!.token);
                                },
                                child: Text(
                                  'Load More',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        String roomName =
                            roomService.publicRooms[index]['roomName'];
                        String roomId =
                            roomService.publicRooms[index]['roomId'];
                        String admin =
                            roomService.publicRooms[index]['roomAdmin'];

                        return ListTile(
                          title: Text('Room name: $roomName'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Room ID: $roomId'),
                              Text('Admin: $admin'),
                            ],
                          ),
                          onTap: () {
                            UserProfile user = UserProfile(
                              id: authController.userProfile.value!.id,
                              avatarUrl:
                                  authController.userProfile.value!.avatarUrl,
                              fullname:
                                  authController.userProfile.value!.fullname,
                              premiumAccount: authController
                                  .userProfile.value!.premiumAccount,
                              username:
                                  authController.userProfile.value!.username,
                            );

                            socketService.joinRoom(roomId: roomId, user: user);
                          },
                        );
                      }),
                );
              }
            }),
      ),
    );
  }
}

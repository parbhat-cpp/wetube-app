import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wetube/main.dart';
import 'package:wetube/services/socket_service.dart';

class RoomStateManager extends GetxController {}

class Room extends StatelessWidget {
  Room({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    RoomStateManager roomStateManager =
        Get.put<RoomStateManager>(RoomStateManager());

    SocketService socketService = Get.find<SocketService>();

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              onPressed: socketService.exitRoom,
              icon: const Icon(Icons.arrow_back),
            );
          }),
          title: Obx(
            () => Text('${socketService.currentRoomName}'),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                _scaffoldKey.currentState!.openEndDrawer();
              },
              icon: Icon(Icons.group),
            ),
          ],
        ),
        endDrawer: Obx(
          () => Drawer(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: ListView.builder(
                  itemCount: socketService.roomAttendees.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> admin = socketService.roomAttendees[0];
                    Map<String, dynamic> currentUser =
                        socketService.roomAttendees[index];

                    String username =
                        currentUser['username'] ?? currentUser['full_name'];
                    String? avatarUrl = currentUser['avatar_url'];

                    return ListTile(
                      leading: CircleAvatar(
                        child: avatarUrl != null
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
                                imageUrl: avatarUrl,
                              )
                            : Text(username.split('')[0][0]),
                      ),
                      title: Text(
                          '$username ${admin['id'] == currentUser['id'] ? '(Admin)' : ''}'),
                      trailing: admin['id'] ==
                                  supabase.auth.currentSession!.user.id &&
                              admin['id'] != currentUser['id']
                          ? IconButton(
                              onPressed: () {
                                socketService.removeAttendee(
                                    userId: currentUser['socketId']);
                              },
                              icon: Icon(Icons.person_remove_alt_1),
                            )
                          : null,
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }
}

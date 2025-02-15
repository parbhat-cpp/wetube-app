import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wetube/controllers/auth_controller.dart';
import 'package:wetube/entities/user_profile.dart';
import 'package:wetube/main.dart';
import 'package:wetube/screens/youtube_search.dart';
import 'package:wetube/services/socket_service.dart';
import 'package:wetube/widgets/chat.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RoomStateManager extends GetxController {
  Rx<TextEditingController> chatController = TextEditingController().obs;
  YoutubePlayerController youtubePlayerController = YoutubePlayerController(
      initialVideoId: '1BfCnjr_Vjg',
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

  void setChatText(String text) {
    chatController.value.text = text;
  }

  void setVideo(String videoId) {
    youtubePlayerController.load(videoId);
    youtubePlayerController.play();
  }

  void destroy() {
    youtubePlayerController.dispose();
  }
}

class Room extends StatelessWidget {
  Room({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SocketService socketService = Get.find<SocketService>();

    AuthController authController = Get.put<AuthController>(AuthController());
    RoomStateManager roomStateManager =
        Get.put<RoomStateManager>(RoomStateManager());

    void handleSendMessage() {
      String message = roomStateManager.chatController.value.text;
      UserProfile user = UserProfile(
        id: authController.userProfile.value!.id,
        avatarUrl: authController.userProfile.value!.avatarUrl,
        fullname: authController.userProfile.value!.fullname,
        premiumAccount: authController.userProfile.value!.premiumAccount,
        username: authController.userProfile.value!.username,
      );

      socketService.sendMessage(user: user, message: message);

      roomStateManager.setChatText('');
    }

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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => YoutubeSearch(),
                  ),
                );
              },
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
        body: Column(
          children: [
            YoutubePlayer(
              controller: roomStateManager.youtubePlayerController,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () => ListView.builder(
                      itemCount: socketService.chats.length,
                      itemBuilder: (context, index) {
                        String message = socketService.chats[index]['message'];
                        Map<String, dynamic> user =
                            socketService.chats[index]['sendBy'];
                        String myUserId = supabase.auth.currentSession!.user.id;

                        return Row(
                          children: [
                            if (user['id'] == myUserId)
                              const Spacer(
                                flex: 1,
                              ),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              child: Chat(
                                text: message,
                                username: myUserId == user['id']
                                    ? 'Me'
                                    : user['username'] ?? user['full_name'],
                                isMe: myUserId == user['id'],
                              ),
                            ),
                          ],
                        );
                      }),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                padding: const EdgeInsets.all(2),
                child: TextField(
                  controller: roomStateManager.chatController.value,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    isDense: true,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(width: 1),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        handleSendMessage();
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ),
                  onSubmitted: (msg) {
                    handleSendMessage();
                  },
                ),
              ),
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

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:wetube/controllers/auth_controller.dart';
import 'package:wetube/entities/user_profile.dart';
import 'package:wetube/main.dart';
import 'package:wetube/screens/home.dart';
import 'package:wetube/screens/room.dart';
import 'package:wetube/utils/duration.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SocketService extends GetxService {
  late io.Socket socket;

  RxString currentRoomId = ''.obs;
  RxString currentRoomName = ''.obs;
  RxList roomAttendees = [].obs;
  RxList chats = [].obs;

  late RoomStateManager roomStateManager;
  late AuthController authController;

  SocketService init() {
    roomStateManager = Get.find<RoomStateManager>();
    authController = Get.find<AuthController>();

    socket = io.io(
      dotenv.env['BACKEND_URL'],
      io.OptionBuilder()
          .setTransports(
            ['websocket', 'polling'],
          )
          .setExtraHeaders({
            'Authorization':
                'Bearer ${supabase.auth.currentSession?.accessToken}',
            'Connection': 'Upgrade',
            'Upgrade': 'websocket',
          })
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((data) {
    });

    socket.onConnectError((data) {
    });

    socket.onerror((err) {
    });

    registerListeners();

    return this;
  }

  void setVideoId(String videoId) {
    roomStateManager.setVideo(videoId);
  }

  void registerListeners() {
    socket.on('room-exists', (data) {
      Fluttertoast.showToast(msg: 'Room already exists');
    });

    socket.on('room-created', (data) {
      Map<String, dynamic> roomData = jsonDecode(data[currentRoomId]);

      log(roomData.toString());

      currentRoomName.value = roomData['roomName'];
      roomAttendees.value = roomData['attendees'];

      Get.to(Room());
    });

    socket.on("room-limit-reached", (data) {
      Fluttertoast.showToast(msg: 'Room is full');
    });

    socket.on("enter-room", (data) {
      Map<String, dynamic> roomData = jsonDecode(data[currentRoomId]);

      log(roomData.toString());

      currentRoomName.value = roomData['roomName'];
      roomAttendees.value = roomData['attendees'];

      Get.to(Room());
    });

    socket.on("new-attendee", (data) {
      roomAttendees.add(data);

      Fluttertoast.showToast(
          msg: '${data.username ?? data.full_name} joined the room');
    });

    socket.on("room-not-found", (data) {
      Fluttertoast.showToast(msg: 'Room not found');
    });

    socket.on('leave-room', (data) {
      currentRoomId.value = '';
      currentRoomName.value = '';
      roomAttendees.value = [];
      chats.value = [];

      Get.to(Home());
    });

    socket.on('attendee-left', (data) {
      Fluttertoast.showToast(msg: '$data left');
    });

    socket.on('attendee-kicked', (user) {
      roomAttendees.removeWhere((attendee) => attendee['id'] == user['id']);

      Fluttertoast.showToast(
          msg: '${user['username'] ?? user['full_name']} removed by the admin');
    });

    socket.on('receive-message', (chat) {
      chats.add(chat);
    });

    socket.on('set-video-id', (videoData) {
      String username = videoData['username'];
      String videoId = videoData['videoId'];

      setVideoId(videoId);

      Fluttertoast.showToast(msg: '$username set new video');
    });

    socket.on('set-video-pause', (data) {
      String username = data['username'];

      roomStateManager.youtubePlayerController.pause();

      Fluttertoast.showToast(msg: 'Video paused by $username');
    });

    socket.on('set-video-play', (data) {
      String username = data['username'];

      roomStateManager.youtubePlayerController.play();

      Fluttertoast.showToast(msg: 'Video played by $username');
    });

    socket.on('seek-to-video', (data) {
      String username = data['username'];

      Duration position = parseDuration(data['position']);
      roomStateManager.youtubePlayerController.seekTo(position);

      Fluttertoast.showToast(msg: 'Video seeked by $username');
    });

    // Youtube player listener
    roomStateManager.youtubePlayerController.addListener(() {
      if (roomStateManager.youtubePlayerController.value.playerState ==
          PlayerState.paused) {
        socket.emit('pause-video', {
          "username": authController.userProfile.value!.username ?? authController.userProfile.value!.fullname,
          "roomId": currentRoomId.value,
        });
      }
      if (roomStateManager.youtubePlayerController.value.isDragging) {
        Duration currentPosition =
            roomStateManager.youtubePlayerController.value.position;

        socket.emit('seek-video', {
          "roomId": currentRoomId.value,
          "position": currentPosition.toString(),
          "username": authController.userProfile.value!.username ?? authController.userProfile.value!.fullname,
        });
      }
    });
  }

  void createRoom({
    required String roomId,
    required String roomName,
    required bool isPublic,
    required UserProfile user,
  }) {
    currentRoomId.value = roomId;

    socket.emit('create-room', {
      "roomId": roomId,
      "roomAdmin": user.username ?? user.fullname,
      "roomName": roomName,
      "isPublic": isPublic,
      "user": {
        "id": user.id,
        "avatar_url": user.avatarUrl,
        "full_name": user.fullname,
        "premium_account": user.premiumAccount,
        "socketId": "",
        "username": user.username,
      }
    });
  }

  void joinRoom({
    required String roomId,
    required UserProfile user,
  }) {
    currentRoomId.value = roomId;

    socket.emit('join-room', {
      "roomId": roomId,
      "user": {
        "id": user.id,
        "avatar_url": user.avatarUrl,
        "full_name": user.fullname,
        "premium_account": user.premiumAccount,
        "socketId": "",
        "username": user.username,
      }
    });
  }

  void exitRoom() {
    socket.emit('exit-room', currentRoomId.value);

    currentRoomId.value = '';
    currentRoomName.value = '';
    roomAttendees.value = [];
    chats.value = [];

    Get.to(Home());
  }

  void removeAttendee({
    required String userId,
  }) {
    socket.emit('remove-attendee', {
      "roomId": currentRoomId.value,
      "userId": userId,
    });
  }

  void sendMessage({
    required UserProfile user,
    required String message,
  }) {
    socket.emit('send-message', {
      "roomId": currentRoomId.value,
      "user": {
        "id": user.id,
        "socketId": "",
        "full_name": user.fullname,
        "username": user.username,
        "avatar_url": user.avatarUrl,
        "premium_account": user.premiumAccount,
      },
      "message": message,
    });

    chats.add({
      "sendBy": {
        "id": user.id,
        "socketId": "",
        "full_name": user.fullname,
        "username": user.username,
        "avatar_url": user.avatarUrl,
        "premium_account": user.premiumAccount,
      },
      "message": message,
    });
  }

  void setVideo({
    required String videoId,
    required String username,
  }) {
    socket.emit('set-video', {
      "roomId": currentRoomId.value,
      "username": username,
      "videoId": videoId,
    });
  }

  @override
  void onClose() {
    roomStateManager.destroy();
    super.onClose();
  }
}

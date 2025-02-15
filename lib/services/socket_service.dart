import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:wetube/entities/user_profile.dart';
import 'package:wetube/main.dart';
import 'package:wetube/screens/home.dart';
import 'package:wetube/screens/room.dart';

class SocketService extends GetxService {
  late io.Socket socket;

  RxString currentRoomId = ''.obs;
  RxString currentRoomName = ''.obs;
  RxList roomAttendees = [].obs;
  RxList chats = [].obs;

  late RoomStateManager roomStateManager;

  @override
  void onInit() {
    roomStateManager = Get.find<RoomStateManager>();
    super.onInit();
  }

  SocketService init() {
    socket = io.io(
      dotenv.env['BACKEND_URL'],
      io.OptionBuilder()
          .setTransports(
            ['websocket', 'polling'],
          )
          .setExtraHeaders({
            'Authorization':
                'Bearer ${supabase.auth.currentSession?.accessToken ?? ''}',
            'Connection': 'Upgrade',
            'Upgrade': 'websocket',
          })
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((data) {
      Fluttertoast.showToast(msg: 'Server Connected');
    });

    socket.onConnectError((data) {
      log(data.toString());
      Fluttertoast.showToast(msg: 'Failed to connect server');
    });

    socket.onerror((err) {
      Fluttertoast.showToast(msg: err);
    });

    registerListeners();

    return this;
  }

  void setVideoId(String videoId) {
    roomStateManager.setVideo(videoId);
    // youtubePlayerController.load(videoId);
    // youtubePlayerController.play();
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

  @override
  void onClose() {
    roomStateManager.destroy();
    super.onClose();
  }
}

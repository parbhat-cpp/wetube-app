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

  SocketService init() {
    socket = io.io(
      dotenv.env['BACKEND_URL'],
      io.OptionBuilder()
          .setTransports(
            ['websocket', 'polling'],
          )
          .setExtraHeaders({
            'Authorization':
                'Bearer ${supabase.auth.currentSession!.accessToken}',
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
}

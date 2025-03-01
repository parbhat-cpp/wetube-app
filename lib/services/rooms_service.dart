import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

class RoomService extends GetxService {
  Map<int, bool> cursorVisited = {};

  RxList publicRooms = [].obs;

  RxInt cursor = 0.obs;
  int count = 5;

  final String userProfileBaseUrl = '${dotenv.env['BACKEND_URL']}/rooms';
  final _dio = dio.Dio();

  Future<void> getPublicRooms(String token) async {
    try {
      if (cursorVisited.containsKey(cursor.value)) {
        Fluttertoast.showToast(msg: 'No more rooms available');
        return;
      }

      String getPublicRoomsUrl = '$userProfileBaseUrl/?cursor=$cursor&count=5';

      final response = await _dio.get(
        getPublicRoomsUrl,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      Map publicRoomsData = response.data;

      cursorVisited[cursor.value] = true;
      cursor.value = int.parse(publicRoomsData['nextCursor']);

      List rooms = [];

      for (int i = 0; i < publicRoomsData['data'].length; i++ ) {
        rooms.add(jsonDecode(publicRoomsData['data'][i]));
      }

      publicRooms.value = [...publicRooms, ...rooms];
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 12.0,
      );
    }
  }
}

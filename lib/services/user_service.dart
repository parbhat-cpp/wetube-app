import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:wetube/controllers/auth_controller.dart';

class UserService extends GetxService {
  final String userProfileBaseUrl = '${dotenv.env['BACKEND_URL']}/user';
  final _dio = dio.Dio();

  Future<void> getUserProfile(String id, String token) async {
    try {
      final AuthController authController = Get.put(AuthController());

      String fetchProfileUrl = '$userProfileBaseUrl/$id';

      final response = await _dio.get(
        fetchProfileUrl,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      Map resBody = response.data;

      authController.setUserProfile(
        id,
        resBody['full_name'],
        resBody['username'],
        resBody['avatar_url'],
        resBody['premium_account'],
        token,
      );
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

  Future<void> deleteAccount(String userId, String token) async {
    try {
      String deleteAccounfUrl = '$userProfileBaseUrl/$userId';

      final response = await _dio.delete(
        deleteAccounfUrl,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
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

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class YoutubeServices extends GetxService {
  final dio = Dio();

  static String youtubeApiUrl = 'https://www.googleapis.com/youtube/v3';

  late Map<String, dynamic> searchFilter;
  RxList searchResult = [].obs;

  late String nextPageToken;

  YoutubeServices() {
    nextPageToken = '';
    searchResult.value = [];

    searchFilter = {
      "maxResults": 10,
    };
  }

  Future<void> search(String searchQuery, bool loadNext) async {
    String searchUrl =
        '$youtubeApiUrl/search?key=${dotenv.env['YOUTUBE_API_KEY']}&q=$searchQuery&maxResults=${searchFilter['maxResults']}&type=video&part=snippet';

    if (loadNext) {
      searchUrl = '$searchUrl&pageToken=$nextPageToken';
    }

    if (!loadNext) {
      searchResult.value = [];
    }

    final searchResponse = await dio.get(searchUrl);

    if (searchResponse.statusCode == 200) {
      final searchResultJson = searchResponse.data;
      log(searchResultJson.toString());

      nextPageToken = searchResultJson['nextPageToken'];

      List<dynamic> searchData = searchResultJson['items'];
      List<Map<String, dynamic>> searchDataList = [];

      for (int i = 0; i < searchData.length; i++) {
        String? videoId = searchData[i]['id']!['videoId'];

        if (videoId == null) continue;

        String videoTitle = searchData[i]['snippet']['title'];
        String thumbnailUrl =
            searchData[i]['snippet']['thumbnails']['default']['url'];
        int thumbnailWidth =
            searchData[i]['snippet']['thumbnails']['default']['width'];
        int thumbnailHeight =
            searchData[i]['snippet']['thumbnails']['default']['height'];

        searchDataList.add({
          "videoId": videoId,
          "title": videoTitle,
          "thumbnailUrl": thumbnailUrl,
          "thumbnailWidth": thumbnailWidth.toDouble(),
          "thumbnailHeight": thumbnailHeight.toDouble()
        });
      }

      searchResult.value = [...searchResult, ...searchDataList];
    } else {
      throw Exception('Failed to load data');
    }
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wetube/controllers/auth_controller.dart';
import 'package:wetube/screens/room.dart';
import 'package:wetube/services/socket_service.dart';
import 'package:wetube/services/youtube_services.dart';

class YoutubeSearchStateManager extends GetxController {
  RxBool isLoading = false.obs;

  void setIsLoading(bool loading) {
    isLoading.value = loading;
  }
}

class YoutubeSearch extends StatelessWidget {
  YoutubeSearch({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    YoutubeServices youtubeServices = Get.find<YoutubeServices>();
    SocketService socketService = Get.find<SocketService>();

    AuthController authController = Get.put<AuthController>(AuthController());

    YoutubeSearchStateManager youtubeSearchStateManager =
        Get.put<YoutubeSearchStateManager>(YoutubeSearchStateManager());

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                youtubeServices.searchResult.value = [];
                Get.to(Room());
              },
              icon: const Icon(Icons.arrow_back),
            );
          }),
          title: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search',
            ),
            onSubmitted: (search) {
              youtubeServices.search(search, false);
            },
          ),
        ),
        body: Obx(() {
          if (youtubeServices.searchResult.isEmpty) {
            return Center(
              child: const Text('Search something...'),
            );
          } else {
            return ListView.builder(
                itemCount: youtubeServices.searchResult.length + 1,
                itemBuilder: (context, index) {
                  if (index == youtubeServices.searchResult.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: youtubeSearchStateManager.isLoading.value
                            ? CircularProgressIndicator()
                            : ElevatedButton(
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
                                  youtubeSearchStateManager.setIsLoading(true);

                                  youtubeServices.search(
                                      searchController.text, true);

                                  youtubeSearchStateManager.setIsLoading(false);
                                },
                                child: Text(
                                  'Load More',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                              ),
                      ),
                    );
                  }

                  double thumbnailWidth =
                      youtubeServices.searchResult[index]['thumbnailHeight'];
                  double thumbnailHeight =
                      youtubeServices.searchResult[index]['thumbnailHeight'];
                  String videoTitle =
                      youtubeServices.searchResult[index]['title'];
                  String imageSrc =
                      youtubeServices.searchResult[index]['thumbnailUrl'];
                  String videoId =
                      youtubeServices.searchResult[index]['videoId'];

                  return SizedBox(
                    height: 60,
                    child: ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: imageSrc,
                        width: thumbnailWidth,
                        height: thumbnailHeight,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: Text('Loading...'),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      title: Text(
                        videoTitle,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.clip,
                      ),
                      onTap: () {
                        socketService.setVideoId(videoId);

                        socketService.setVideo(
                          videoId: videoId,
                          username:
                              authController.userProfile.value!.username ??
                                  authController.userProfile.value!.fullname,
                        );

                        Navigator.of(context).pop();
                      },
                    ),
                  );
                });
          }
        }),
      ),
    );
  }
}

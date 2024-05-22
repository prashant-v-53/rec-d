import 'dart:developer';

import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/api_variable_key.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:http/http.dart' as http;

class PodcastRepo {
  Future fetchBestPodcast({int page}) async {
    String url =
        "${Global.podcastApiBaseUrl}${API.BEST_PODCAST}page=$page&region=us&safe_mode=0&only_in=title&region=us";

    final response = await http.get(
      url,
      headers: {"${PrefsKey.PODCAST_HEADER}": "${Global.podcastToken}"},
    );
    return response;
  }

  Future fetchPodCast({String podCastId}) async {
    try {
      String url = "${Global.podcastApiBaseUrl}${API.VIEW_PODCAST}$podCastId";
      final response = await http.get(url,
          headers: {"${PrefsKey.PODCAST_HEADER}": "${Global.podcastToken}"});
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future fetchRelatedPodcast({String podCastId}) async {
    try {
      String url =
          "${Global.podcastApiBaseUrl}${API.VIEW_PODCAST}/$podCastId/recommendations?safe_mode=0";

      final response = await http.get(
        url,
        headers: {"${PrefsKey.PODCAST_HEADER}": "${Global.podcastToken}"},
      );

      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }
}

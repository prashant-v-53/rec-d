import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/model/books/books.dart';
import 'package:recd/model/category_model.dart';
import 'package:recd/model/podcast/podcast_model.dart';
import 'package:recd/model/trending/movie.dart';
import 'package:http/http.dart' as http;
import 'package:recd/model/tv_show/tv_show_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/podcast_repo/podcast_repo.dart';
import 'package:recd/repository/trending/trending_auth.dart';

class TrendingController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController movieSC = ScrollController();
  ScrollController tvShowSC = ScrollController();
  ScrollController podCastSC = ScrollController();
  // ScrollController bookSC = ScrollController();

  TabController controller;

  bool isInternet;
  bool isLoading = false;
  bool isDataLoaded = true;
  bool isTvShowsLoaded = true;
  bool isPodCastLoaded = true;
  bool isbookLoaded = true;

  bool isMoviePaginationStop = false;
  bool isTvPaginationStop = false;

  int topIndex = 0;
  int moviePageNumber = 1;
  int tvShowPageNumber = 1;
  int podCastPageNumber = 1;
  int bookPageNumber = 0;

  String type = "movie";
  String trendingType = "day";

  List<Movie> movieList = [];
  List<TvShows> tvShowList = [];
  List<BookModel> booksList = [];
  List<Category> categoryList = [];
  List<PodcastModel> podcastList = [];

  List<Widget> tabbar = [
    Center(child: Text("Movies")),
    Center(child: Text("TV Shows")),
    Center(child: Text("Books")),
    Center(child: Text("Podcasts"))
  ];

  void changeTopIndex(int value) {
    setState(() => topIndex = value);
  }

  loadingListener() async {
    movieSC.addListener(() {
      if (movieSC.position.pixels == movieSC.position.maxScrollExtent) {
        fetchMovie().then((v) {
          setState(() => movieList.addAll(v));
        });
      }
    });

    tvShowSC.addListener(() {
      if (tvShowSC.position.pixels == tvShowSC.position.maxScrollExtent) {
        fetchTvShows().then((v) {
          setState(() => tvShowList.addAll(v));
        });
      }
    });

    podCastSC.addListener(() {
      if (podCastSC.position.pixels == podCastSC.position.maxScrollExtent) {
        fetchPodcast().then((v) {
          setState(() => podcastList.addAll(v));
        });
      }
    });
    // bookSC.addListener(() {
    //   if (bookSC.position.pixels == bookSC.position.maxScrollExtent) {
    //     fetchBooks().then((v) {
    //       setState(() {
    //         booksList.addAll(v);
    //         final ids = booksList.map((e) => e.id).toSet();
    //         booksList.retainWhere((x) => ids.remove(x.id));
    //       });
    //     });
    //   }
    // });
  }

  tabListner() async {
    controller.addListener(() {
      if (controller.index == 1) {
        if (tvShowList.isEmpty) {
          fetchTvShows().then((value) {
            setState(() {
              tvShowList = value;
              isTvShowsLoaded = false;
            });
          });
        } else {
          setState(() => isTvShowsLoaded = false);
        }
      } else if (controller.index == 2) {
        if (booksList.isEmpty) {
          fetchBooks().then((value) {
            setState(() {
              booksList = value;
              final ids = booksList.map((e) => e.id).toSet();
              booksList.retainWhere((x) => ids.remove(x.id));
              isbookLoaded = false;
            });
          });
        } else {
          setState(() => isbookLoaded = false);
        }
      } else if (controller.index == 3) {
        if (podcastList.isEmpty) {
          fetchPodcast().then((value) {
            setState(() {
              podcastList = value;
              isPodCastLoaded = false;
            });
          });
        } else {
          setState(() => isPodCastLoaded = false);
        }
      }
    });
  }

  Future<List<Movie>> fetchMovie() async {
    try {
      List<Movie> mList = [];
      setState(() => isLoading = true);
      http.Response response = await TrendingRepo().getTrendingMovie(
          page: moviePageNumber, trendingType: trendingType, type: type);
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        setState(() => isLoading = false);
        res['results'].forEach((val) {
          Movie movie = Movie(
            movieId: val['id'],
            movieTitle: val['title'],
            movieCategory: val['genre_ids'],
            movieImage: val['poster_path'],
            releaseDate: val['release_date'],
            desc: val['overview'],
          );
          setState(() => mList.add(movie));
        });
        setState(() => moviePageNumber++);
        return mList;
      } else if (response.statusCode == 400) {
        var res = json.decode(response.body);
        if (res['status_code'] == 22) {
          setState(() => isMoviePaginationStop = true);
          return null;
        } else {
          toast("Something went wrong");
          setState(() => isLoading = false);
          return null;
        }
      } else {
        toast("Something went wrong1");
        setState(() => isLoading = false);
        return null;
      }
    } catch (e) {
      toast("Something went wrong");
      setState(() => isLoading = false);
      log('$e');
      return null;
    }
  }

  Future<List<TvShows>> fetchTvShows() async {
    try {
      List<TvShows> tvShowList = [];
      http.Response response = await TrendingRepo().getTrendingTvShow(
          type: type, trendingType: trendingType, tvShowPage: tvShowPageNumber);

      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        setState(() => isLoading = false);
        res['results'].forEach((val) {
          TvShows movie = TvShows(
              id: val['id'],
              name: val['name'],
              category: val['genre_ids'],
              image: val['poster_path'],
              desc: val['overview'],
              releaseDate: val['first_air_date']);
          setState(() => tvShowList.add(movie));
        });
        setState(() => tvShowPageNumber++);
        return tvShowList;
      } else if (response.statusCode == 400) {
        var res = json.decode(response.body);
        if (res['status_code'] == 22) {
          setState(() => isTvPaginationStop = true);
          return null;
        } else {
          toast("Something went wrong");
          setState(() => isLoading = false);
          return null;
        }
      } else {
        toast("Something went wrong");
        setState(() => isLoading = false);
        return null;
      }
    } catch (e) {
      toast("Something went wrong");
      setState(() => isLoading = false);
      return null;
    }
  }

  Future<List<PodcastModel>> fetchPodcast() async {
    try {
      List<PodcastModel> mList = [];
      setState(() => isLoading = true);
      http.Response response =
          await PodcastRepo().fetchBestPodcast(page: podCastPageNumber);
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        setState(() => isLoading = false);
        res['podcasts'].forEach((val) {
          PodcastModel podcast = PodcastModel(
              podCastId: val['id'],
              podCastImage: val['thumbnail'],
              category: val['genre_ids'],
              podCastName: val['title'],
              publisher: val['publisher']);
          setState(() => mList.add(podcast));
        });
        setState(() => podCastPageNumber++);
        return mList;
      } else if (response.statusCode == 400) {
        var res = json.decode(response.body);
        if (res['status_code'] == 22) {
          // setState(() => isMoviePaginationStop = true);
          return null;
        } else {
          toast("Something went wrong");
          setState(() => isLoading = false);
          return null;
        }
      } else {
        toast("Something went wrong");
        setState(() => isLoading = false);
        return null;
      }
    } catch (e) {
      toast("Something went wrong");
      setState(() => isLoading = false);
      return null;
    }
  }

  Future<List<BookModel>> fetchBooks() async {
    try {
      String url = "${App.RECd_URL}api/v1/recd/get-trending-books-list";

      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<BookModel> bookList = [];
        var res = json.decode(response.body);
        res['data'].forEach((val) {
          setState(() {
            bookList.add(
              BookModel(
                id: val['id'].toString(),
                title: val['volumeInfo']['title'].toString(),
                image: val['volumeInfo'].containsKey('imageLinks')
                    ? val['volumeInfo']['imageLinks']['smallThumbnail']
                        .toString()
                    : Global.staticRecdImageUrl,
                releaseDate: val['volumeInfo']['publishedDate'],
                authors: val['volumeInfo'].containsKey('authors')
                    ? val['volumeInfo']['authors']
                    : ["N/A"],
              ),
            );
          });
        });
        setState(() => bookPageNumber = bookPageNumber + 20);
        return bookList;
      } else if (response.statusCode == 400) {
        toast("Something went wrong");
        return null;
      } else {
        toast("Something went wrong");
        return null;
      }
    } catch (e) {
      toast("Something went wrong");
      log('$e');
      return null;
    }
  }

  /*

  Future<List<BookModel>> fetchBooks() async {
    try {
      String url =
          "https://www.googleapis.com/books/v1/volumes?q=2020&orderBy=newest&maxResults=20&startIndex=$bookPageNumber";

      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<BookModel> bookList = [];
        var res = json.decode(response.body);
        res['items'].forEach((val) {
          setState(() {
            bookList.add(
              BookModel(
                id: val['id'].toString(),
                title: val['volumeInfo']['title'].toString(),
                image: val['volumeInfo'].containsKey('imageLinks')
                    ? val['volumeInfo']['imageLinks']['smallThumbnail']
                        .toString()
                    : Global.staticRecdImageUrl,
                releaseDate: val['volumeInfo']['publishedDate'],
                authors: val['volumeInfo'].containsKey('authors')
                    ? val['volumeInfo']['authors']
                    : ["N/A"],
              ),
            );
          });
        });
        setState(() => bookPageNumber = bookPageNumber + 20);
        return bookList;
      } else if (response.statusCode == 400) {
        toast("Something went wrong");
        return null;
      } else {
        toast("Something went wrong");
        return null;
      }
    } catch (e) {
      toast("Something went wrong");
      log('$e');
return null;
    }
  }
  */
}

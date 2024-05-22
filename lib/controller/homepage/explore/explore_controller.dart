import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/model/books/books.dart';
import 'package:recd/model/category_model.dart';
import 'package:recd/model/podcast/podcast_model.dart';
import 'package:recd/model/trending/movie.dart';
import 'package:recd/model/tv_show/tv_show_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/podcast_repo/podcast_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final net =
      "https://images.squarespace-cdn.com/content/v1/592b020a8419c2e1dd1199dc/1524536685475-NALVUGZ0EJTQ9W29TQ90/ke17ZwdGBToddI8pDm48kOdlMSuc6l3bg4_O3p1DNccUqsxRUqqbr1mOJYKfIPR7LoDQ9mXPOjoJoqy81S2I8N_N4V1vUb5AoIIIbLZhVYxCRW4BPu10St3TBAUQYVKcxzwZuf9fRNKkUMm03yynrdSj3pwwD7zb1cvsHRaCg60C1WB8ANBZkVcGAwv6VHsQ/Infinity-War-Movie-New-Presales-Record.jpg";

  final booknet = "${App.RECd_URL}public/static/images/bookmarkPlaceholder.png";
  TabController controller;

  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0);
  bool isInternet;
  bool isLoading = false;
  String trendingType = "";
  bool isDataLoaded = false;
  bool isTvShowDataLoaded = false;
  bool isPodCastLoaded = false;
  bool isBookLoaded = false;
  bool isCategoryLoading = false;

  TextEditingController searchController = TextEditingController();

  ScrollController podCastSC = ScrollController();
  ScrollController bookSC = ScrollController();

  List<Movie> topRatedMovie = [];
  List<TvShows> topRatedTvShow = [];
  List<PodcastModel> podcastList = [];
  List<BookModel> bookList = [];

  List<Movie> upComingMovie = [];
  List<TvShows> popularTvShow = [];
  List<Movie> popularMovie = [];
  List<CategoryList> movieCategory = [];
  List<CategoryList> tvShowCategory = [];

  bool isbookLoading = true;
  List<BookModel> booksList = [];

  int podCastPageNumber = 1;
  int bookPageNumber = 0;
  bool isPodCastPageLoading = false;

  loadingListener() async {
    podCastSC.addListener(() {
      if (podCastSC.position.pixels == podCastSC.position.maxScrollExtent) {
        setState(() {
          isPodCastPageLoading = true;
        });
        fetchPodcastList().then((v) {
          setState(() => podcastList.addAll(v));
          setState(() {
            isPodCastPageLoading = false;
          });
        });
      }
    });
    // bookSC.addListener(() {
    //   if (bookSC.position.pixels == bookSC.position.maxScrollExtent) {
    // fetchBooks().then((v) {
    //   setState(() {
    //     bookList.addAll(v);
    //     final ids = bookList.map((e) => e.id).toSet();
    //     bookList.retainWhere((x) => ids.remove(x.id));
    //   });
    // });
    // if (booksList.isEmpty) {
    //   fetchBooks().then((value) {
    //     setState(() {
    //       booksList = value;
    //       final ids = booksList.map((e) => e.id).toSet();
    //       booksList.retainWhere((x) => ids.remove(x.id));
    //       isbookLoaded = false;
    //     });
    //   });
    // } else {
    //   setState(() => isbookLoaded = false);
    // }
    //   }
    // });
  }

  tabListner() async {
    controller.addListener(() {
      if (controller.index == 1) {
        // if (popularTvShow.isEmpty || topRatedTvShow.isEmpty) {
        fetchTopRatedTvShow().then((tvShows) {
          fetchPopularTvShow().then((poptvshow) {
            fetchCategory("Tv Show").then((val) {
              setState(() {
                popularTvShow = poptvshow;
                topRatedTvShow = tvShows;
                tvShowCategory = val;
                isTvShowDataLoaded = true;
              });
            });
          });
        });
        // }
      } else if (controller.index == 2) {
        // if (bookList.isEmpty) {
        //   fetchBooks().then((books) {
        //     setState(() {
        //       bookList = books;
        //       final ids = bookList.map((e) => e.id).toSet();
        //       bookList.retainWhere((x) => ids.remove(x.id));
        //       isBookLoaded = true;
        //     });
        //   });
        // }
        setState(() => isbookLoading = true);
        if (booksList.isEmpty) {
          fetchBooks().then((value) {
            setState(() {
              booksList = value;
              final ids = booksList.map((e) => e.id).toSet();
              booksList.retainWhere((x) => ids.remove(x.id));
              isbookLoading = false;
            });
          });
        } else {
          setState(() => isbookLoading = false);
        }
      } else if (controller.index == 3) {
        if (podcastList.isEmpty) {
          fetchPodcastList().then((podcast) {
            setState(() {
              podcastList = podcast;
              isPodCastLoaded = true;
            });
          });
        }
      }
    });
  }

  Future<List<Movie>> fetchTopRatedMovies() async {
    List<Movie> list = [];
    String url =
        "${Global.tmdbApiBaseUrl}/3/movie/top_rated?api_key=${Global.apiKey}&language=en-US";
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      res['results'].forEach((val) {
        Movie movie = Movie(
          movieId: val['id'],
          movieTitle: val['title'],
          movieImage: val['poster_path'],
        );
        setState(() => list.add(movie));
      });
      return list;
    } else if (response.statusCode == 400) {
      return null;
    } else {
      return null;
    }
  }

  Future<List<Movie>> fetchUpComingMovie() async {
    List<Movie> list = [];
    String url =
        "${Global.tmdbApiBaseUrl}/3/movie/upcoming?api_key=${Global.apiKey}&language=en-US";
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);

      res['results'].forEach((val) {
        Movie movie = Movie(
          movieId: val['id'],
          movieTitle: val['title'],
          movieImage: val['poster_path'],
        );
        setState(() => list.add(movie));
      });
      return list;
    } else if (response.statusCode == 400) {
      return null;
    } else {
      return null;
    }
  }

  Future<List<Movie>> fetchTopPopularMovies() async {
    List<Movie> list = [];
    String url =
        "${Global.tmdbApiBaseUrl}/3/movie/popular?api_key=${Global.apiKey}&language=en-US";
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);

      res['results'].forEach((val) {
        Movie movie = Movie(
            movieId: val['id'],
            movieTitle: val['title'],
            movieImage: val['backdrop_path'],
            movieCategory: val['genre_ids']);
        setState(() => list.add(movie));
      });
      return list;
    } else if (response.statusCode == 400) {
      toast("Something went wrong");
      return null;
    } else {
      toast("Something went wrong");
      return null;
    }
  }

  // Future<List<Category>> fetchCategory() async {
  //   try {
  //     List<Category> catList = [];
  //     setState(() => isLoading = true);
  //     String url = Global.tmdbApiBaseUrl +
  //         "/3/genre/movie/list?api_key=${Global.apiKey}&language=en-US";

  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       var res = json.decode(response.body);
  //       setState(() => isLoading = false);
  //       res['genres'].forEach((val) {
  //         Category category = Category(
  //           categoryId: val['id'],
  //           categoryName: val['name'],
  //         );
  //         setState(() => catList.add(category));
  //       });
  //       return catList;
  //     } else if (response.statusCode == 400) {
  //       setState(() => isLoading = false);
  //       toast("Something went wrong");
  //       return null;
  //     } else {
  //       setState(() => isLoading = false);
  //       toast("Something went wrong");
  //       return null;
  //     }
  //   } catch (e) {
  //     setState(() => isLoading = false);
  //     toast("Something went wrong");
  //     return null;
  //   }
  // }

  Future<List<TvShows>> fetchTopRatedTvShow() async {
    List<TvShows> list = [];

    String url =
        "${Global.tmdbApiBaseUrl}/3/tv/airing_today?api_key=${Global.apiKey}&language=en-US&page=1";

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);

      res['results'].forEach((val) {
        TvShows tvShow = TvShows(
          id: val['id'],
          name: val['name'],
          image: val['poster_path'],
        );
        setState(() => list.add(tvShow));
      });
      return list;
    } else if (response.statusCode == 400) {
      toast("Something went wrong");
      return null;
    } else {
      toast("Something went wrong");
      return null;
    }
  }

  Future<List<TvShows>> fetchPopularTvShow() async {
    List<TvShows> list = [];
    String url =
        "${Global.tmdbApiBaseUrl}/3/tv/popular?api_key=${Global.apiKey}&language=en-US";
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);

      res['results'].forEach((val) {
        TvShows tvShow = TvShows(
          id: val['id'],
          name: val['name'],
          image: val['poster_path'],
        );
        setState(() => list.add(tvShow));
      });
      return list;
    } else if (response.statusCode == 400) {
      toast("Something went wrong");
      return null;
    } else {
      toast("Something went wrong");
      return null;
    }
  }

  Future<List<PodcastModel>> fetchPodcastList() async {
    try {
      List<PodcastModel> mList = [];
      print(podCastPageNumber);
      http.Response response =
          await PodcastRepo().fetchBestPodcast(page: podCastPageNumber);
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        print(response.statusCode);
        if (res['has_next']) {
          res['podcasts'].forEach((val) {
            PodcastModel podcast = PodcastModel(
                podCastId: val['id'],
                podCastImage: val['thumbnail'],
                category: val['genre_ids'],
                podCastName: val['title'],
                publisher: val['publisher']);
            setState(() {
              mList.add(podcast);
            });
          });
          setState(() {
            podCastPageNumber++;
          });
        }
        setState(() => isPodCastLoaded = true);

        return mList;
      } else if (response.statusCode == 400) {
        setState(() => isPodCastLoaded = true);
        toast("Something went wrong");
        return null;
      } else {
        setState(() => isPodCastLoaded = true);
        toast("Something went wrong");
        return null;
      }
    } catch (e) {
      setState(() => isPodCastLoaded = true);
      toast("Something went wrong");
      debugPrint('$e');
      return e;
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
  // Future<List<BookModel>> fetchBooks() async {
  //   String url =
  //       "https://www.googleapis.com/books/v1/volumes?q=2020&orderBy=newest&maxResults=40&startIndex=$bookPageNumber";
  //   var response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     List<BookModel> bookList = [];
  //     var res = json.decode(response.body);
  //     res['items'].forEach((val) {
  //       setState(() {
  //         bookList.add(BookModel(
  //             id: val['id'].toString(),
  //             title: val['volumeInfo']['title'].toString(),
  //             image: val['volumeInfo'].containsKey('imageLinks')
  //                 ? val['volumeInfo']['imageLinks']['smallThumbnail'].toString()
  //                 : booknet,
  //             authors: val['volumeInfo'].containsKey('authors')
  //                 ? val['volumeInfo']['authors']
  //                 : ["N/A"],
  //             releaseDate: val['volumeInfo']['publishedDate'].toString()));
  //       });
  //     });
  //     setState(() => bookPageNumber++);
  //     return bookList;
  //   } else if (response.statusCode == 400) {
  //     toast("Something went wrong");
  //     return null;
  //   } else {
  //     toast("Something went wrong");
  //     return null;
  //   }
  // }

  Future<List<CategoryList>> fetchCategory(String type) async {
    try {
      List<CategoryList> catList = [];
      setState(() => isCategoryLoading = true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
      String url =
          App.RECd_URL + "api/v1/category/get-sub-category-by-parent-name";

      final response = await http.post(
        url,
        body: {"category_type": "$type"},
        headers: {"Accept": "application/json", "authorization": "$token"},
      );

      if (response.statusCode == 200) {
        var res = json.decode(response.body);

        res['data'].forEach((val) {
          CategoryList cat = CategoryList(
            id: val['_id'],
            name: val['name'],
            image: val['genre_cover_path'],
            genresId: val['tmdb_genre_id'],
          );
          setState(() => catList.add(cat));
        });

        return catList;
      } else if (response.statusCode == 400) {
        setState(() => isCategoryLoading = false);
        toast("Something went wrong");
        return null;
      } else {
        setState(() => isCategoryLoading = false);
        toast("Something went wrong");
        return null;
      }
    } catch (e) {
      setState(() => isCategoryLoading = false);
      toast("Something went wrong");
      return null;
    }
  }
}

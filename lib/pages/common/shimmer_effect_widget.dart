import 'package:flutter/material.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmer(Size size) {
  return Container(
      child: Shimmer.fromColors(
          child: SingleChildScrollView(
              child: Column(children: [
            hBox(15.0),
            shimmerContainer(size),
            shimmerContainer(size),
            shimmerContainer(size),
            shimmerContainer(size),
            shimmerContainer(size),
            shimmerContainer(size),
            shimmerContainer(size)
          ])),
          baseColor: Colors.grey[400],
          highlightColor: Colors.grey[200]));
}

Shimmer notificationShimmer() => Shimmer.fromColors(
    baseColor: Colors.grey[500],
    highlightColor: Colors.grey[100],
    child: Text(" "));

Shimmer trendingShimmer(Size size) {
  return Shimmer.fromColors(
    child: SingleChildScrollView(
        child: Column(children: [
      hBox(10.0),
      hBox(15.0),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        shimmerTab(size),
        wBox(2.0),
        shimmerTab(size),
        wBox(2.0),
        shimmerTab(size),
        wBox(2.0),
        shimmerTab(size)
      ]),
      hBox(15.0),
      shimmerContainer(size),
      shimmerContainer(size),
      shimmerContainer(size),
      shimmerContainer(size),
      shimmerContainer(size),
      shimmerContainer(size),
      shimmerContainer(size),
      shimmerContainer(size),
      shimmerContainer(size),
      shimmerContainer(size),
      shimmerContainer(size),
      shimmerContainer(size),
      shimmerContainer(size)
    ])),
    baseColor: Colors.grey[400],
    highlightColor: Colors.grey[100],
  );
}

Shimmer recdShimmer() => Shimmer.fromColors(
    highlightColor: Colors.grey[400],
    baseColor: Colors.grey[100],
    child: Container(
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(3)),
        height: 15,
        width: 130,
        child: Text(" ")));
Widget shimmerContainer(Size size) {
  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
      child: Container(
          height: size.height * 0.125,
          width: size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0), color: Colors.grey)));
}

Widget shimmerTab(Size size) {
  return Container(
      height: 20.0,
      width: size.width / 4.5,
      decoration: BoxDecoration(
          color: Colors.grey, borderRadius: BorderRadius.circular(5.0)),
      child: Text(' '));
}

//* User List
Widget userShimmer(BuildContext context) {
  return Expanded(
      child: Shimmer.fromColors(
          child: SingleChildScrollView(
              child: Column(children: [
            userListShimmer(context),
            userListShimmer(context),
            userListShimmer(context),
            userListShimmer(context),
            userListShimmer(context),
            userListShimmer(context)
          ])),
          baseColor: Colors.grey,
          highlightColor: Colors.grey.withOpacity(0.5)));
}

Widget imageShimmer() {
  return Shimmer.fromColors(
      child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7), color: Colors.grey),
          child: Text(" ")),
      baseColor: Colors.grey[400],
      highlightColor: Colors.grey[100]);
}

Widget imageShimmerWithHW({double h, double w, double radius}) {
  return Shimmer.fromColors(
      child: Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius), color: Colors.grey),
          child: Text(" ")),
      baseColor: Colors.grey[400],
      highlightColor: Colors.grey[100]);
}

Widget userListShimmer(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        CircleAvatar(
            radius: 25.0,
            child: Shimmer.fromColors(
                child: Text(" "),
                baseColor: Colors.grey.withOpacity(0.5),
                highlightColor: Colors.grey)),
        Container(
            decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            height: 15.0,
            width: size.width / 1.5,
            child: Shimmer.fromColors(
                child: Text(" "),
                baseColor: Colors.grey.withOpacity(0.5),
                highlightColor: Colors.grey))
      ]));
}

Widget relatedItemShimmer() {
  return Shimmer.fromColors(
      child: Container(
          height: 140.0,
          width: 240.0,
          decoration: BoxDecoration(color: Colors.grey),
          child: Text(" ")),
      baseColor: Colors.grey[200],
      highlightColor: Colors.black26);
}

Widget recdByShimmerEffect(Size size) {
  return Shimmer.fromColors(
    highlightColor: Colors.grey[400],
    baseColor: Colors.grey[200],
    period: Duration(milliseconds: 9),
    child: Container(
        height: 25,
        width: size.width / 2,
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(10)),
        child: Text(" ")),
  );
}

Widget popularMovieShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[100],
    highlightColor: Colors.grey[400],
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
        color: Colors.grey[400],
      ),
    ),
  );
}

Widget mainImageShimmer(Size size) {
  return Shimmer.fromColors(
      highlightColor: Colors.grey[100],
      baseColor: Colors.grey[400],
      child: Container(
          height: size.height / 2,
          width: size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7), color: Colors.grey),
          child: Text(" ")));
}

Widget tvShowTvShowEffect() {
  return Shimmer.fromColors(
      child: Container(
          height: 160.0,
          width: 160.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[400])),
      baseColor: Colors.grey[500],
      highlightColor: Colors.grey[300]);
}

Widget rightRecoEffect() {
  return Shimmer.fromColors(
      child: Container(
          height: 110.0,
          width: 90.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              color: Colors.grey[400])),
      baseColor: Colors.grey[500],
      highlightColor: Colors.grey[300]);
}

Widget leftRecoEffect() {
  return Shimmer.fromColors(
      child: Container(
          height: 110.0,
          width: 90.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  topLeft: Radius.circular(10.0)),
              color: Colors.grey[400])),
      baseColor: Colors.grey[500],
      highlightColor: Colors.grey[300]);
}

Widget contactEffect(Size size) {
  return Shimmer.fromColors(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
          ),
          wBox(5),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cont(18.0, size.width / 1.3 - 60),
              hBox(5.0),
              cont(18.0, size.width / 3),
            ],
          )
        ],
      ),
    ),
    baseColor: Colors.grey[500],
    highlightColor: Colors.grey[300],
  );
}

Widget cont(double h, double w) {
  return Container(
    height: h,
    width: w,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(7),
      color: Colors.grey[100],
    ),
    child: Text(" "),
  );
}

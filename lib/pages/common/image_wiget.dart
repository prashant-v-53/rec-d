import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/pages/common/shimmer_effect_widget.dart';
import 'package:shimmer/shimmer.dart';

class ImageWidget extends StatefulWidget {
  final String imageUrl;
  final double height;
  final double width;
  final int cacheHeight;
  final int cacheWidth;
  ImageWidget({
    Key key,
    @required this.imageUrl,
    this.cacheHeight = 200,
    this.cacheWidth = 200,
    this.height = 200,
    this.width = 200,
  }) : super(key: key);

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // child: Image.network('${widget.img}',
      //     cacheHeight: widget.cacheHeight,
      //     // cacheWidth: widget.cacheWidth,
      //     fit: BoxFit.cover,
      //     errorBuilder: (context, url, error) => Icon(Icons.error),
      //     loadingBuilder: (BuildContext context, Widget child,
      //         ImageChunkEvent loadingProgress) {
      //       if (loadingProgress == null) return child;
      //       return Center(
      //         child: relatedItemShimmer(),
      //         // child: CircularProgressIndicator(
      //         //   value: loadingProgress.expectedTotalBytes != null
      //         //       ? loadingProgress.cumulativeBytesLoaded /
      //         //           loadingProgress.expectedTotalBytes
      //         //       : null,
      //         // ),
      //       );
      //     }),
      child: CachedNetworkImage(
          imageUrl: '${widget.imageUrl}',
          fit: BoxFit.cover,
          memCacheWidth: 170,
          height: widget.height,
          width: widget.width,
          errorWidget: (context, url, error) => errorImage(),
          fadeInDuration: Duration(microseconds: 10),
          fadeInCurve: Curves.easeIn,
          placeholder: (context, url) => popularMovieShimmer()),
    );
  }

  Widget relatedItemShimmer() {
    return Shimmer.fromColors(
        child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(color: Colors.grey),
            child: Text(" ")),
        baseColor: Colors.grey[200],
        highlightColor: Colors.black26);
  }

  static errorImage() => Image.asset(
        ImagePath.RECDLOGO,
        filterQuality: FilterQuality.low,
      );
}

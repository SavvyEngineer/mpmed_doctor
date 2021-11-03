import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mpmed_doctor/documents/provider/documents_provider.dart';
import 'package:photo_view/photo_view.dart';

class image_slider_widget extends StatelessWidget {
  const image_slider_widget(
      {Key? key,
      required this.id,
      required this.mediaData,
      this.changeDirection = Axis.horizontal,
      this.imageScale = BoxFit.fill})
      : super(key: key);

  final int id;
  final List<DocumentMedia> mediaData;
  final Axis changeDirection;
  final BoxFit imageScale;

  @override
  Widget build(BuildContext context) {
    List<String> mediaLink = [];
    mediaData.forEach((element) {
      if (element.doc_id == id) {
        mediaLink.add(element.doc_url);
      }
    });
    return Container(
        margin: EdgeInsets.only(left: 1, right: 10),
        height: 190,
        width: 130,
        child: CarouselSlider.builder(
          itemCount: mediaLink.length,
          options: CarouselOptions(
            height: 170,
            viewportFraction: 0.8,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            onPageChanged: null,
            scrollDirection: changeDirection,
          ),
          itemBuilder:
              (BuildContext context, int itemIndex, int pageViewIndex) =>
                  Container(
            child: Container(
              height: 200,
              width: double.infinity,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: PhotoView(
                    imageProvider: NetworkImage(
                      mediaLink[itemIndex],
                    ),
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 1.8,
                    initialScale: PhotoViewComputedScale.covered,
                    basePosition: Alignment.center,
                  )),
            ),
          ),
        ));
  }
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:mpmed_doctor/documents/provider/documents_provider.dart';
import 'package:mpmed_doctor/documents/screens/document_item_screen.dart';
import 'package:mpmed_doctor/documents/widgets/image_slider_widget.dart';
import 'package:provider/provider.dart';

class DocumenetItem extends StatelessWidget {
  final int id;
  final String reason;
  final String doctor_name;
  final String date;

  DocumenetItem(this.id, this.reason, this.doctor_name, this.date);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final mediaLinksData =
        Provider.of<DocumentsProvider>(context, listen: false)
            .getDocumentsMedia;

    return Container(
      height: 220,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8, left: 10, right: 10),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            DocumentItemScreen.routeName,
            arguments: {'itemId': id},
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              child: GlassContainer(
                isFrostedGlass: true,
        frostedOpacity: 0.05,
        blur: 20,
        elevation: 15,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.60),
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.60),
          ],
          stops: [0.0, 0.45, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25.0),
                height: 130,
                width: mediaQuery.size.width,
                child: Container(
                  margin: EdgeInsets.all(20),
                  alignment: Alignment.centerRight,
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          reason,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,color: Colors.white)
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: 180,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(doctor_name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,color: Colors.white),
                            ),
                          ), Text(date,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400,color: Colors.white),)],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                top: 10,
                left: 10,
                child: image_slider_widget(id: id, mediaData: mediaLinksData))
          ],
        ),
      ),
    );
  }
}

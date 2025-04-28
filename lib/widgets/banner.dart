import 'package:belanjain/components/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_controller.dart' as cs;

class MyBanner extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool autoPlay;
  final bool enableInfiniteScroll;
  final double height;
  final cs.CarouselSliderController buttonCarouselController = cs.CarouselSliderController();

  MyBanner({
    Key? key,
    required this.items,
    this.autoPlay = true,
    this.enableInfiniteScroll = true,
    this.height = 150,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _screen = MediaQuery.of(context).size;

    if (items.isEmpty) {
      return const Center(child: Text("Tidak ada produk tersedia."));
    }

    return SizedBox(
      height: _screen.height * 0.17,
      width: double.infinity,
      child: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: items.length,
            itemBuilder: (context, index, realIndex) {
              final item = items[index];

              print('asdnjsadjasdjnsad ${item['imageUrl']}');
              return Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        item['imageUrl'] ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: _screen.height * 0.06,
                    left: _screen.width * 0.04,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: _screen.width * 0.22,
                          child: Text(
                            item['title'] ?? '',
                            style: const TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(
                          width: _screen.width * 0.5,
                          child: Text(
                            item['subtitle'] ?? '',
                            style: const TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            carouselController: buttonCarouselController,
            options: CarouselOptions(
              autoPlay: autoPlay && items.length > 1,
              enlargeCenterPage: true,
              viewportFraction: 0.95,
              aspectRatio: 2.0,
              initialPage: 0,
              height: height,
              enableInfiniteScroll: enableInfiniteScroll && items.length > 1,
              scrollPhysics: items.length > 1 ? null : const NeverScrollableScrollPhysics(),
            ),
          ),
        ],
      ),
    );
  }
}

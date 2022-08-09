import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadProvider extends ChangeNotifier {
  shimmerForAll() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const BannerPlaceholder(),
              const TitlePlaceholder(width: double.infinity),
              const SizedBox(height: 16.0),
              const ContentPlaceholder(
                lineType: ContentLineType.threeLines,
              ),
              const SizedBox(height: 16.0),
              const TitlePlaceholder(width: 200.0),
              const SizedBox(height: 16.0),
              const ContentPlaceholder(
                lineType: ContentLineType.twoLines,
              ),
              const SizedBox(height: 16.0),
              const TitlePlaceholder(width: 200.0),
              const SizedBox(height: 16.0),
              const ContentPlaceholder(
                lineType: ContentLineType.twoLines,
              ),
            ],
          ),
        ));
  }

  shimmerForMap() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Center(
              child: Container(
                width: double.infinity,
                height: 500,
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.black,
                ),
              ),
            )));
  }

  shimmerForProfile() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 15,
              ),
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    color: Colors.white,
                  ),
                ),
              ),
              // Avatar

              Center(child: const TitlePlaceholder(width: 200)),
              const SizedBox(height: 32.0),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 100.0,
                          height: 90.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 50,
                          height: 12.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    SizedBox(width: 15),
                    Column(
                      children: [
                        Container(
                          width: 100.0,
                          height: 90.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 50,
                          height: 12.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    SizedBox(width: 15),
                    Column(
                      children: [
                        Container(
                          width: 100.0,
                          height: 90.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 50,
                          height: 12.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: 200,
                  height: 12.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              const TitlePlaceholder(width: 200),
            ],
          ),
        ));
  }

  shimmerForSharing() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const BannerPlaceholder(),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    width: 100,
                    height: 12.0,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 35.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5),
                  Container(
                    width: 35.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5),
                  Container(
                    width: 35.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5),
                ],
              ),
              SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                width: 300,
                height: 12.0,
                color: Colors.white,
              ),
            ],
          ),
        ));
  }
}

class BannerPlaceholder extends StatelessWidget {
  const BannerPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 230.0,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
      ),
    );
  }
}

class TitlePlaceholder extends StatelessWidget {
  final double width;

  const TitlePlaceholder({
    Key? key,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: 12.0,
            color: Colors.white,
          ),
          SizedBox(height: 8.0),
          Container(
            width: width,
            height: 12.0,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

enum ContentLineType {
  twoLines,
  threeLines,
}

class ContentPlaceholder extends StatelessWidget {
  final ContentLineType lineType;

  const ContentPlaceholder({
    Key? key,
    required this.lineType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 96.0,
            height: 72.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 10.0,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8.0),
                ),
                if (lineType == ContentLineType.threeLines)
                  Container(
                    width: double.infinity,
                    height: 10.0,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 8.0),
                  ),
                Container(
                  width: 100.0,
                  height: 10.0,
                  color: Colors.white,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:starbucks/ads/ads.dart';
import 'package:starbucks/common/common_widget.dart';
import 'package:starbucks/common/constant/constant.dart';
import '../Controller/favorite_Controller/favorite_Controller.dart';
import '../Controller/home_controller.dart';

class IntroScreen extends StatefulWidget {
  final String image;
  final String name;
  final String instruction;
  final int id;
  final bool isFile;

  IntroScreen({super.key, required this.image, required this.id, required this.name, required this.instruction, this.isFile = false});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final HomeController _homeController = Get.put(HomeController());
  final FavoriteController _favoriteController = Get.put(FavoriteController());
  ScreenshotController screenshotController = ScreenshotController();
  RxBool isShare = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Screenshot(
          controller: screenshotController,
          child: Column(
            children: [
              Container(
                height: 200.h,
                width: MediaQuery.sizeOf(context).width,
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: 40.h, left: 20.w, right: 20.w),
                decoration: BoxDecoration(
                  color: CommonColor.greenColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.r),
                    bottomRight: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10.r),
                        child: Icon(Icons.arrow_back_ios, color: CommonColor.whiteColor, size: 20.h),
                      ),
                    ),
                    if (!widget.isFile)
                      StreamBuilder<List<int>>(
                          stream: _favoriteController.favListId.stream,
                          builder: (context, snapshot) {
                            return GestureDetector(
                                onTap: () async {
                                  if (_favoriteController.favListId.contains(widget.id)) {
                                    _favoriteController.favListId.remove(widget.id);
                                    _homeController.databaseHelper.delete(widget.id);
                                  } else {
                                    await _homeController.addToFavorite(id: widget.id, image: widget.image, name: widget.name, instruction: widget.instruction).then((value) {
                                      _favoriteController.favListId.add(widget.id);
                                    });
                                  }
                                },
                                child: _favoriteController.favListId.contains(widget.id)
                                    ? Icon(Icons.favorite, size: 25.h, color: Colors.red)
                                    : Icon(Icons.favorite_border, size: 25.h, color: CommonColor.whiteColor));
                          }),
                  ],
                ),
              ),
              Baseline(
                baseline: MediaQuery.sizeOf(context).width / 4,
                baselineType: TextBaseline.alphabetic,
                child: !widget.isFile
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15.r),
                        child: Image.asset(
                          Assets.images + widget.image,
                          height: 200.w,
                          width: 200.w,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15.r),
                        child: Image.file(
                          File(widget.image),
                          height: 200.w,
                          width: 200.w,
                          fit: BoxFit.cover,
                        )),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Styles.regular(widget.name, color: CommonColor.greenColor, ff: AppFont.extraB, fontSize: 22.sp, align: TextAlign.center),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.only(left: 15.w, right: 15.w),
                child: Styles.regular(widget.instruction, color: CommonColor.blackColor, ff: AppFont.medium, fontSize: 14.sp),
              ),
              SizedBox(height: 10.h),
              Obx(() {
                if (isShare.value) {
                  return SizedBox.shrink();
                }
                return ApplovinAds.showNativeAds(300);
              }),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () {
                  isShare.value = true;
                  final Size size = MediaQuery.of(context).size;
                  screenshotController.capture(delay: Duration(milliseconds: 0), pixelRatio: 3).then((value) async {
                    if (value != null) {
                      final directory = await getApplicationDocumentsDirectory();
                      final imagePath = await File('${directory.path}/image.png').create();
                      await imagePath.writeAsBytes(value);
                      Share.shareXFiles([XFile(imagePath.path)], text: widget.name, sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2));
                    }
                    isShare.value = false;
                  }).catchError((onError) {
                    print(onError);
                    isShare.value = false;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: CommonColor.greenColor, borderRadius: BorderRadius.circular(15)),
                  height: 56.h,
                  margin: EdgeInsets.all(10.r),
                  width: MediaQuery.sizeOf(context).width,
                  child: Obx(() {
                    if (isShare.value) {
                      return SizedBox(height: 22.w, width: 22.w, child: CircularProgressIndicator(color: CommonColor.whiteColor));
                    }
                    return Styles.regular(
                      'Share',
                      align: TextAlign.center,
                      fontSize: 18.sp,
                      color: CommonColor.whiteColor,
                      ff: AppFont.semiBold,
                    );
                  }),
                ),
              ),
              SizedBox(height: 20.h)
            ],
          ),
        ),
      ),
    );
  }
}

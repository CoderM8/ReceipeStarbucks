import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:starbucks/ads/ads.dart';
import '../Controller/favorite_Controller/favorite_Controller.dart';
import 'IntroPage.dart';
import '../common/common_widget.dart';
import '../common/constant/constant.dart';

List items = List.generate(10, (index) => {'index': index});

class FavoriteListItem extends GetView {
  final FavoriteController _favoriteController = Get.put(FavoriteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Styles.regular(Const.favorite, fontSize: 18.sp, color: CommonColor.whiteColor, ff: AppFont.semiBold),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Icon(Icons.arrow_back_ios, color: CommonColor.whiteColor, size: 20.h),
          ),
        ),
      ),
      body: Obx(() {
        _favoriteController.favData;
        if (_favoriteController.favData.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(right: 10.w, left: 10.w, top: 10.h, bottom: 10.h),
            itemCount: _favoriteController.favData.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  Get.to(() => IntroScreen(
                        id: _favoriteController.favData[index]['id'] ?? 0,
                        image: _favoriteController.favData[index]['image'] ?? '',
                        name: _favoriteController.favData[index]['name'] ?? '',
                        instruction: _favoriteController.favData[index]['instruction'] ?? '',
                      ));
                },
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Row(
                      children: [
                        Container(
                          height: 70.w,
                          width: 70.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              image: DecorationImage(
                                  image: AssetImage(
                                    '${Assets.images}${_favoriteController.favData[index]['image'] ?? ''}',
                                  ),
                                  fit: BoxFit.cover)),
                        ),
                        SizedBox(width: 20.w),
                        Expanded(
                          child: Styles.regular(_favoriteController.favData[index]['name'] ?? '',
                              fontSize: 14.sp, ov: TextOverflow.ellipsis, color: CommonColor.blackColor, ff: AppFont.semiBold, maxLines: 2),
                        ),
                        InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () async {
                            await DatabaseHelper().delete(_favoriteController.favData[index]['id']);
                            _favoriteController.favData.removeAt(index);
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: CommonColor.greenColor.withOpacity(.2)),
                            child: Icon(Icons.favorite, color: Colors.red, size: 25.h),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('${Assets.lottie}no_data_found (1).json', fit: BoxFit.cover, height: 200.w, width: 200.w),
                SizedBox(height: 16.h),
                Styles.regular('No Favorite items found', fontSize: 14.sp, ov: TextOverflow.ellipsis, color: CommonColor.blackColor, ff: AppFont.semiBold, maxLines: 2),
              ],
            ),
          );
        }
      }),
      bottomNavigationBar: ApplovinAds.showBannerAds(),
    );
  }
}

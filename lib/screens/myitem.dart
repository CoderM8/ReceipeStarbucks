import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:starbucks/ads/ads.dart';
import 'package:starbucks/screens/IntroPage.dart';
import '../Controller/favorite_Controller/favorite_Controller.dart';
import '../common/common_widget.dart';
import '../common/constant/constant.dart';

class MyItem extends GetView {
  final RxBool isDelete = false.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Styles.regular("My Items", fontSize: 18.sp, color: CommonColor.whiteColor, ff: AppFont.semiBold),
        centerTitle: true,
        backgroundColor: CommonColor.greenColor,
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
        isDelete.value;
        return FutureBuilder(
            future: DatabaseHelper().getAll(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return SizedBox.shrink();
              }
              if (snapshot.data!.isNotEmpty) {
                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(right: 10.w, left: 10.w, top: 10.h, bottom: 10.h),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data![index];
                    return GestureDetector(
                      onTap: () async {
                        Get.to(() => IntroScreen(id: data['id'] ?? 0, image: data['image'] ?? '', name: data['name'] ?? '', instruction: data['instruction'], isFile: true));
                      },
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Row(
                            children: [
                              Container(
                                height: 70.w,
                                width: 70.w,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), image: DecorationImage(image: FileImage(File(data['image'])), fit: BoxFit.cover)),
                              ),
                              SizedBox(width: 20.w),
                              Expanded(
                                child: Styles.regular(data['name'], fontSize: 14.sp, ov: TextOverflow.ellipsis, color: CommonColor.blackColor, ff: AppFont.semiBold, maxLines: 2),
                              ),
                              InkWell(
                                  onTap: () async {
                                    isDelete.value = !isDelete.value;
                                    await DatabaseHelper().removeItem(data['id']);
                                  },
                                  child: Icon(Icons.delete, color: Colors.red, size: 20.h)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return ConstrainedBox(
                  constraints: BoxConstraints.expand(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('${Assets.lottie}no_data_found (1).json', fit: BoxFit.cover),
                    ],
                  ),
                );
              }
            });
      }),
      bottomNavigationBar: ApplovinAds.showBannerAds(),
    );
  }
}

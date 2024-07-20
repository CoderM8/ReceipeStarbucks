import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:starbucks/Controller/onBording_controller.dart';
import 'package:starbucks/common/common_widget.dart';
import 'package:starbucks/common/constant/constant.dart';
import 'package:starbucks/database/storages.dart';
import 'package:starbucks/screens/homescreen.dart';

class OnBoardingScreen extends StatelessWidget {
  final OnBoardingController _onBoardingController = Get.put(OnBoardingController());

  OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isTab(BuildContext context) {
      return MediaQuery.sizeOf(context).width >= 600 && MediaQuery.sizeOf(context).width < 2048;
    }

    return Scaffold(
      backgroundColor: CommonColor.whiteColor,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              onPageChanged: (value) {
                _onBoardingController.currentPage.value = value;
              },
              controller: _onBoardingController.controller,
              scrollDirection: Axis.horizontal,
              itemCount: _onBoardingController.onboardingImageList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Image.asset(
                      '${Assets.useAppImages}${_onBoardingController.onboardingImageList[index]}',
                      width: MediaQuery.sizeOf(context).width,
                      height: isTab(context) ? 455.h : 475.h,
                      fit: isTab(context) ? BoxFit.fill : BoxFit.cover,
                    ),
                    SizedBox(height: 40.h),
                    Styles.regular(_onBoardingController.onboardingContentList[index], color: CommonColor.greenColor, ff: AppFont.semiBold, fontSize: 16.sp, align: TextAlign.center)
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 10.h),
          SmoothPageIndicator(
            axisDirection: Axis.horizontal,
            controller: _onBoardingController.controller,
            count: _onBoardingController.onboardingImageList.length,
            textDirection: TextDirection.ltr,
            effect: SlideEffect(
                type: SlideType.normal,
                spacing: 8.0,
                radius: 10.w,
                dotWidth: 10.w,
                dotHeight: 10.w,
                paintStyle: PaintingStyle.fill,
                strokeWidth: 2.5,
                dotColor: Colors.grey,
                activeDotColor: CommonColor.greenColor),
          ),
          Obx(() {
            _onBoardingController.currentPage.value;
            return GestureDetector(
              onTap: () async {
                if (_onBoardingController.currentPage == _onBoardingController.onboardingContentList.length - 1) {
                  await Storages.write('new', true);
                  Get.offAll(() => HomeScreen());
                } else {
                  _onBoardingController.controller.nextPage(curve: Curves.linearToEaseOut, duration: Duration(milliseconds: 400));
                }
              },
              child: Container(
                alignment: Alignment.center,
                height: 55.h,
                width: MediaQuery.sizeOf(context).width,
                margin: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: CommonColor.greenColor,
                ),
                child: Styles.regular(_onBoardingController.getButtonText(_onBoardingController.currentPage.value),
                    color: CommonColor.whiteColor, ls: 0.8, fontWeight: FontWeight.w700, fontSize: 16.sp, ff: AppFont.regular),
              ),
            );
          }),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

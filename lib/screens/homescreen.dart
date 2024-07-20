import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:starbucks/Controller/home_controller.dart';
import 'package:starbucks/ads/ads.dart';
import 'package:starbucks/common/common_widget.dart';
import 'package:starbucks/screens/IntroPage.dart';
import 'package:starbucks/screens/Privacy_PolicyScreen.dart';
import 'package:starbucks/screens/additems.dart';
import 'package:starbucks/screens/myitem.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/constant/constant.dart';
import 'favoriteItemList.dart';
import 'menulist_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final HomeController _homeController = Get.put(HomeController());
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  @override
  void initState() {
    _homeController.categoryController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      menuBackgroundColor: CommonColor.greenColor,
      style: DrawerStyle.defaultStyle,
      borderRadius: 24.0,
      showShadow: true,
      slideWidth: isTab(context) ? MediaQuery.sizeOf(context).width / 1.8 : MediaQuery.sizeOf(context).width / 1.3,
      mainScreenTapClose: true,
      angle: -8,
      openCurve: Curves.linearToEaseOut,
      duration: Duration(milliseconds: 400),
      controller: _drawerController,
      mainScreen: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () async {
                await ApplovinAds.showInterAds();
                Get.to(() => FavoriteListItem());
              },
              icon: Icon(Icons.favorite, color: CommonColor.whiteColor, size: 22.h),
            ),
            SizedBox(width: 10.h)
          ],
          title: Styles.regular(Const.menu, fontSize: 18.sp, color: CommonColor.whiteColor, ff: AppFont.semiBold),
          centerTitle: true,
          backgroundColor: CommonColor.greenColor,
          leading: IconButton(
              onPressed: () {
                _drawerController.open!();
                _drawerController.toggle!();
              },
              icon: Icon(Icons.menu, color: CommonColor.whiteColor)),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              welcomeText(),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _homeController.catList.length,
                itemBuilder: (BuildContext context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Styles.regular(
                              _homeController.catList[index],
                              fontSize: 18.sp,
                              ff: AppFont.extraB,
                              color: CommonColor.greenColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(() => MenuListScreen(index: index, title: _homeController.catList[index]));
                            },
                            child: Styles.regular(
                              'See All',
                              fontSize: 14.sp,
                              ff: AppFont.medium,
                              color: CommonColor.blackColor,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 130.w,
                        child: FutureBuilder(
                            future: rootBundle.loadString('assets/database/${getDataBasePath(index: index)}.json'),
                            builder: (context, snapshot) {
                              if (snapshot.data == null) {
                                return SizedBox.shrink();
                              }
                              final data = jsonDecode(snapshot.data!);
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                primary: false,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                itemBuilder: (context, i) {
                                  return InkWell(
                                    onTap: () async {
                                      final int r = Random().nextInt(5);
                                      if (r == index) {
                                        await ApplovinAds.showInterAds();
                                      }
                                      Get.to(() => IntroScreen(id: data[i]['id'], image: data[i]['image'], name: data[i]['name'], instruction: data[i]['instruction']));
                                    },
                                    child: Container(
                                      height: MediaQuery.sizeOf(context).height,
                                      width: 140.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.r),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(Assets.images + data[i]['image']),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                                itemCount: data.take(6).length,
                              );
                            }),
                      )
                    ],
                  );
                },
              ),
              SizedBox(height: 20.h)
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: 15.h),
          child: ApplovinAds.showBannerAds(),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: '2',
          onPressed: () {
            Get.to(() => AddItems());
          },
          backgroundColor: CommonColor.greenColor,
          child: Icon(Icons.add),
        ),
      ),
      menuScreen: MenuScreen(controller: _drawerController),
    );
  }

  /// Welcome text
  Widget welcomeText() {
    return Padding(
      padding: EdgeInsets.only(left: 10.w, bottom: 10.h, top: 10.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Styles.regular(
            align: TextAlign.start,
            "${getTimeOfDay} 👋",
            fontSize: 20.sp,
            ff: AppFont.semiBold,
            color: CommonColor.blackColor,
          ),
          Styles.regular(
            align: TextAlign.start,
            "The Ultimate Secret Menu for Starbucks!",
            fontSize: 14.sp,
            ff: AppFont.regular,
            fontWeight: FontWeight.w500,
            color: CommonColor.blackColor,
          )
        ],
      ),
    );
  }
}

class MenuScreen extends StatefulWidget {
  final ZoomDrawerController controller;

  MenuScreen({super.key, required this.controller});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColor.greenColor,
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Column(
          children: [
            SizedBox(height: 100.h),
            IconButton(
                onPressed: () {
                  widget.controller.close!();
                },
                icon: Icon(Icons.close, color: CommonColor.whiteColor, size: 30)),
            SizedBox(height: isTab(context) ? 250.h : 300),
            ListTile(
              onTap: () {
                Get.to(() => MyItem());
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              tileColor: CommonColor.blackColor.withOpacity(0.2),
              leading: Container(
                height: 40.w,
                width: 40.w,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: const Color(0xffFFB43F), borderRadius: BorderRadius.circular(8.r)),
                child: Icon(Icons.my_library_books_rounded, color: CommonColor.whiteColor),
              ),
              title: Styles.regular(
                align: TextAlign.start,
                "My Items",
                fontSize: 15.sp,
                ff: AppFont.medium,
                color: CommonColor.whiteColor,
              ),
            ),
            SizedBox(height: 5.h),
            ListTile(
              onTap: () {
                Get.to(() => PrivacyPolicyScreen());
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              tileColor: CommonColor.blackColor.withOpacity(0.2),
              leading: Container(
                height: 40.w,
                width: 40.w,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: const Color(0xff43DB6D), borderRadius: BorderRadius.circular(8.r)),
                child: Icon(Icons.privacy_tip_outlined, color: CommonColor.whiteColor),
              ),
              title: Styles.regular(
                align: TextAlign.start,
                "Privacy Policy",
                fontSize: 15.sp,
                ff: AppFont.medium,
                color: CommonColor.whiteColor,
              ),
            ),
            SizedBox(height: 5.h),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              onTap: () async {
                if (isTab(context)) {
                  await Share.share('Secret Menu for Starbucks! \n$shareApp', sharePositionOrigin: Rect.fromLTWH(0, 0, MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height / 2));
                } else {
                  await Share.share('Secret Menu for Starbucks! \n$shareApp');
                }
              },
              tileColor: CommonColor.blackColor.withOpacity(0.2),
              leading: Container(
                height: 40.w,
                width: 40.w,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: const Color(0xff19DFC4), borderRadius: BorderRadius.circular(8.r)),
                child: Icon(Icons.share, color: CommonColor.whiteColor),
              ),
              title: Styles.regular(
                align: TextAlign.start,
                "Share App",
                fontSize: 15.sp,
                ff: AppFont.medium,
                color: CommonColor.whiteColor,
              ),
            ),
            SizedBox(height: 5.h),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              onTap: _requestReview,
              tileColor: CommonColor.blackColor.withOpacity(0.2),
              leading: Container(
                height: 40.w,
                width: 40.w,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: const Color(0xffFC6A51), borderRadius: BorderRadius.circular(8.r)),
                child: Icon(Icons.star, color: CommonColor.whiteColor),
              ),
              title: Styles.regular(
                align: TextAlign.start,
                "Rate Us",
                fontSize: 15.sp,
                ff: AppFont.medium,
                color: CommonColor.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestReview() async {
    if (await canLaunchUrl(Uri.parse(rateApp))) {
      await launchUrl(Uri.parse(rateApp));
    }
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:starbucks/ads/ads.dart';
import 'package:starbucks/common/common_widget.dart';
import 'package:starbucks/common/constant/constant.dart';
import 'package:starbucks/models/CategoryMenuListItemsModel.dart';
import '../Controller/home_controller.dart';
import 'IntroPage.dart';

class MenuListScreen extends StatefulWidget {
  final int index;
  final String title;

  const MenuListScreen({Key? key, required this.index, required this.title});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> with TickerProviderStateMixin {
  final HomeController _homeController = Get.put(HomeController());
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    _homeController.categoryMenuList(widget.index);
    _controller = AnimationController(duration: const Duration(milliseconds: 400), vsync: this)..forward();

    // slide animation
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // horizontal
      // begin: const Offset(0.0, 1.0), // vertical
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // slow animation item come
    _fadeAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    super.initState();
  }

  void searchBook(String query) {
    final suggestions = _homeController.categoryMenuListItemsModel.where((book) {
      final bookTitle = book.name.toLowerCase();
      final input = query.toLowerCase();

      return bookTitle.contains(input);
    }).toList();

    setState(() => _homeController.filteredItems.value = suggestions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: AnimatedSearchBar(
              width: 300.w,
              searchBarOpen: (int) {},
              onChange: (p0) {
                searchBook(p0);
              },
              textController: _homeController.searchController,
              onSuffixTap: SizedBox(),
              closeSearchOnSuffixTap: true,
              onSubmitted: (value) {},
            ),
          )
        ],
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Icon(Icons.arrow_back_ios, color: CommonColor.whiteColor, size: 20.h),
          ),
        ),
        title: Styles.regular(widget.title, fontSize: 18.sp, color: CommonColor.whiteColor, ff: AppFont.semiBold),
      ),
      body: StreamBuilder<List<CategoryMenuListItemsModel>>(
          stream: _homeController.filteredItems.stream,
          builder: (context, snapshot) {
            return GridView.builder(
              itemCount: _homeController.filteredItems.length,
              padding: EdgeInsets.all(15.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 150.w / 200.w,
              ),
              itemBuilder: (context, index) {
                final data = _homeController.filteredItems[index];
                return SlideTransition(
                  position: _offsetAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final int r = Random().nextInt(5);
                              if (r == index) {
                                await ApplovinAds.showRewardAds();
                              }
                              Get.to(() => IntroScreen(id: data.id, image: data.image, name: data.name, instruction: data.instruction));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.r),
                              child: Image.asset(
                                Assets.images + data.image,
                                fit: BoxFit.cover,
                                width: MediaQuery.sizeOf(context).width,
                                height: MediaQuery.sizeOf(context).height,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Styles.regular(
                          data.name,
                          fontSize: 14.sp,
                          ff: AppFont.semiBold,
                          maxLines: 1,
                          align: TextAlign.center,
                          color: CommonColor.blackColor,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}

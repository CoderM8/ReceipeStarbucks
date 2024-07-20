import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:starbucks/Controller/favorite_Controller/favorite_Controller.dart';
import 'package:starbucks/ads/ads.dart';
import 'package:starbucks/common/common_widget.dart';
import 'package:starbucks/common/constant/constant.dart';

class AddItems extends StatefulWidget {
  const AddItems({super.key});

  @override
  State<AddItems> createState() => _AddItemsState();
}

class _AddItemsState extends State<AddItems> {
  final globalKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController desController = TextEditingController();
  String? selected;
  final List<String> catList = [
    "Frappuccinos",
    "Lattes",
    "Macchiatos",
    "Refreshers",
    "Hot Chocolate",
    "Smoothies",
    "Teas",
  ];
  File? file;
  RxBool isUpload = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Styles.regular("Add Items", fontSize: 18.sp, color: CommonColor.whiteColor, ff: AppFont.semiBold),
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Form(
            key: globalKey,
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        file = await Const.pickImage();
                        isUpload.value = !isUpload.value;
                      },
                      child: Container(
                        height: 150.w,
                        width: 150.w,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 50.h, color: CommonColor.whiteColor),
                            SizedBox(height: 10.h),
                            Styles.regular("Select image", fontSize: 14.sp, color: CommonColor.whiteColor, ff: AppFont.medium),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Obx(() {
                      isUpload.value;
                      if (file != null) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(15.r),
                          child: Image.file(file!, height: 150.w, width: 150.w, fit: BoxFit.cover),
                        );
                      }
                      return SizedBox.shrink();
                    }),
                  ],
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: nameController,
                  style: TextStyle(fontFamily: AppFont.semiBold, fontSize: 16.sp),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: "Title",
                    hintStyle: TextStyle(fontFamily: AppFont.semiBold, fontSize: 16.sp),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  maxLines: 3,
                  controller: desController,
                  style: TextStyle(fontFamily: AppFont.semiBold, fontSize: 16.sp),
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "Instruction",
                    hintStyle: TextStyle(fontFamily: AppFont.semiBold, fontSize: 16.sp),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 20.h),
                DropdownButtonFormField(
                  style: TextStyle(fontFamily: AppFont.semiBold, fontSize: 16.sp),
                  decoration: InputDecoration(
                    hintText: "Category",
                    hintStyle: TextStyle(fontFamily: AppFont.semiBold, fontSize: 16.sp),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                  ),
                  items: catList
                      .map(
                        (e) => DropdownMenuItem(
                          child: Styles.regular(e, fontSize: 16.sp, color: CommonColor.blackColor, ff: AppFont.medium),
                          value: e,
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    selected = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 30.h),
                InkWell(
                  onTap: () async {
                    if (globalKey.currentState!.validate()) {
                      await ApplovinAds.showRewardAds();
                      await DatabaseHelper().addItem({
                        "image": file!.path,
                        "name": nameController.text,
                        "instruction": desController.text,
                        "category": selected,
                      });
                      Get.back();
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: CommonColor.greenColor, borderRadius: BorderRadius.circular(15.r)),
                    height: 56.h,
                    margin: EdgeInsets.all(10.r),
                    width: MediaQuery.sizeOf(context).width,
                    child: Styles.regular('Save', align: TextAlign.center, fontSize: 18.sp, color: CommonColor.whiteColor, ff: AppFont.semiBold),
                  ),
                ),
                SizedBox(height: 10.h),
                ApplovinAds.showBannerAds(),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

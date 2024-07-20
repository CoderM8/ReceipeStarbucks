import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

String get shareApp {
  if (Platform.isAndroid) {
    return "https://play.google.com/store/apps/details?id=com.vocsy.starbuck";
  } else if (Platform.isIOS) {
    return "https://apps.apple.com/in/app/secret-menu-for-starbucks/id6471466957";
  } else {
    return "Unsupported Platform ${Platform.operatingSystem}";
  }
}

String get rateApp {
  if (Platform.isAndroid) {
    return "https://play.google.com/store/apps/details?id=com.vocsy.starbuck";
  } else if (Platform.isIOS) {
    return "https://itunes.apple.com/app/id6471466957?action=write-review";
  } else {
    return "Unsupported Platform ${Platform.operatingSystem}";
  }
}

class CommonColor {
  static Color greenColor = const Color(0xFF00623B);
  static Color blackColor = const Color(0xFF000000);
  static Color whiteColor = const Color(0xFFFFFFFF);
}

class Assets {
  static String images = 'assets/images/';
  static String useAppImages = 'assets/images/useAppImages/';
  static String lottie = 'assets/lottie/';
  static String database = 'assets/database/';
}

class AppFont {
  static String bold = 'B';
  static String regular = 'R';
  static String extraB = 'EB';
  static String medium = 'M';
  static String semiBold = 'SB';
}

Future<void> appTracking() async {
  final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  } else if (status == TrackingStatus.denied) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
  if (status == TrackingStatus.authorized) {
    await AppTrackingTransparency.getAdvertisingIdentifier();
  }
}

bool isTab(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= 600 && MediaQuery.sizeOf(context).width < 2048;
}

class Const {
  static String menu = 'Menu';
  static String favorite = 'Favorite';
  static String privacyPolicy = 'Privacy Policy';
  static String areYouSure = 'Are you sure?';
  static String doYouWantToExitAnApp = 'Do you want to exit an App';
  static String yes = 'Yes';
  static String no = 'No';
  static String shareApp = 'Share App';
  static String oneCupCoffeeMakeYourDayProductive = 'One Cup Coffee Make\n  Your Day Productive';
  static String allYouNeedToFeelBatterIsCoffee = 'All You Need To Feel\n Batter Is Coffee';
  static String enjoyHundredsOfRecipes = 'Enjoy hundreds Of\n Recipes';
  static String next = 'Next';
  static String done = 'Done';

  static Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }
}

String get getTimeOfDay {
  final DateTime now = DateTime.now();

  if (now.hour < 12) {
    return 'Good morning!';
  } else if (now.hour < 18) {
    return 'Good afternoon!';
  } else {
    return 'Good evening!';
  }
}

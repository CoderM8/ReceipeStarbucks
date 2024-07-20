import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:starbucks/Notification/local_notification_services.dart';
import 'package:starbucks/Splash_screen.dart';
import 'package:starbucks/database/storages.dart';

import 'common/constant/constant.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Storages.init();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarBrightness: Brightness.light, statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));

  /// automatically get breadcrumb logs to understand user actions leading up to a crash, non-fatal, or ANR event
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  /// INITIALIZE LOCAL NOTIFICATION FOR [IOS]
  await NotificationService.init();
  await NotificationService.cancelAllNotifications();

  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      designSize: isTab(context) ? const Size(585, 812) : const Size(375, 812),
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Recipe for Starbucks',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: CommonColor.greenColor),
            useMaterial3: false,
            appBarTheme: AppBarTheme(backgroundColor: CommonColor.greenColor, elevation: 0, centerTitle: true),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

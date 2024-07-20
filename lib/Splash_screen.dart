import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:starbucks/ads/ads.dart';
import 'package:starbucks/database/storages.dart';
import 'package:starbucks/screens/homescreen.dart';
import 'package:starbucks/screens/onBoarding_screen.dart';
import 'common/constant/constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _initAds();
    Future.delayed(const Duration(seconds: 3), () async {
      await appTracking();

      /// CHECK USER IS NEW OR OLD IN APP
      Get.off(() => Storages.read('new') == true ? HomeScreen() : OnBoardingScreen());
    });
    super.initState();
  }

  /// MOBILE ADS SDK INITIALIZE
  Future<void> _initAds() async {
    // TODO : APPLOVIN ADS STEP 4
    await ApplovinAds.initAds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        alignment: Alignment.center,
        child: Lottie.asset('${Assets.lottie}coffee.json'),
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('${Assets.useAppImages}sds.jpg'), fit: BoxFit.cover),
        ),
      ),
    );
  }
}

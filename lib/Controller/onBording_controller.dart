import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../common/constant/constant.dart';

class OnBoardingController extends GetxController{
  RxInt currentPage = 0.obs;
  final List<String> onboardingImageList = [
    'board1.png',
    'board2.png',
    'board3.png',
  ];
  final List<String> onboardingContentList = [
    Const.oneCupCoffeeMakeYourDayProductive,
    Const.allYouNeedToFeelBatterIsCoffee,
    Const.enjoyHundredsOfRecipes,
  ];
  final PageController controller = PageController();

  String getButtonText(int page) {
    switch (page) {
      case 0:
        return Const.next;
      case 1:
        return Const.next;
    }
    return Const.done;
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:starbucks/models/Category_model.dart';
import '../models/CategoryMenuListItemsModel.dart';
import 'favorite_Controller/favorite_Controller.dart';

class HomeController extends GetxController {
  RxInt catIndex = 0.obs;
  TextEditingController searchController = TextEditingController();
  RxList<CategoryMenuListItemsModel> filteredItems = <CategoryMenuListItemsModel>[].obs;
  RxList<CategoryModel> filteredCatItems = <CategoryModel>[].obs;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<String> catList = [
    "Frappuccinos",
    "Lattes",
    "Macchiatos",
    "Refreshers",
    "Hot Chocolate",
    "Smoothies",
    "Teas",
  ];

  /// Category Controller
  RxList<CategoryModel> categoryModelList = <CategoryModel>[].obs;

  Future? categoryController() async {
    categoryModelList.clear();
    final jsonString = await rootBundle.loadString('assets/database/json_categories.json');
    categoryModelList.value = categoryModelFromJson(jsonString);
    filteredCatItems.addAll(categoryModelList);
    return null;
  }

  /// category menu List
  RxList<CategoryMenuListItemsModel> categoryMenuListItemsModel = <CategoryMenuListItemsModel>[].obs;

  categoryMenuList(int index) async {
    filteredItems.clear();
    categoryMenuListItemsModel.clear();
    final jsonString = await rootBundle.loadString('assets/database/${getDataBasePath(index: index)}.json');
    categoryMenuListItemsModel.value = categoryMenuListItemsModelFromJson(jsonString);
    filteredItems.addAll(categoryMenuListItemsModel);
  }

  Future<void> addToFavorite({required String image, required String name, required String instruction, required int id}) async {
    databaseHelper.insert({"id": id, "name": name, "image": image, "instruction": instruction});
  }
}

String getDataBasePath({required int index}) {
  if (index == 0) {
    return 'json_category_frappuccinos';
  } else if (index == 1) {
    return 'json_category_lattes';
  } else if (index == 2) {
    return 'json_category_macchiatos';
  } else if (index == 3) {
    return 'json_category_refreshers';
  } else if (index == 4) {
    return 'json_category_hot_chocolate';
  } else if (index == 5) {
    return 'json_category_smoothies';
  } else {
    return 'json_category_teas';
  }
}

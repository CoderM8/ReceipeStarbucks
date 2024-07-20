import 'dart:convert';

List<CategoryMenuListItemsModel> categoryMenuListItemsModelFromJson(String str) => List<CategoryMenuListItemsModel>.from(json.decode(str).map((x) => CategoryMenuListItemsModel.fromJson(x)));

String categoryMenuListItemsModelToJson(List<CategoryMenuListItemsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoryMenuListItemsModel {
  final int id;
  final String name;
  final String image;
  final String instruction;

  factory CategoryMenuListItemsModel.fromJson(Map<String, dynamic> json) => CategoryMenuListItemsModel(id: json["id"], name: json["name"], image: json["image"], instruction: json["instruction"]);

  CategoryMenuListItemsModel({required this.id, required this.name, required this.image, required this.instruction});

  Map<String, dynamic> toJson() => {"id": id, "name": name, "image": image, "instruction": instruction};
}

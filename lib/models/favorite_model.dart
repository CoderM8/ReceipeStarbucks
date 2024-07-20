import 'dart:convert';

List<FavoriteItemModel> favoriteItemModelFromJson(String str) => List<FavoriteItemModel>.from(json.decode(str).map((x) => FavoriteItemModel.fromJson(x)));

String favoriteItemModelToJson(List<FavoriteItemModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FavoriteItemModel {
  String? name;
  String? image;
  String? instruction;

  FavoriteItemModel({
    this.name,
    this.image,
    this.instruction,
  });

  factory FavoriteItemModel.fromJson(Map<String, dynamic> json) => FavoriteItemModel(
    name: json["name"],
    image: json["image"],
    instruction: json["instruction"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "image": image,
    "instruction": instruction,
  };
}

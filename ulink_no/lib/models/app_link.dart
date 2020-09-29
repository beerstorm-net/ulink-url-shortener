import 'package:cloud_firestore/cloud_firestore.dart';

class AppLink {
  String id;
  String createdAt;
  String long_link;
  String short_link;
  List<String> simple_links;

  AppLink(
      {this.id,
      this.createdAt,
      this.long_link,
      this.short_link,
      this.simple_links});

  factory AppLink.fromJson(Map<String, dynamic> json) {
    return AppLink(
      id: json['_id'],
      createdAt: json['createdAt'],
      long_link: json['long_link'],
      short_link: json['short_link'],
      simple_links: json['simple_links'] != null
          ? new List<String>.from(json['simple_links'])
          : List(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['createdAt'] = this.createdAt;
    data['long_link'] = this.long_link;
    data['short_link'] = this.short_link;
    if (this.simple_links != null) {
      data['simple_links'] = this.simple_links;
    }
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  Map<String, dynamic> toRequestJson() {
    Map<String, dynamic> data = Map();
    data['long_link'] = this.long_link;
    data['simple_links'] = this.simple_links;
    return data;
  }

  static AppLink fromFormInput(Map<String, dynamic> formInput) {
    AppLink appLink = AppLink();

    appLink.long_link = formInput['long_link'] as String;
    if (formInput.containsKey('simple_links')) {
      appLink.simple_links = formInput['simple_links'] as List;
    }

    return appLink;
  }

  static AppLink fromSnapshot(DocumentSnapshot snap) {
    AppLink appLink = AppLink();

    // TODO: map from firestore data!!!

    return appLink;
  }
}

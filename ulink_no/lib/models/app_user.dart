import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  AppUser(
      {this.uid,
      this.createdAt,
      this.updatedAt,
      this.email,
      this.photoUrl,
      this.displayName,
      this.extData,
      this.token,
      this.token_created_at});

  String uid;
  String email;
  String photoUrl;
  String displayName;
  String createdAt;
  String updatedAt;
  String token;
  String token_created_at;
  // extra data, e.g. device/loc related details
  Map<String, dynamic> extData = Map();

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'email': email,
        'photoUrl': photoUrl,
        'displayName': displayName,
        'extData': extData ?? Map(),
        'token': token,
        'token_created_at': token_created_at
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      extData: json['extData'] ?? Map(),
      token: json['token'],
      token_created_at: json['token_created_at'],
    );
  }

  static AppUser fromSnapshot(DocumentSnapshot snap) {
    AppUser appUser = new AppUser();

    appUser.uid = snap.id; //.documentID;
    appUser.createdAt = snap.data().containsKey('createdAt')
        ? snap.data()['createdAt'] as String
        : '';
    appUser.updatedAt = snap.data().containsKey('updatedAt')
        ? snap.data()['updatedAt'] as String
        : '';
    appUser.email =
        snap.data().containsKey('email') ? snap.data()['email'] as String : '';
    appUser.displayName = snap.data().containsKey('displayName')
        ? snap.data()['displayName'] as String
        : '';
    appUser.photoUrl = snap.data().containsKey('photoUrl')
        ? snap.data()['photoUrl'] as String
        : '';

    // NB! not used by the client
    //appUser.extData = snap.data.containsKey('extData') ? snap.data['extData'] as Map : Map();

    return appUser;
  }
}

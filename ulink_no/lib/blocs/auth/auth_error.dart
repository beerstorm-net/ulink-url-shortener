class LoginError {
  String code;
  String message;

  LoginError({this.code, this.message});

  factory LoginError.fromJson(Map<String, dynamic> json) {
    return LoginError(
        code: json['code'] as String, message: json['message'] as String);
  }

  Map<String, String> toJson() => {'code': code, 'message': message};
}

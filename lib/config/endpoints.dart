import 'package:flutter_dotenv/flutter_dotenv.dart';

class EndPoints {
  static final baseUrl = dotenv.env['BASE_URL'];
  static final signupUrl = dotenv.env['SIGNUP_URL'];
  static final loginUrl = dotenv.env['LOGIN_URL'];
}

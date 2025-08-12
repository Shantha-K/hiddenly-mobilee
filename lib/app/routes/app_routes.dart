// ignore_for_file: constant_identifier_names

import 'package:inochat/app/bindings/home_binding.dart';
import 'package:inochat/app/screens/contacts/chat_detail_screen.dart';
import 'package:inochat/app/screens/home_screen.dart';

import '../screens/status/status_screen.dart';
import '../bindings/status_binding.dart';
import 'package:get/get.dart';
import 'package:inochat/app/screens/splash_screen.dart';
import '../bindings/splash_binding.dart';
import '../bindings/signup_binding.dart';
import '../bindings/verify_binding.dart';
import '../bindings/fingerprint_binding.dart';
import '../bindings/qrcode_binding.dart';
import '../bindings/account_created_binding.dart';
import '../bindings/chat_binding.dart';
import '../screens/signup_screen.dart';
import '../screens/verify_screen.dart';
import '../screens/fingerprint_screen.dart';
import '../screens/qrcode_screen.dart';
import '../screens/account_created_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/signin_screen.dart';
import '../screens/contacts/contacts_screen.dart';
import '../bindings/contacts_binding.dart';

class AppRoutes {
  static const STATUS = '/status';
  static const SPLASH = '/splash';
  static const CONTACTS = '/contacts';
  static const SIGNIN = '/signin';
  static const SIGNUP = '/signup';
  static const VERIFY = '/verify';
  static const FINGERPRINT = '/fingerprint';
  static const QRCODE = '/qrcode';
  static const ACCOUNT_CREATED = '/account_created';
  static const CHAT = '/chat';
  static const HOME = '/home';
  static const CHATDETAIL = '/chat_detail';

  static final routes = [
    GetPage(name: STATUS, page: () => StatusScreen(), binding: StatusBinding()),
    GetPage(name: SPLASH, page: () => SplashScreen(), binding: SplashBinding()),
    GetPage(name: SIGNIN, page: () => SignInScreen()),
    GetPage(name: HOME, page: () => HomeScreen(), binding: HomeBinding()),
    GetPage(
      name: CHATDETAIL,
      page: () => ChatDetailScreen(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: CONTACTS,
      page: () => ContactsScreen(),
      binding: ContactsBinding(),
    ),
    GetPage(name: SIGNUP, page: () => SignupScreen(), binding: SignupBinding()),
    GetPage(name: VERIFY, page: () =>VerifyScreen(), binding: VerifyBinding()),
    GetPage(
      name: FINGERPRINT,
      page: () => FingerprintScreen(),
      binding: FingerprintBinding(),
    ),
    GetPage(name: QRCODE, page: () => QRCodeScreen(), binding: QRCodeBinding()),
    GetPage(
      name: ACCOUNT_CREATED,
      page: () => AccountCreatedScreen(),
      binding: AccountCreatedBinding(),
    ),
    GetPage(name: CHAT, page: () => ChatScreen(), binding: ChatBinding()),
  ];
}

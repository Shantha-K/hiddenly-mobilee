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
import '../screens/chat_screen.dart';

class AppRoutes {
  static const SPLASH = '/splash';
  static const SIGNUP = '/signup';
  static const VERIFY = '/verify';
  static const FINGERPRINT = '/fingerprint';
  static const QRCODE = '/qrcode';
  static const ACCOUNT_CREATED = '/account_created';
  static const CHAT = '/chat';

  static final routes = [
    GetPage(name: SPLASH, page: () => SplashScreen(), binding: SplashBinding()),
    GetPage(name: SIGNUP, page: () => SignupScreen(), binding: SignupBinding()),
    GetPage(name: VERIFY, page: () => VerifyScreen(), binding: VerifyBinding()),
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

import 'package:get/get.dart';
import '../controllers/qrcode_controller.dart';

class QRCodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QRCodeController>(() => QRCodeController());
  }
}

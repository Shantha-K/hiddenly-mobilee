import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  var chats = [].obs;
  var isLoading = false.obs;

  final String apiUrl = 'http://35.154.10.237:5000/api/chats';
  final String token = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2ODk1OTg0NTQ5Y2VlNGE4ZTIwMzBmOGQiLCJtb2JpbGUiOiI3ODc2NTU2Nzg5IiwiaWF0IjoxNzU0NjM0MzMyLCJleHAiOjE3NTUyMzkxMzJ9.FQcacRUYFQbFDBuXPSEs9m-lFx74MIjKPrkvBkJ6LRk';

  Future<void> fetchChats() async {
    try {
      isLoading(true);

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };

      var request = http.Request('GET', Uri.parse(apiUrl));
      request.body = json.encode({
        "email": "vana@gmail.com",
        "qrText": "this is my qr"
      });
      request.headers.addAll(headers);

      var response = await request.send();

      if (response.statusCode == 200) {
        var data = jsonDecode(await response.stream.bytesToString());
        chats.assignAll(data['chats']);
      } else {
        Get.snackbar("Error", response.reasonPhrase ?? "Unknown error");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  @override
  void onInit() {
    fetchChats();
    super.onInit();
  }
}

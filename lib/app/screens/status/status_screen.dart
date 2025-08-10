import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/status_controller.dart';

class StatusScreen extends StatelessWidget {
  final StatusController controller = Get.put(StatusController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text("status screen")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue[700],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

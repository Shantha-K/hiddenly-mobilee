import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_routes.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Inochat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialRoute: AppRoutes.SPLASH,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
 }
// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'InoChat',
//       theme: ThemeData(
//         fontFamily: 'Poppins', // Apply globally
//       ),
//       home: Scaffold(
//         appBar: AppBar(title: Text('InoChat')),
//         body: Center(child: Text('Welcome to InoChat!')),
//       ),
//     );
//   }
// }

// ...existing code...

import 'dart:typed_data';
import 'package:get/get.dart';

class Contact {
  final String name;
  final String subtitle;
  final Uint8List? photo;

  Contact({required this.name, required this.subtitle, this.photo});
}

class UserContactsController extends GetxController {
  var isLoading = false.obs;
  var allContacts = <Contact>[].obs;
  var filteredContacts = <Contact>[].obs;
  var selectedContacts = <Contact>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  Future<void> loadContacts() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));

    // Dummy data
    allContacts.value = [
      Contact(name: "Aarya", subtitle: "Lorem Ipsum is simply dummy text."),
      Contact(name: "Abhimanyu", subtitle: "Lorem Ipsum is simply dummy text."),
      Contact(name: "Andrea", subtitle: "Lorem Ipsum is simply dummy text."),
      Contact(name: "Ben", subtitle: "Lorem Ipsum is simply dummy text."),
      Contact(name: "Bianca", subtitle: "Lorem Ipsum is simply dummy text."),
      Contact(name: "Casandra", subtitle: "Lorem Ipsum is simply dummy text."),
      Contact(name: "Daemon", subtitle: "Lorem Ipsum is simply dummy text."),
    ];

    filteredContacts.assignAll(allContacts);
    isLoading.value = false;
  }

  void searchContacts(String query) {
    if (query.isEmpty) {
      filteredContacts.assignAll(allContacts);
    } else {
      filteredContacts.assignAll(
        allContacts.where((c) =>
            c.name.toLowerCase().contains(query.toLowerCase())),
      );
    }
  }

  void toggleSelect(Contact contact) {
    if (selectedContacts.contains(contact)) {
      selectedContacts.remove(contact);
    } else {
      selectedContacts.add(contact);
    }
  }

  void removeSelected(Contact contact) {
    selectedContacts.remove(contact);
  }

  bool isSelected(Contact contact) => selectedContacts.contains(contact);

  void proceedToNext() {
    if (selectedContacts.isNotEmpty) {
      Get.toNamed('/unlockChat', arguments: selectedContacts);
    }
  }
}


// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/services.dart';

// class UserContactsController extends GetxController {
//   final registeredContacts = <Contact>[].obs;
//   final isLoading = false.obs;

//   static const String _checkExistUrl =
//       "http://35.154.10.237:5000/api/contacts/check-exist";
//   static const String _chatStartUrl =
//       "http://35.154.10.237:5000/api/chat/start";

//   final Map<String, String> _jsonHeaders = const {
//     'Content-Type': 'application/json',
//   };

//   @override
//   void onInit() {
//     super.onInit();
//     fetchRegisteredContacts();
//   }

//   Future<void> loadContacts() async => fetchRegisteredContacts();

//   Future<void> fetchRegisteredContacts() async {
//     try {
//       isLoading.value = true;

//       final granted = await FlutterContacts.requestPermission();
//       if (!granted) {
//         registeredContacts.clear();
//         Get.snackbar('Permission Required', 'Please allow Contacts permission.');
//         return;
//       }

//       final contacts = await FlutterContacts.getContacts(
//         withProperties: true,
//         withPhoto: true,
//       );

//       if (contacts.isEmpty) {
//         registeredContacts.clear();
//         return;
//       }

//       final Set<String> mobileSet = {};
//       for (final c in contacts) {
//         for (final p in c.phones) {
//           final last10 = _last10Digits(p.number);
//           if (last10 != null) mobileSet.add(last10);
//         }
//       }

//       if (mobileSet.isEmpty) {
//         registeredContacts.clear();
//         return;
//       }

//       final response = await http.post(
//         Uri.parse(_checkExistUrl),
//         headers: _jsonHeaders,
//         body: json.encode({"mobiles": mobileSet.toList()}),
//       );

//       if (response.statusCode != 200) {
//         registeredContacts.clear();
//         Get.snackbar('API Error', response.reasonPhrase ?? 'Unknown error');
//         return;
//       }

//       final data = json.decode(response.body);
//       final List<String> found = List<String>.from(data['foundMobiles'] ?? []);

//       registeredContacts.value = contacts.where((c) {
//         return c.phones.any((p) {
//           final last10 = _last10Digits(p.number);
//           return last10 != null && found.contains(last10);
//         });
//       }).toList();

//       registeredContacts.sort((a, b) => a.displayName.compareTo(b.displayName));
//     } on PlatformException catch (e) {
//       registeredContacts.clear();
//       Get.snackbar('Error', e.message ?? e.toString());
//     } catch (e) {
//       registeredContacts.clear();
//       Get.snackbar('Error', e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> createChatRoom(Contact contact, String name) async {
//     final phone = contact.phones.isNotEmpty
//         ? _last10Digits(contact.phones.first.number)
//         : null;

//     if (phone == null) {
//       Get.snackbar('Invalid Number', 'No valid phone number found.');
//       return;
//     }

//     final body = {
//       "mobile": phone,
//       "username": name,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(_chatStartUrl),
//         headers: _jsonHeaders,
//         body: json.encode(body),
//       );

//       if (response.statusCode == 200) {
//         Get.toNamed('/chat', arguments: {'contact': contact});
//       } else {
//         Get.snackbar('Failed', 'Could not start chat.');
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString());
//     }
//   }

//   String? _last10Digits(String number) {
//     final digits = number.replaceAll(RegExp(r'\D'), '');
//     if (digits.length >= 10) {
//       return digits.substring(digits.length - 10);
//     }
//     return null;
//   }
// }

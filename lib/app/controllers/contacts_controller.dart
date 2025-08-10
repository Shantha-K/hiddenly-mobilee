import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ContactsController extends GetxController {
  var registeredContacts = <Contact>[].obs;
  var unregisteredContacts = <Contact>[].obs;
  var isLoading = false.obs;

  final String apiUrl = "http://35.154.10.237:5000/api/contacts/check-exist";

  @override
  void onInit() {
    super.onInit();
    fetchAndValidateContacts();
  }

  Future<void> fetchAndValidateContacts() async {
    try {
      isLoading.value = true;

      // Request permission
      if (!await FlutterContacts.requestPermission()) {
        registeredContacts.clear();
        unregisteredContacts.clear();
        return;
      }

      // Get all contacts with phone numbers
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      // Collect unique, normalized last-10-digit numbers
      final Set<String> mobileNumbers = {};
      for (final c in contacts) {
        for (final p in c.phones) {
          final normalized = p.number.replaceAll(RegExp(r'[^0-9]'), '');
          if (normalized.length >= 10) {
            mobileNumbers.add(normalized.substring(normalized.length - 10));
          }
        }
      }

      if (mobileNumbers.isEmpty) {
        registeredContacts.clear();
        unregisteredContacts.clear();
        return;
      }

      // Call API to check which numbers are registered
      final resp = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"mobiles": mobileNumbers.toList()}),
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final List<String> found = List<String>.from(
          data['foundMobiles'] ?? [],
        );
        final List<String> notFound = List<String>.from(
          data['notFoundMobiles'] ?? [],
        );

        // Filter contacts based on last 10 digits
        registeredContacts.value = contacts.where((c) {
          return c.phones.any((p) {
            final normalized = p.number.replaceAll(RegExp(r'[^0-9]'), '');
            return normalized.length >= 10 &&
                found.contains(normalized.substring(normalized.length - 10));
          });
        }).toList();

        unregisteredContacts.value = contacts.where((c) {
          return c.phones.any((p) {
            final normalized = p.number.replaceAll(RegExp(r'[^0-9]'), '');
            return normalized.length >= 10 &&
                notFound.contains(normalized.substring(normalized.length - 10));
          });
        }).toList();
      } else {
        registeredContacts.clear();
        unregisteredContacts.clear();
      }
    } on PlatformException {
      registeredContacts.clear();
      unregisteredContacts.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> inviteContact(Contact contact) async {
    if (contact.phones.isEmpty) return;
    String phone = contact.phones.first.number.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    if (phone.length >= 10) phone = phone.substring(phone.length - 10);

    String message =
        "Hey ${contact.displayName ?? ''}, join me on Inochat! https://inochat.example.com";

    final whatsapp = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(whatsapp)) {
      await launchUrl(whatsapp, mode: LaunchMode.externalApplication);
      return;
    }

    final sms = Uri.parse("sms:$phone?body=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(sms)) {
      await launchUrl(sms);
    }
  }
}

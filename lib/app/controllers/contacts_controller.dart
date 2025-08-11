// lib/app/controllers/contacts/contacts_controller.dart
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

  // If you want to change token or header later, update here
  final Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };

  @override
  void onInit() {
    super.onInit();
    fetchAndValidateContacts();
  }

  /// Public alias used by UI RefreshIndicator
  Future<void> loadContacts() async {
    await fetchAndValidateContacts();
  }

  /// Fetch phone contacts, normalize last-10-digits, call server
  Future<void> fetchAndValidateContacts() async {
    try {
      isLoading.value = true;

      // Request permission
      final granted = await FlutterContacts.requestPermission();
      if (!granted) {
        registeredContacts.clear();
        unregisteredContacts.clear();
        return;
      }

      // Get contacts (with phone numbers & photo)
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
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
        headers: defaultHeaders,
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
        // server error -> clear to avoid stale state
        registeredContacts.clear();
        unregisteredContacts.clear();
        final msg = resp.reasonPhrase ?? 'Server error';
        Get.snackbar('Contacts API error', msg);
      }
    } on PlatformException catch (e) {
      registeredContacts.clear();
      unregisteredContacts.clear();
      Get.snackbar('Platform error', e.toString());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Invite a contact: prefer WhatsApp, fallback to SMS
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
    } else {
      Get.snackbar('Cannot send', 'No app available to send invite');
    }
  }
}

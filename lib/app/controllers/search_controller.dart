import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart' as http;
import 'package:inochat/app/core/cache_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class SearchController extends GetxController {
  final CacheService _cacheService = CacheService();
  final TextEditingController searchController = TextEditingController();

  // UI state
  final registeredContacts = <Contact>[].obs;
  final isLoading = false.obs;
  var username = ''.obs;

  
  final selectedContacts = <Contact>[].obs;

  // APIs
  static const String _checkExistUrl =
      "http://35.154.10.237:5000/api/contacts/check-exist";

  final Map<String, String> _jsonHeaders = const {
    'Content-Type': 'application/json',
  };

  @override
  void onInit() {
    super.onInit();
    fetchAndValidateContacts();
  }

  Future<void> searchContacts(String query) async {
    if (query.isEmpty) {
      await fetchAndValidateContacts();
      return;
    }

    registeredContacts.value = registeredContacts.where((contact) {
      final name = (contact.displayName ?? '').toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();
  }

  Future<void> loadContacts() => fetchAndValidateContacts();

  Future<void> fetchAndValidateContacts() async {
    try {
      isLoading.value = true;

      final granted = await FlutterContacts.requestPermission();
      if (!granted) {
        registeredContacts.clear();
        Get.snackbar(
          'Permission required',
          'Please allow Contacts permission to proceed.',
        );
        return;
      }

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      if (contacts.isEmpty) {
        registeredContacts.clear();
        return;
      }

      final Set<String> mobileSet = {};
      for (final c in contacts) {
        for (final p in c.phones) {
          final last10 = _last10Digits(p.number);
          if (last10 != null) mobileSet.add(last10);
        }
      }

      if (mobileSet.isEmpty) {
        registeredContacts.clear();
        return;
      }

      final resp = await http.post(
        Uri.parse(_checkExistUrl),
        headers: _jsonHeaders,
        body: json.encode({"mobiles": mobileSet.toList()}),
      );

      if (resp.statusCode != 200) {
        registeredContacts.clear();
        Get.snackbar(
          'Contacts API error',
          resp.reasonPhrase ?? 'Server error while checking contacts',
        );
        return;
      }

      final data = json.decode(resp.body);
      final List<String> found = List<String>.from(
        data['foundMobiles'] ?? const <String>[],
      );

      registeredContacts.value = contacts.where((c) {
        return c.phones.any((p) {
          final last10 = _last10Digits(p.number);
          return last10 != null && found.contains(last10);
        });
      }).toList();

      registeredContacts.sort(
        (a, b) => (a.displayName).compareTo(b.displayName),
      );
    } on PlatformException catch (e) {
      registeredContacts.clear();
      Get.snackbar('Platform error', e.message ?? e.toString());
    } catch (e) {
      registeredContacts.clear();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Add/remove selected contact
  void toggleSelection(Contact contact) {
    if (selectedContacts.contains(contact)) {
      selectedContacts.remove(contact);
    } else {
      selectedContacts.add(contact);
    }
  }

  Future<void> inviteContact(Contact contact) async {
    if (contact.phones.isEmpty) return;

    final last10 = _last10Digits(contact.phones.first.number);
    if (last10 == null) {
      Get.snackbar('Invalid number', 'Could not parse contact number.');
      return;
    }

    final displayName = (contact.displayName.isNotEmpty)
        ? contact.displayName
        : 'there';
    final message =
        "Hey $displayName, join me on Inochat! https://inochat.example.com";

    final whatsapp = Uri.parse(
      "https://wa.me/$last10?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsapp)) {
      await launchUrl(whatsapp, mode: LaunchMode.externalApplication);
      return;
    }

    final sms = Uri.parse("sms:$last10?body=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(sms)) {
      await launchUrl(sms, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Cannot send',
        'No compatible app found to send the invitation.',
      );
    }
  }

  /// ✅ Navigate to chat screen without creating chatId
  Future<void> openChat(Contact contact, String name) async {
    try {
      if (contact.phones.isEmpty) {
        Get.snackbar('Error', 'Selected contact has no phone number.');
        return;
      }

      final receiver = _last10Digits(contact.phones.first.number);
      if (receiver == null) {
        Get.snackbar('Error', 'Invalid receiver number.');
        return;
      }
      // no-op for now
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong while opening the chat.');
    }
  }

  String? _last10Digits(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) return null;
    return digits.substring(digits.length - 10);
  }

  Future<void> refreshContacts() async {
    await loadContacts();
  }
}

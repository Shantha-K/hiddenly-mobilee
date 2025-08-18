// lib/app/controllers/contacts/contacts_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart' as http;
import 'package:inochat/app/core/cache_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ContactsController extends GetxController {
  final CacheService _cacheService = CacheService();

  // UI state
  final registeredContacts = <Contact>[].obs;
  final unregisteredContacts = <Contact>[].obs;
  final isLoading = false.obs;
  var username = ''.obs;

  // APIs
  static const String _checkExistUrl =
      "http://35.154.10.237:5000/api/contacts/check-exist";
  static const String _chatStartUrl =
      "http://35.154.10.237:5000/api/chat/start";

  final Map<String, String> _jsonHeaders = const {
    'Content-Type': 'application/json',
  };

  @override
  void onInit() {
    super.onInit();
    fetchAndValidateContacts();
  }

  /// Public alias for pull-to-refresh
  Future<void> loadContacts() => fetchAndValidateContacts();

  /// Fetch device contacts, normalize to last-10 digits, check with server,
  /// and split into registered/unregistered lists
  Future<void> fetchAndValidateContacts() async {
    try {
      isLoading.value = true;

      // 1) Ask permission
      final granted = await FlutterContacts.requestPermission();
      if (!granted) {
        registeredContacts.clear();
        unregisteredContacts.clear();
        Get.snackbar(
          'Permission required',
          'Please allow Contacts permission to proceed.',
        );
        return;
      }

      // 2) Read contacts with phone + photo
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      if (contacts.isEmpty) {
        registeredContacts.clear();
        unregisteredContacts.clear();
        return;
      }

      // 3) Build unique set of last-10-digit numbers
      final Set<String> mobileSet = {};
      for (final c in contacts) {
        for (final p in c.phones) {
          final last10 = _last10Digits(p.number);
          if (last10 != null) mobileSet.add(last10);
        }
      }

      if (mobileSet.isEmpty) {
        registeredContacts.clear();
        unregisteredContacts.clear();
        return;
      }

      // 4) Call backend to check existence
      final resp = await http.post(
        Uri.parse(_checkExistUrl),
        headers: _jsonHeaders,
        body: json.encode({"mobiles": mobileSet.toList()}),
      );

      if (resp.statusCode != 200) {
        registeredContacts.clear();
        unregisteredContacts.clear();
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
      final List<String> notFound = List<String>.from(
        data['notFoundMobiles'] ?? const <String>[],
      );

      // 5) Split contacts based on any phone matching the sets
      registeredContacts.value = contacts.where((c) {
        return c.phones.any((p) {
          final last10 = _last10Digits(p.number);
          return last10 != null && found.contains(last10);
        });
      }).toList();

      unregisteredContacts.value = contacts.where((c) {
        return c.phones.any((p) {
          final last10 = _last10Digits(p.number);
          return last10 != null && notFound.contains(last10);
        });
      }).toList();

      // Optional: sort by display name for nicer UI
      registeredContacts.sort(
        (a, b) => (a.displayName).compareTo(b.displayName),
      );
      unregisteredContacts.sort(
        (a, b) => (a.displayName).compareTo(b.displayName),
      );
    } on PlatformException catch (e) {
      registeredContacts.clear();
      unregisteredContacts.clear();
      Get.snackbar('Platform error', e.message ?? e.toString());
    } catch (e) {
      registeredContacts.clear();
      unregisteredContacts.clear();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Invite a contact (WhatsApp first, then SMS)
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

  /// Create (or get) a chat room between me and the selected device contact,
  /// always using last-10-digit normalized numbers.
  Future<void> creatChatRoom(Contact contact, String name) async {
    try {
      // 1) Validate contact has a number
      if (contact.phones.isEmpty) {
        Get.snackbar('Error', 'Selected contact has no phone number.');
        return;
      }


      // 2) Read my number from cache
      final myRaw = await _cacheService.getMyMobileNumber();
      final sender = _last10Digits(myRaw ?? '');
      final receiver = _last10Digits(contact.phones.first.number);

      if (sender == null || receiver == null) {
        Get.snackbar('Error', 'Could not parse sender/receiver numbers.');
        return;
      }

      // 3) Call chat start API
      final resp = await http.post(
        Uri.parse(_chatStartUrl),
        headers: _jsonHeaders,
        body: json.encode({"sender": sender, "receiver": receiver}),
      );

      if (resp.statusCode != 200) {
        Get.snackbar(
          'Error',
          resp.reasonPhrase ?? 'Failed to create or fetch chat room.',
        );
        return;
      }

      final data = json.decode(resp.body);
      final chatId = data['chatId'];

      if (chatId == null || chatId.toString().isEmpty) {
        Get.snackbar('Error', 'Chat room creation failed: missing chatId.');
        return;
      }

      // 4) Navigate to chat detail
      Get.toNamed(
        '/chat_detail',
        arguments: {
          'chatId': chatId.toString(),
          // Important: pass the same normalized receiver used in history API
          'contact': receiver,
          'name': name, // Pass contact name for display
        },
      );
    } catch (e, st) {
      // Keep logs helpful during dev
      // ignore: avoid_print
      print('Error creating chat room: $e\n$st');
      Get.snackbar(
        'Error',
        'Something went wrong while creating or opening the chat room.',
      );
    }
  }

  // ------------------------
  // Helpers
  // ------------------------

  /// Returns last 10 digits of any phone-like string; null if < 10 digits.
  String? _last10Digits(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) return null;
    return digits.substring(digits.length - 10);
    // If you need to force Indian numbers, you can also prefix +91 when sending out.
  }
}

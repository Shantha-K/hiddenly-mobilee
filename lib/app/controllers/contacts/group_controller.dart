import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:inochat/app/core/cache_service.dart';

class GroupController extends GetxController {
  final groupName = ''.obs;
  final autoDeleteOption = 'timeline'.obs;
  final autoDeleteAt = Rxn<DateTime>();

  final textChecked = true.obs;
  final voiceChecked = false.obs;
  final mediaChecked = true.obs;
  final docsChecked = false.obs;
  final attachChecked = false.obs;

  final isLoading = false.obs;

  Future<void> createGroup(List<Contact> selectedContacts) async {
    String? myMobileNumber = await CacheService().getMyMobileNumber();

    if (groupName.value.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a group name');
      return;
    }
    if (selectedContacts.isEmpty) {
      Get.snackbar('Error', 'Please select at least one contact');
      return;
    }

    try {
      isLoading.value = true;

      // final participants = selectedContacts
      //     .map((c) => c.phones.isNotEmpty ? c.phones.first.number : '')
      //     .map(_last10Digits)
      //     .whereType<String>()
      //     .toList();

      List<String> selectContacts = selectedContacts
          .map((c) => c.phones.isNotEmpty ? c.phones.first.number : '')
          .map(_last10Digits)
          .whereType<String>()
          .toList();

      selectContacts.add(myMobileNumber!);

      print('Selected contacts: $selectContacts');

      final contentTypes = <String>[];
      if (textChecked.value) contentTypes.add('text');
      if (voiceChecked.value) contentTypes.add('voice');
      if (mediaChecked.value) contentTypes.add('media');
      if (docsChecked.value) contentTypes.add('documents');
      if (attachChecked.value) contentTypes.add('attachments');

      final autoDelete = autoDeleteOption.value == 'timeline';
      final deleteAt = autoDelete ? autoDeleteAt.value : null;

      final url = Uri.parse('http://35.154.10.237:5000/api/group/Creategroup');

      final res = await http.post(
        url,
        headers: const {'Content-Type': 'application/json'},
        body: json.encode({
          "title": groupName.value.trim(),
          "participants": selectContacts,
          "autoDelete": autoDelete,
          "autoDeleteAt": deleteAt?.toUtc().toIso8601String(),
          "contentTypes": contentTypes,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = json.decode(res.body);
        final group = data['group'];

        final String createdGroupId = group?['_id']?.toString() ?? '';
        print('Created group ID: $createdGroupId');
        final String createdGroupName =
            group?['title']?.toString() ?? groupName.value.trim();

        Get.snackbar(
          'Success',
          data['message'] ?? 'Group created successfully',
        );

        print('Selected contacts: $selectedContacts');

        Get.offNamed(
          '/groupchat_screen',
          arguments: {
            'groupId': createdGroupId,
            'groupName': createdGroupName,
            'selectedContacts': selectContacts,
          },
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to create group (${res.statusCode}): ${res.body}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String? _last10Digits(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) return null;
    return digits.substring(digits.length - 10);
  }
}

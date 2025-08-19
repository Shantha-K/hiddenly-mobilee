import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:inochat/app/controllers/search_controller.dart';

class SearchScreen extends GetWidget<SearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F8FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: controller.searchController,
            onChanged: (val) => controller.searchContacts(val),
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[600]),
                onPressed: () {
                  controller.searchController.clear();
                  controller.searchContacts("");
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.registeredContacts.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refreshContacts,
            child: ListView(
              children: const [
                SizedBox(
                  height: 400,
                  child: Center(child: Text('No contacts found.')),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshContacts,
          child: ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            children: [
              ...controller.registeredContacts.map((contact) {
                final name = contact.displayName ?? '';
                final subtitle =
                    (contact.notes != null && contact.notes.isNotEmpty)
                    ? contact.notes!.first.toString()
                    : 'Hey, would you be interested in ...';
                final time = _mockTime(
                  controller.registeredContacts.indexOf(contact),
                );

                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        (contact.photoOrThumbnail != null &&
                            contact.photoOrThumbnail!.isNotEmpty)
                        ? MemoryImage(contact.photoOrThumbnail!)
                        : null,
                    child:
                        (contact.photoOrThumbnail == null ||
                            contact.photoOrThumbnail!.isEmpty)
                        ? Text(
                            name.isNotEmpty ? name[0] : '?',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    time,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    // ✅ now using openChat (no chatId API call)
                    controller.openChat(contact, name);
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }),
    );
  }

  String _mockTime(int index) {
    const times = [
      '24m ago',
      '40m ago',
      '1h ago',
      '2d ago',
      '4d ago',
      '5d ago',
      '1w ago',
      '5d ago',
      '1w ago',
    ];
    return times[index % times.length];
  }
}

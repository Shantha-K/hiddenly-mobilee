import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:inochat/app/controllers/search_controller.dart';
import 'group_screen.dart';

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
          onPressed: () => Get.back(),
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

        return Column(
          children: [
            // Selected users row (as per image)
            Obx(() {
              if (controller.selectedContacts.isEmpty) {
                return const SizedBox.shrink();
              }
              return SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: controller.selectedContacts.map((c) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    (c.photoOrThumbnail != null &&
                                        c.photoOrThumbnail!.isNotEmpty)
                                    ? MemoryImage(c.photoOrThumbnail!)
                                    : null,
                                child:
                                    (c.photoOrThumbnail == null ||
                                        c.photoOrThumbnail!.isEmpty)
                                    ? Text(
                                        c.displayName.isNotEmpty
                                            ? c.displayName[0]
                                            : '?',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () =>
                                        controller.toggleSelection(c),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 60,
                            child: Text(
                              c.displayName,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }),

            // Contact list
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshContacts,
                child: ListView(
                  padding: const EdgeInsets.only(top: 16, bottom: 80),
                  children: controller.registeredContacts.map((contact) {
                    final name = contact.displayName ?? '';
                    final subtitle =
                        (contact.notes != null && contact.notes.isNotEmpty)
                        ? contact.notes!.first.toString()
                        : 'Lorem Ipsum is simply dummy text.';

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
                      trailing: Obx(
                        () => controller.selectedContacts.contains(contact)
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const SizedBox.shrink(),
                      ),
                      onTap: () => controller.toggleSelection(contact),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.selectedContacts.isEmpty) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton(
          backgroundColor: Colors.blue,
          child: const Icon(Icons.arrow_forward, color: Colors.white),
          onPressed: () {
            Get.to(
              () => GroupScreen(
                selectedContacts: controller.selectedContacts.toList(),
              ),
            );
          },
        );
      }),
    );
  }
}



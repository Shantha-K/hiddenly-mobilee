// lib/app/screens/contacts/contacts_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inochat/app/controllers/contacts_controller.dart';

class ContactsScreen extends StatelessWidget {
  final ContactsController controller = Get.put(ContactsController());

  Future<void> _refreshContacts() async {
    await controller.loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.registeredContacts.isEmpty &&
            controller.unregisteredContacts.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refreshContacts,
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
          onRefresh: _refreshContacts,
          child: ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            children: [
              // Registered contacts
              if (controller.registeredContacts.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Registered Contacts',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ...controller.registeredContacts.map((contact) {
                  final name = contact.displayName ?? '';
                  final subtitle =
                      (contact.notes != null && contact.notes!.isNotEmpty)
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
                      // pass Contact object directly to chat screen
                      Get.toNamed('/chat_detail', arguments: contact);
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                  );
                }).toList(),
              ],

              // Unregistered contacts
              if (controller.unregisteredContacts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Invite to Inochat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
                ...controller.unregisteredContacts.map((contact) {
                  final name = contact.displayName ?? '';
                  final subtitle =
                      (contact.notes != null && contact.notes!.isNotEmpty)
                      ? contact.notes!.first.toString()
                      : 'Invite to join Inochat!';

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
                    trailing: TextButton(
                      onPressed: () => controller.inviteContact(contact),
                      child: const Text(
                        'Invite',
                        style: TextStyle(
                          color: Color(0xFF2253A2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2253A2),
        child: const Icon(Icons.message, color: Colors.white),
      ),
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

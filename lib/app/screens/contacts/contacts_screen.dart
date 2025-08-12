import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/contacts_controller.dart';

class ContactsScreen extends StatelessWidget {
  final ContactsController controller = Get.put(ContactsController());

  ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.registeredContacts.isEmpty &&
            controller.unregisteredContacts.isEmpty) {
          return Center(child: Text('No contacts found.'));
        }
        return ListView(
          padding: EdgeInsets.only(top: 16, bottom: 80),
          children: [
            if (controller.registeredContacts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              ...controller.registeredContacts.map((contact) {
                final name = contact.displayName;
                final subtitle = contact.notes.isNotEmpty
                    ? contact.notes.first.toString()
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    time,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {},
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                );
              }),
            ],
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
                final name = contact.displayName;
                final subtitle = contact.notes.isNotEmpty
                    ? contact.notes.first.toString()
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: TextButton(
                    onPressed: () => controller.inviteContact(contact),
                    child: Text(
                      'Invite',
                      style: TextStyle(
                        color: Color(0xFF2253A2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                );
              }),
            ],
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(0xFF2253A2),
        child: Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  String _mockTime(int index) {
    // Demo times for Figma look
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

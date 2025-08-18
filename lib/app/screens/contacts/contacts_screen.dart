import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inochat/app/controllers/contacts_controller.dart';

// Dummy AppBarController for search and logout functionality
class AppBarController extends GetxController {
  final RxBool isSearching = false.obs;
  final RxString searchText = ''.obs;

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchText.value = '';
    }
  }

  void logout() {
    // Implement logout logic here
    Get.snackbar('Logout', 'You have been logged out.');
  }
}

class ContactsScreen extends StatelessWidget {
  final ContactsController controller = Get.put(ContactsController());
  final AppBarController appBarController = Get.put(AppBarController());

  ContactsScreen({super.key});

  Future<void> _refreshContacts() async {
    await controller.loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 Custom AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.fromARGB(255, 99, 176, 235), Colors.white],
              ),
            ),
            child: Row(
              children: [
                // 🔹 Reactive Title / Search Field
                Expanded(
                  child: appBarController.isSearching.value
                      ? TextField(
                          autofocus: true,
                          onChanged: (v) =>
                              appBarController.searchText.value = v,
                          decoration: const InputDecoration(
                            hintText: "Search contacts...",
                            border: InputBorder.none,
                          ),
                        )
                      : const Text(
                          "Inochat Contacts",
                          style: TextStyle(
                            color: Color(0xFF2253A2),
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                ),

                // 🔹 Search toggle
                IconButton(
                  icon: Icon(
                    appBarController.isSearching.value
                        ? Icons.close
                        : Icons.search,
                    color: const Color(0xFF7B8FA1),
                  ),
                  onPressed: () => appBarController.toggleSearch(),
                ),

                // 🔹 Popup menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF7B8FA1)),
                  onSelected: (value) {
                    if (value == 'settings') {
                      Get.to(() => const SettingsScreen());
                    } else if (value == 'logout') {
                      appBarController.logout();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'settings',
                      child: Text("Settings"),
                    ),
                    const PopupMenuItem(value: 'logout', child: Text("Logout")),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // 🔹 Contacts list
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 🔹 Filter registered + unregistered contacts by search
        final query = appBarController.searchText.value.toLowerCase();

        final registered = controller.registeredContacts.where((c) {
          final name = c.displayName?.toLowerCase() ?? '';
          return query.isEmpty || name.contains(query);
        }).toList();

        final unregistered = controller.unregisteredContacts.where((c) {
          final name = c.displayName?.toLowerCase() ?? '';
          return query.isEmpty || name.contains(query);
        }).toList();

        if (registered.isEmpty && unregistered.isEmpty) {
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
              if (registered.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Registered Contacts',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ...registered.map((contact) {
                  final name = contact.displayName ?? '';
                  final subtitle =
                      (contact.notes != null && contact.notes!.isNotEmpty)
                      ? contact.notes!.first.toString()
                      : 'Hey, would you be interested in ...';
                  final time = _mockTime(registered.indexOf(contact));

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
                    onTap: () => controller.creatChatRoom(contact),
                  );
                }).toList(),
              ],

              // Unregistered contacts
              if (unregistered.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Invite to Inochat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2253A2),
                    ),
                  ),
                ),
                ...unregistered.map((contact) {
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

// Dummy settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: const Center(child: Text("Settings Page")),
    );
  }
}

// lib/app/screens/contacts/contacts_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:inochat/app/controllers/contacts_controller.dart';

// class ContactsScreen extends StatelessWidget {
//   final ContactsController controller = Get.put(ContactsController());

//   Future<void> _refreshContacts() async {
//     await controller.loadContacts();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (controller.registeredContacts.isEmpty &&
//             controller.unregisteredContacts.isEmpty) {
//           return RefreshIndicator(
//             onRefresh: _refreshContacts,
//             child: ListView(
//               children: const [
//                 SizedBox(
//                   height: 400,
//                   child: Center(child: Text('No contacts found.')),
//                 ),
//               ],
//             ),
//           );
//         }

//         return RefreshIndicator(
//           onRefresh: _refreshContacts,
//           child: ListView(
//             padding: const EdgeInsets.only(top: 16, bottom: 80),
//             children: [
//               // Registered contacts
//               if (controller.registeredContacts.isNotEmpty) ...[
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Text(
//                     'Registered Contacts',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                 ),
//                 ...controller.registeredContacts.map((contact) {
//                   final name = contact.displayName ?? '';
//                   final subtitle =
//                       (contact.notes != null && contact.notes!.isNotEmpty)
//                       ? contact.notes!.first.toString()
//                       : 'Hey, would you be interested in ...';
//                   final time = _mockTime(
//                     controller.registeredContacts.indexOf(contact),
//                   );

//                   return ListTile(
//                     leading: CircleAvatar(
//                       radius: 24,
//                       backgroundColor: Colors.grey[200],
//                       backgroundImage:
//                           (contact.photoOrThumbnail != null &&
//                               contact.photoOrThumbnail!.isNotEmpty)
//                           ? MemoryImage(contact.photoOrThumbnail!)
//                           : null,
//                       child:
//                           (contact.photoOrThumbnail == null ||
//                               contact.photoOrThumbnail!.isEmpty)
//                           ? Text(
//                               name.isNotEmpty ? name[0] : '?',
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 color: Colors.blue[900],
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             )
//                           : null,
//                     ),
//                     title: Text(
//                       name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     subtitle: Text(
//                       subtitle,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     trailing: Text(
//                       time,
//                       style: const TextStyle(color: Colors.grey, fontSize: 12),
//                     ),
//                     onTap: () {
//                       // pass Contact object directly to chat screen
//                       controller.creatChatRoom(contact);
//                     },
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 4,
//                     ),
//                   );
//                 }).toList(),
//               ],

//               // Unregistered contacts
//               if (controller.unregisteredContacts.isNotEmpty) ...[
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   child: Text(
//                     'Invite to Inochat',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Colors.blue[900],
//                     ),
//                   ),
//                 ),
//                 ...controller.unregisteredContacts.map((contact) {
//                   final name = contact.displayName ?? '';
//                   final subtitle =
//                       (contact.notes != null && contact.notes!.isNotEmpty)
//                       ? contact.notes!.first.toString()
//                       : 'Invite to join Inochat!';

//                   return ListTile(
//                     leading: CircleAvatar(
//                       radius: 24,
//                       backgroundColor: Colors.grey[200],
//                       backgroundImage:
//                           (contact.photoOrThumbnail != null &&
//                               contact.photoOrThumbnail!.isNotEmpty)
//                           ? MemoryImage(contact.photoOrThumbnail!)
//                           : null,
//                       child:
//                           (contact.photoOrThumbnail == null ||
//                               contact.photoOrThumbnail!.isEmpty)
//                           ? Text(
//                               name.isNotEmpty ? name[0] : '?',
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 color: Colors.blue[900],
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             )
//                           : null,
//                     ),
//                     title: Text(
//                       name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     subtitle: Text(
//                       subtitle,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     trailing: TextButton(
//                       onPressed: () => controller.inviteContact(contact),
//                       child: const Text(
//                         'Invite',
//                         style: TextStyle(
//                           color: Color(0xFF2253A2),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 4,
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ],
//           ),
//         );
//       }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {},
//         backgroundColor: const Color(0xFF2253A2),
//         child: const Icon(Icons.message, color: Colors.white),
//       ),
//     );
//   }

//   String _mockTime(int index) {
//     const times = [
//       '24m ago',
//       '40m ago',
//       '1h ago',
//       '2d ago',
//       '4d ago',
//       '5d ago',
//       '1w ago',
//       '5d ago',
//       '1w ago',
//     ];
//     return times[index % times.length];
//   }
// }

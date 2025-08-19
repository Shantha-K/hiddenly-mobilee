import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inochat/app/controllers/user_contact_controller.dart';

class UserContactsView extends StatelessWidget {
  final controller = Get.put(UserContactsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // 🔹 Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD1F3F3), Color(0xFFEFFCFC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(24)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: controller.searchContacts,
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Selected Contacts Horizontal List
              Obx(() => controller.selectedContacts.isEmpty
                  ? const SizedBox.shrink()
                  : Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.selectedContacts.length,
                        itemBuilder: (context, index) {
                          final contact =
                              controller.selectedContacts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.grey[300],
                                      child: Text(contact.name[0]),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: () =>
                                            controller.removeSelected(contact),
                                        child: const CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.red,
                                          child: Icon(Icons.close,
                                              size: 12, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(contact.name,
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          );
                        },
                      ),
                    )),

              // 🔹 Contacts List
              Expanded(
                child: ListView.builder(
                  itemCount: controller.filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = controller.filteredContacts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[200],
                        child: Text(contact.name[0]),
                      ),
                      title: Text(contact.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(contact.subtitle,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: controller.isSelected(contact)
                          ? const Icon(Icons.check_circle,
                              color: Colors.green)
                          : null,
                      onTap: () => controller.toggleSelect(contact),
                    );
                  },
                ),
              ),

              // 🔹 Proceed Button
              Obx(() => controller.selectedContacts.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          backgroundColor: Colors.lightBlueAccent,
                          onPressed: controller.proceedToNext,
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),

              // Footer
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Made with '),
                      WidgetSpan(
                        child: Icon(Icons.favorite,
                            color: Colors.purple, size: 16),
                      ),
                      TextSpan(
                        text: ' Yisily',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}


// lib/app/screens/user_contacts/user_contacts_screen.dart

// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// // Dummy UserContactsController implementation for demonstration.
// // Replace with your actual logic and models.
// class UserContactsController extends GetxController {
//   var isLoading = false.obs;
//   var registeredContacts = <Contact>[].obs;

//   Future<void> loadContacts() async {
//     isLoading.value = true;
//     // Simulate loading contacts
//     await Future.delayed(const Duration(seconds: 1));
//     // Populate with dummy data
//     registeredContacts.value = [
//       Contact(
//         displayName: 'John Doe',
//         notes: ['Friend from school'],
//         photoOrThumbnail: null,
//       ),
//       Contact(
//         displayName: 'Jane Smith',
//         notes: ['Work colleague'],
//         photoOrThumbnail: null,
//       ),
//     ];
//     isLoading.value = false;
//   }

//   void createChatRoom(Contact contact, String name) {
//     // Implement chat room creation logic here
//     Get.snackbar('Chat', 'Chat room created for $name');
//   }
// }

// // Dummy Contact model for demonstration.
// // Replace with your actual Contact model.
// class Contact {
//   final String? displayName;
//   final List<String>? notes;
//   final Uint8List? photoOrThumbnail;

//   Contact({
//     this.displayName,
//     this.notes,
//     this.photoOrThumbnail,
//   });
// }

// class UserContactsScreen extends StatelessWidget {
//   final UserContactsController controller = Get.put(UserContactsController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Obx(() {
//           if (controller.isLoading.value) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return RefreshIndicator(
//             onRefresh: controller.loadContacts,
//             child: Column(
//               children: [
//                 // Header
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Color(0xFFD1F3F3), Color(0xFFEFFCFC)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.arrow_back),
//                         onPressed: () => Get.back(),
//                       ),
//                       const Expanded(
//                         child: TextField(
//                           decoration: InputDecoration(
//                             hintText: 'Search',
//                             prefixIcon: Icon(Icons.search),
//                             filled: true,
//                             fillColor: Colors.white,
//                             contentPadding: EdgeInsets.symmetric(horizontal: 16),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.all(Radius.circular(24)),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Contacts List
//                 Expanded(
//                   child: controller.registeredContacts.isEmpty
//                       ? const Center(child: Text('No registered contacts found.'))
//                       : ListView.builder(
//                           padding: const EdgeInsets.only(bottom: 16),
//                           itemCount: controller.registeredContacts.length,
//                           itemBuilder: (context, index) {
//                             final contact = controller.registeredContacts[index];
//                             final name = contact.displayName ?? '';
//                             final subtitle = (contact.notes != null &&
//                                     contact.notes!.isNotEmpty)
//                                 ? contact.notes!.first
//                                 : 'Lorem Ipsum is simply dummy text.';

//                             return ListTile(
//                               leading: CircleAvatar(
//                                 radius: 24,
//                                 backgroundImage: (contact.photoOrThumbnail != null &&
//                                         contact.photoOrThumbnail!.isNotEmpty)
//                                     ? MemoryImage(contact.photoOrThumbnail!)
//                                     : null,
//                                 backgroundColor: Colors.grey[200],
//                                 child: (contact.photoOrThumbnail == null ||
//                                         contact.photoOrThumbnail!.isEmpty)
//                                     ? Text(
//                                         name.isNotEmpty ? name[0] : '?',
//                                         style: const TextStyle(
//                                           fontSize: 22,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black87,
//                                         ),
//                                       )
//                                     : null,
//                               ),
//                               title: Text(
//                                 name,
//                                 style: const TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               subtitle: Text(
//                                 subtitle,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               onTap: () => controller.createChatRoom(contact, name),
//                             );
//                           },
//                         ),
//                 ),

//                 // Footer
//                 const Padding(
//                   padding: EdgeInsets.only(bottom: 10),
//                   child: Text.rich(
//                     TextSpan(
//                       children: [
//                         TextSpan(text: 'Made with '),
//                         WidgetSpan(
//                           child: Icon(Icons.favorite, color: Colors.purple, size: 16),
//                         ),
//                         TextSpan(
//                           text: ' Yisily',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blueAccent,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

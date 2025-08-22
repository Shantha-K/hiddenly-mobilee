import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:inochat/app/controllers/chat_controller.dart';
import 'package:inochat/app/controllers/contacts/chat_detail_controller.dart';
import 'package:inochat/app/routes/app_routes.dart';
import 'package:inochat/app/screens/chat/search_screen.dart';
import 'package:inochat/app/screens/settings/settings_screen.dart';
import 'contacts/contacts_screen.dart';
import 'chat/chat_screen.dart';
import 'status/status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatController controller = Get.put(ChatController());

  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  static final List<Widget> _screens = [
    ContactsScreen(),
    ChatScreen(),
    StatusScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 250),
      curve: Curves.ease,
    );
  }

  Widget _buildTab(String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Color(0xFF2253A2) : Color(0xFFB0B7C3),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 16,
                letterSpacing: 0.1,
              ),
            ),
            SizedBox(height: 2),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 38 : 0,
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF2253A2) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(108),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 99, 176, 235), // light blue top
                Colors.white, // white bottom
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 18,
                    top: 8,
                    right: 8,
                    bottom: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inochat',
                        style: TextStyle(
                          color: Color(0xFF2253A2),
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                          letterSpacing: 0.1,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: Color(0xFF7B8FA1),
                            ),
                            onPressed: () {
                              // Navigate to ContactsScreen using GetX
                              Get.to(() => ContactsScreen());
                            },
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Color(0xFF7B8FA1),
                            ),
                            onSelected: (value) {
                              switch (value) {
                                case "new_group":
                                  Get.toNamed(AppRoutes.SEARCH_CONTACTS)!.then((
                                    _,
                                  ) {
                                    // open contacts for group
                                    controller.fetchChats();
                                  });
                                  break;
                                case "settings":
                                  Get.to(
                                    () => SettingsView(),
                                  ); // open settings screen
                                  break;
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem(
                                value: "new_group",
                                child: Text("New Group"),
                              ),
                              const PopupMenuDivider(), // divider line
                              const PopupMenuItem(
                                value: "settings",
                                child: Text("Settings"),
                              ),
                            ],
                          ),
                        ],
                      ),

                      //     Row(
                      //       children: [
                      //         IconButton(
                      //           icon: Icon(Icons.search, color: Color(0xFF7B8FA1)),
                      //           onPressed: () {},
                      //         ),
                      //         IconButton(
                      //           icon: Icon(
                      //             Icons.more_vert,
                      //             color: Color(0xFF7B8FA1),
                      //           ),
                      //           onPressed: () {},
                      //         ),
                      //       ],
                      //     ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTab('Contacts', 0),
                      _buildTab('Chat', 1),
                      _buildTab('Status', 2),
                    ],
                  ),
                ),
                SizedBox(height: 2),
                Divider(
                  height: 2,
                  thickness: 4,
                  color: Color.fromARGB(182, 243, 244, 246),
                ),
              ],
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: const BouncingScrollPhysics(),
        children: _screens,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

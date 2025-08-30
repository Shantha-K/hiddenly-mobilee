import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/status_controller.dart';

class StatusScreen extends StatelessWidget {
  final StatusController controller = Get.put(StatusController());

  StatusScreen({super.key});

  final List<Map<String, String>> unseen = [
    {
      "name": "Abhimanyu",
      "avatar": "https://randomuser.me/api/portraits/men/11.jpg",
      "subtitle": "New status available",
    },
    {
      "name": "Andrea",
      "avatar": "https://randomuser.me/api/portraits/women/12.jpg",
      "subtitle": "New status available",
    },
    {
      "name": "Ben",
      "avatar": "https://randomuser.me/api/portraits/men/13.jpg",
      "subtitle": "New status available",
    },
    {
      "name": "Bianca",
      "avatar": "https://randomuser.me/api/portraits/women/14.jpg",
      "subtitle": "New status available",
    },
    {
      "name": "Ben",
      "avatar": "https://randomuser.me/api/portraits/men/15.jpg",
      "subtitle": "New status available",
    },
  ];

  final List<Map<String, String>> seen = [
    {
      "name": "Casandra",
      "avatar": "https://randomuser.me/api/portraits/women/16.jpg",
      "subtitle": "Viewed 12 minutes ago",
    },
    {
      "name": "Daemon",
      "avatar": "https://randomuser.me/api/portraits/men/17.jpg",
      "subtitle": "Viewed 1 hour ago",
    },
    {
      "name": "Aarya",
      "avatar": "https://randomuser.me/api/portraits/women/18.jpg",
      "subtitle": "Viewed 2 hours ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // My Status
          ListTile(
            leading: CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(
                "https://randomuser.me/api/portraits/men/10.jpg",
              ),
            ),
            title: const Text(
              "My Status",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Tap to add status"),
            onTap: () {},
          ),
          const SizedBox(height: 8),
          // Unseen Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              "Unseen",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 15,
              ),
            ),
          ),
          // Unseen List
          ...unseen.map(
            (item) => ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(item["avatar"]!),
              ),
              title: Text(
                item["name"]!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                item["subtitle"]!,
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          // Seen Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              "Seen",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 15,
              ),
            ),
          ),
          // Seen List
          ...seen.map(
            (item) => ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(item["avatar"]!),
              ),
              title: Text(
                item["name"]!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                item["subtitle"]!,
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

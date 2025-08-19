import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inochat/app/controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB2F4FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => Column(
          children: [
            // 🔹 Profile Image
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  color: const Color(0xFFB2F4FF),
                ),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: controller.photo.value != null
                      ? MemoryImage(controller.photo.value!)
                      : const AssetImage("assets/images/default_avatar.png")
                            as ImageProvider,
                ),
                Positioned(
                  right: MediaQuery.of(context).size.width / 2 - 20,
                  top: 120,
                  child: GestureDetector(
                    onTap: () {
                      // Add image picker here
                      Get.snackbar("Profile", "Change photo clicked");
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera_alt, color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 🔹 Editable Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _ProfileField(
                    label: "Name",
                    value: controller.name.value,
                    onEdit: () => _editField(
                      context,
                      "Name",
                      controller.name.value,
                      controller.updateName,
                    ),
                  ),
                  const Divider(),
                  _ProfileField(
                    label: "About",
                    value: controller.about.value,
                    onEdit: () => _editField(
                      context,
                      "About",
                      controller.about.value,
                      controller.updateAbout,
                    ),
                  ),
                  const Divider(),
                  _ProfileField(
                    label: "Phone",
                    value: controller.phone.value,
                    onEdit: null,
                  ),
                  const SizedBox(height: 40),

                  // 🔹 Delete Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: controller.deleteAccount,
                      child: const Text(
                        "Delete my account",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editField(
    BuildContext context,
    String label,
    String value,
    Function(String) onSave,
  ) {
    final TextEditingController textController = TextEditingController(
      text: value,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit $label"),
        content: TextField(controller: textController),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              onSave(textController.text);
              Get.back();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onEdit;

  const _ProfileField({
    required this.label,
    required this.value,
    this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      trailing: onEdit != null
          ? IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: onEdit,
            )
          : null,
      contentPadding: EdgeInsets.zero,
    );
  }
}

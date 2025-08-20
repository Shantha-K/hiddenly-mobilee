import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:inochat/app/controllers/contacts/group_controller.dart';

class GroupScreen extends StatelessWidget {
  final List<Contact> selectedContacts;
  final GroupController controller = Get.put(GroupController());

  GroupScreen({super.key, required this.selectedContacts});

  void _showAutoDeleteDialog(BuildContext context) async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    int selectedHour = 12;
    int selectedMinute = 0;
    String selectedPeriod = "AM";

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Auto deleting group at",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date Picker
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${selectedDate.day.toString().padLeft(2, '0')} - "
                            "${_monthName(selectedDate.month)} - "
                            "${selectedDate.year}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Time selectors
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _dropdown<int>(
                        value: selectedHour,
                        items: List.generate(12, (i) => i + 1),
                        onChanged: (v) => setState(() => selectedHour = v!),
                      ),
                      _dropdown<int>(
                        value: selectedMinute,
                        items: List.generate(60, (i) => i),
                        onChanged: (v) => setState(() => selectedMinute = v!),
                      ),
                      _dropdown<String>(
                        value: selectedPeriod,
                        items: ["AM", "PM"],
                        onChanged: (v) => setState(() => selectedPeriod = v!),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        int hour24 = selectedHour % 12;
                        if (selectedPeriod == "PM") hour24 += 12;

                        final combinedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          hour24,
                          selectedMinute,
                        );

                        controller.autoDeleteOption.value = 'timeline';
                        controller.autoDeleteAt.value = combinedDateTime;

                        Get.back();
                        Get.snackbar(
                          "Selected",
                          "Auto delete set at $combinedDateTime",
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Set",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<T>(
          value: value,
          underline: const SizedBox(),
          isExpanded: true,
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text("$i")))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("New group", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group title
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  onChanged: (val) => controller.groupName.value = val,
                  decoration: const InputDecoration(
                    hintText: "Add group title here",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Selected users row
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: selectedContacts.map((c) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 28,
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
              ),
              const SizedBox(height: 20),

              // Auto deleting group
              const Text(
                "Auto deleting group",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              RadioListTile<String>(
                value: "timeline",
                groupValue: controller.autoDeleteOption.value,
                onChanged: (val) {
                  controller.autoDeleteOption.value = val!;
                  _showAutoDeleteDialog(context);
                },
                title: const Text("Timeline Set for Deleting"),
                subtitle: const Text(
                  "You can set your time for deleting automatically",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              RadioListTile<String>(
                value: "never",
                groupValue: controller.autoDeleteOption.value,
                onChanged: (val) => controller.autoDeleteOption.value = val!,
                title: const Text("Never"),
              ),
              const SizedBox(height: 16),

              // Content customisation
              const Text(
                "Content customisation",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              CheckboxListTile(
                value: controller.textChecked.value,
                onChanged: (v) => controller.textChecked.value = v!,
                title: const Text("Text"),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                value: controller.voiceChecked.value,
                onChanged: (v) => controller.voiceChecked.value = v!,
                title: const Text("Voice"),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                value: controller.mediaChecked.value,
                onChanged: (v) => controller.mediaChecked.value = v!,
                title: const Text("Media (Image, video & GIF)"),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                value: controller.docsChecked.value,
                onChanged: (v) => controller.docsChecked.value = v!,
                title: const Text("Documents"),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                value: controller.attachChecked.value,
                onChanged: (v) => controller.attachChecked.value = v!,
                title: const Text("Attachments"),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const Spacer(),

              // Create Group button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.createGroup(selectedContacts),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          "Create Group",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

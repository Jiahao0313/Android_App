import "dart:io";

import "package:babylon_app/models/event.dart";
import "package:babylon_app/services/event/event_exceptions.dart";
import "package:babylon_app/services/event/event_service.dart";
import "package:babylon_app/views/navigation/custom_app_bar.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

class EventUpdateForm extends StatefulWidget {
  final Event event;

  const EventUpdateForm({super.key, required this.event});

  @override
  State<EventUpdateForm> createState() => _EventUpdateForm();
}

class _EventUpdateForm extends State<EventUpdateForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _descriptionShortController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  XFile? _image;
  String? _eventImgURL;
  final ImagePicker _picker = ImagePicker();
  String? _error = "";

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.event.fullDescription!;
    _descriptionShortController.text = widget.event.shortDescription!;
    _nameController.text = widget.event.title;
    _placeController.text = widget.event.place!;
    _image = null;
    _eventImgURL = widget.event.pictureURL!;
    _selectedTime = TimeOfDay(
        hour: widget.event.date!.hour, minute: widget.event.date!.minute);
    _selectedDate = widget.event.date!;
  }

  // Dispose controllers when the screen is removed
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionShortController.dispose();
    _descriptionController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: "Update ${widget.event.title}"),
        body: SingleChildScrollView(
            child: Container(
          margin: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).colorScheme.background,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black87,
                            blurRadius: 2,
                            offset: Offset(0, 1))
                      ]),
                  child: TextFormField(
                    controller: _nameController,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    decoration: InputDecoration(
                      hintText: "Event Name*",
                      hintStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                  )),
              Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).colorScheme.background,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black87,
                            blurRadius: 2,
                            offset: Offset(0, 1))
                      ]),
                  child: TextFormField(
                    controller: TextEditingController(
                        text: formatDateTime(_selectedDate, _selectedTime)),
                    readOnly: true,
                    onTap: () => _pickDateTime(context),
                    style: Theme.of(context).textTheme.labelLarge,
                  )),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).colorScheme.background,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black87,
                            blurRadius: 2,
                            offset: Offset(0, 1))
                      ]),
                  height: 200,
                  child: _image == null && _eventImgURL == ""
                      ? Icon(Icons.camera_alt,
                          color: Theme.of(context).colorScheme.primary)
                      : _image == null
                          ? Image.network(_eventImgURL!, fit: BoxFit.cover)
                          : Image.file(File(_image!.path), fit: BoxFit.cover),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).colorScheme.background,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black87,
                            blurRadius: 2,
                            offset: Offset(0, 1))
                      ]),
                  child: TextFormField(
                    controller: _placeController,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    decoration: InputDecoration(
                      hintText: "Location",
                      hintStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                  )),
              Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).colorScheme.background,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black87,
                            blurRadius: 2,
                            offset: Offset(0, 1))
                      ]),
                  child: TextFormField(
                    controller: _descriptionShortController,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    decoration: InputDecoration(
                      hintText: "Short Description",
                      hintStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                  )),
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).colorScheme.background,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black87,
                            blurRadius: 2,
                            offset: Offset(0, 1))
                      ]),
                  child: TextFormField(
                    controller: _descriptionController,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    decoration: InputDecoration(
                      hintText: "Full Description",
                      hintStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                  )),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Theme.of(context).colorScheme.error)),
                    child: Text("CANCEL"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        EventException.validateUpdateOrCreateForm(
                            eventName: _nameController.text,
                            selectedDateTime: _selectedDate,
                            selectedTimeOfDay: _selectedTime,
                            place: _placeController.text);
                        await EventService.updateEvent(
                            eventUID: widget.event.eventUID,
                            eventName: _nameController.text,
                            image: _image == null ? null : File(_image!.path),
                            eventTimeStamp: Timestamp.fromDate(DateTime(
                                _selectedDate!.year,
                                _selectedDate!.month,
                                _selectedDate!.day,
                                _selectedTime!.hour,
                                _selectedTime!.minute)),
                            description: _descriptionShortController.text,
                            shortDescription: _descriptionController.text,
                            place: _placeController.text);

                        if (!context.mounted) return;
                        Navigator.pop(context);
                      } catch (e) {
                        if (e is FirebaseAuthException) {
                          setState(() {
                            _error = e.message;
                          });
                        } else {
                          setState(() {
                            _error = e.toString();
                          });
                        }
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Theme.of(context).colorScheme.primary)),
                    child: Text("UPDATE"),
                  ),
                ],
              ),
            ],
          ),
        )));
  }

  // pick image
  Future<void> pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
      });
    }
  }

  // Function to pick date and time
  Future<void> _pickDateTime(final BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (date == null) return;

    if (!context.mounted) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = date;
      _selectedTime = time;
    });
  }

  // Helper method to format date and time into a user-friendly string
  String formatDateTime(final DateTime? date, final TimeOfDay? time) {
    if (date == null || time == null) return "Date & Time*";
    return "${MaterialLocalizations.of(context).formatFullDate(date)} at ${time.format(context)}";
  }
}

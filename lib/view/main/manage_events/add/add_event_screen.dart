import 'dart:io';

import 'package:eventgate_flutter/controller/event.dart';
import 'package:eventgate_flutter/shared/image_picker_widget.dart';
import 'package:eventgate_flutter/utils/app_utils.dart';
import 'package:eventgate_flutter/view/main/manage_events/my_events/my_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _addEventFormKey = GlobalKey<FormState>();

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  final GlobalKey<FormFieldState<String>> _nameFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _tagFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _dateFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _startTimeFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _endTimeFieldKey =
      GlobalKey<FormFieldState<String>>();

  final List<String> _selectedTags = [];
  LatLng? _selectedLocation;
  String? _validationLocation;

  EventController eventController = EventController();
  MapController mapController = MapController();

  List<String> _allTags = [];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  List<File> _selectedImages = [];

  bool _isLoading = false;
  bool _locationFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchTags();
  }

  Future<void> _fetchTags() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final tags = await eventController.getTags(context);
      setState(() {
        _allTags = tags;
      });
    } catch (error) {
      AppUtils.showToast(context, eventController.getError()!, 'error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //body: SingleChildScrollView( with Container
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _addEventFormKey,
                child: ListView(
                  children: [
                    _buildNameField(),
                    const SizedBox(height: 16),
                    _buildTagField(),
                    Wrap(
                      spacing: 8.0,
                      children: _selectedTags
                          .map((tag) => Chip(
                                label: Text(tag),
                                onDeleted: () => _removeTag(tag),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(context),
                    const SizedBox(height: 16),
                    _buildTimeField('Start Time', _startTimeController,
                        () => _pickStartTime(context)),
                    const SizedBox(height: 16),
                    _buildTimeField('End Time', _endTimeController,
                        () => _pickEndTime(context)),
                    const SizedBox(height: 16),
                    _buildMap(context),
                    const SizedBox(height: 16),
                    ImagePickerWidget(
                      images: _selectedImages,
                      onImagesChanged: (newImages) {
                        setState(() {
                          _selectedImages = newImages;
                        });
                      },
                    ),
                    _buildSubmitButton(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        key: _nameFieldKey,
        onChanged: (value) => _nameFieldKey.currentState?.validate(),
        controller: _eventNameController,
        decoration: const InputDecoration(
          labelText: 'Event Name',
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
            value!.isEmpty ? 'Please enter an event name' : null,
      ),
    );
  }

  Widget _buildTagField() {
    return Column(
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            final query = textEditingValue.text.toLowerCase();
            return _allTags
                .where((tag) =>
                    tag.toLowerCase().contains(query) &&
                    !_selectedTags.contains(tag))
                .take(10)
                .toList();
          },
          onSelected: (String selectedTag) {
            setState(() {
              if (!_selectedTags.contains(selectedTag)) {
                _selectedTags.add(selectedTag);
                _tagFieldKey.currentState?.validate();
                _tagFieldKey.currentState?.reset();
                FocusScope.of(context).unfocus();
              }
            });
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController controller,
              FocusNode focusNode,
              VoidCallback onEditingComplete) {
            return TextFormField(
              key: _tagFieldKey,
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Add Tag',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _addTag(controller.text);
                    controller.clear();
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
              onEditingComplete: onEditingComplete,
              validator: (value) {
                if ((value == null || value.isEmpty) && _selectedTags.isEmpty) {
                  return 'Please enter a tag or select one from the list';
                }
                return null;
              },
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        key: _dateFieldKey,
        controller: _dateController,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: const InputDecoration(
          labelText: 'Event Date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        validator: (value) => value!.isEmpty ? 'Please enter a date' : null,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${_selectedDate.toLocal()}'.split(' ')[0];
        _dateFieldKey.currentState?.validate();
      });
    }
  }

  Widget _buildTimeField(String label, TextEditingController controller,
      Future<void> Function() onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        key: label == 'Start Time' ? _startTimeFieldKey : _endTimeFieldKey,
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.access_time),
        ),
        validator: (value) =>
            value!.isEmpty ? 'Please enter a ${label.toLowerCase()}' : null,
      ),
    );
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        //_startTimeController.text = _startTime.format(context);
        _startTimeController.text = _formatTime(_startTime);
        _startTimeFieldKey.currentState?.validate();
      });
    }
  }

  Future<void> _pickEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
        //_endTimeController.text = _endTime.format(context);
        _endTimeController.text = _formatTime(_endTime);
        _endTimeFieldKey.currentState?.validate();
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final formattedTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return "${formattedTime.hour.toString().padLeft(2, '0')}:${formattedTime.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildMap(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Select the location of the event on the map:',
          style: TextStyle(fontSize: 16),
        ),
        if (_validationLocation != null)
          Text(
            _validationLocation!,
            style: const TextStyle(color: Colors.red),
          ),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 300,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: const LatLng(36.77, 10.27),
                  initialZoom: 8.0,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _selectedLocation = point;
                      _validationLocation = null;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.tekup.eventgate_flutter',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(158, 44, 2, 51),
                      ),
                      child: FloatingActionButton(
                        onPressed: () => _getUserLocation(context),
                        elevation: 6,
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        child: !_locationFetching
                            ? const Icon(Icons.my_location)
                            : const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  if (_selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 30.0,
                          height: 30.0,
                          point: _selectedLocation!,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _getUserLocation(BuildContext context) async {
    setState(() {
      _locationFetching = true;
    });

    try {
      PermissionStatus permission =
          await Permission.locationWhenInUse.request();
      if (permission.isGranted) {
        try {
          Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );

          LatLng newLocation = LatLng(position.latitude, position.longitude);
          setState(() {
            _selectedLocation = newLocation;
            _validationLocation = null;
          });

          mapController.move(newLocation, 15);
        } catch (e) {
          AppUtils.showToast(context, 'Could not fetch location', 'error');
        }
      } else {
        AppUtils.showToast(context, 'Location permission denied', 'error');
      }
    } catch (e) {
      AppUtils.showToast(
          context, 'An error occurred while fetching location', 'error');
    } finally {
      setState(() {
        _locationFetching = false;
      });
    }
  }

  Widget _buildSubmitButton(context) {
    return ElevatedButton.icon(
      onPressed: () => _submitForm(context),
      iconAlignment: IconAlignment.start,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.add),
      label: Text(_isLoading ? 'Adding event...' : 'Add event'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 44, 2, 51),
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _submitForm(context) async {
    setState(() {
      if (_selectedLocation == null) {
        _validationLocation = 'Please select a location on the map';
        return;
      } else {
        _validationLocation = null;
        _isLoading = true;
      }
    });
    try {
      if (_addEventFormKey.currentState!.validate()) {
        String locationFormat =
            '${_selectedLocation!.latitude},${_selectedLocation!.longitude}';
        await eventController.addEvent(
          context,
          _eventNameController.text,
          locationFormat,
          _dateController.text,
          _startTimeController.text,
          _endTimeController.text,
          _selectedTags,
          _selectedImages,
        );
        if (eventController.getMessage() != null) {
          AppUtils.showToast(context, eventController.getMessage()!, 'success');
          AppUtils.navigateWithFade(context, const MyEventsScreen());
        }
        if (eventController.getError() != null) {
          AppUtils.showToast(context, eventController.getError()!, 'error');
        }
      }
    } catch (error) {
      AppUtils.showToast(context, eventController.getError()!, 'error');
    } finally {
      setState(() {
        _isLoading = false;
        _eventNameController.clear();
        _dateController.clear();
        _startTimeController.clear();
        _endTimeController.clear();
        _selectedDate = DateTime.now();
        _startTime = TimeOfDay.now();
        _endTime = TimeOfDay.now();
        _selectedTags.clear();
        _selectedLocation = null;
        _selectedImages.clear();
      });
      eventController.setMessage(null);
      eventController.setError(null);
    }
  }
}

import 'package:eventgate_flutter/controller/event.dart';
import 'package:eventgate_flutter/model/event.dart';
import 'package:eventgate_flutter/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EventDetailsScreen extends StatefulWidget {
  final int id;

  const EventDetailsScreen({super.key, required this.id});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetailsScreen> {
  EventController eventController = EventController();
  Event? _event;
  String _placeName = 'Fetching location...';
  bool _isLoading = false;
  final String baseUrl = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    _fetchEvent();
  }

  @override
  void dispose() {
    _event = null;
    _placeName = 'Fetching location...';
    super.dispose();
  }

  Future<void> _fetchEvent() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final data = await eventController.getEvent(context, widget.id);

      if (data['event'] != null) {
        setState(() {
          _event = Event.fromJson(data['event']);
        });
        final coords = _event!.location.split(',');
        final latitude = double.parse(coords[0]);
        final longitude = double.parse(coords[1]);

        final placeName =
            await eventController.getPlaceName(latitude, longitude);
        if (mounted) {
          setState(() {
            _placeName = placeName;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        AppUtils.showToast(context, eventController.getError()!, 'error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _event == null
              ? const Center(child: Text('Event not found'))
              : _buildEventDetails(),
    );
  }

  Widget _buildEventDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildImageCarousel(),
          _buildInfoSection(),
          _buildMapSection(),
          const SizedBox(height: 20),
          _buildJoinButton(),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return CarouselSlider(
      items: _event!.images.isNotEmpty
          ? _event!.images.map((image) {
              return CachedNetworkImage(
                imageUrl: baseUrl + image,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error, color: Colors.red)),
              );
            }).toList()
          : [
              Image.asset(
                'assets/images/thumbnail.png',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ],
      options: CarouselOptions(
        height: 250,
        autoPlay: true,
        enlargeCenterPage: true,
        enableInfiniteScroll: _event!.images.isNotEmpty,
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _event!.eventName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _placeName,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    AppUtils.formatStringDate(_event!.day),
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'From ${_event!.startTime.substring(0, 5)} to ${_event!.endTime.substring(0, 5)}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTags(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    final coords = _event!.location.split(',');
    final latitude = double.parse(coords[0]);
    final longitude = double.parse(coords[1]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: SizedBox(
          height: 250,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(latitude, longitude),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tekup.eventgate_flutter',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 30,
                    height: 30,
                    point: LatLng(latitude, longitude),
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
      ),
    );
  }

  Widget _buildTags() {
    return _event!.tags.isNotEmpty
        ? Wrap(
            spacing: 8,
            children: _event!.tags
                .map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.blue[100],
                    ))
                .toList(),
          )
        : const Text(
            'No tags available',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          );
  }

  Widget _buildJoinButton() {
    return ElevatedButton.icon(
      onPressed: () => _joinEvent(context),
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
      label: Text(_isLoading ? 'Joining event...' : 'Join event'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 44, 2, 51),
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _joinEvent(context) async {
    try {
      setState(() {
        _isLoading = true;
      });

      //await eventController.joinEvent(context, widget.id);
      if (eventController.getMessage() != null) {
        AppUtils.showToast(context, eventController.getMessage()!, 'success');
        //AppUtils.navigateWithFade(context, const ());
      }
      if (eventController.getError() != null) {
        AppUtils.showToast(context, eventController.getError()!, 'error');
      }
    } catch (error) {
      AppUtils.showToast(context, eventController.getError()!, 'error');
    } finally {
      setState(() {
        _isLoading = false;
      });
      eventController.setMessage(null);
      eventController.setError(null);
    }
  }
}

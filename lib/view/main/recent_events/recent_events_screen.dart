import 'package:eventgate_flutter/controller/event.dart';
import 'package:eventgate_flutter/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class RecentEventsScreen extends StatefulWidget {
  const RecentEventsScreen({super.key});

  @override
  State<RecentEventsScreen> createState() => _RecentEventsState();
}

class _RecentEventsState extends State<RecentEventsScreen> {
  final ScrollController _listViewController = ScrollController();
  EventController eventController = EventController();
  List<dynamic> _events = [];
  int _currentPage = 1;
  //int _totalPages = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isFetching = false;

  final String baseUrl = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    _fetchEvents();

    _listViewController.addListener(() {
      if (_listViewController.position.pixels >=
              _listViewController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore &&
          !_isFetching) {
        _fetchEvents();
      }
    });
  }

  @override
  void dispose() {
    _listViewController.dispose();
    _hasMore = true;
    _events = [];
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    if (_isFetching) return;
    setState(() {
      _isFetching = true;
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      final data = await eventController.getRecentEvents(
        context,
        page: _currentPage,
        pageSize: 5,
      );

      if (data.isNotEmpty) {
        setState(() {
          _events.addAll(data['events']);
          _hasMore = _currentPage < data['total_pages'];
          _currentPage++;
        });
      }
    } catch (error) {
      if (mounted) {
        AppUtils.showToast(context, eventController.getError()!, 'error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _events.isEmpty && !_isLoading
          ? const Center(child: Text('No recent events found'))
          : ListView.builder(
              controller: _listViewController,
              itemCount: _events.length + 1,
              itemBuilder: (context, index) {
                if (index == _events.length) {
                  return _isLoading
                      ? _buildShimmerLoading()
                      : const SizedBox.shrink();
                }

                final event = _events[index];
                return _buildEventCard(event);
              },
            ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: CarouselSlider(
              items: event['images'].isNotEmpty
                  ? event['images']
                      .map<Widget>((image) => CachedNetworkImage(
                            imageUrl: baseUrl + image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Center(
                                child: Icon(Icons.error, color: Colors.red)),
                          ))
                      .toList()
                  : [
                      Image.asset(
                        'assets/images/thumbnail.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 180,
                      ),
                    ],
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                enlargeCenterPage: true,
                enableInfiniteScroll: event['images'].isNotEmpty,
              ),
            ),
          ),
          Container(
            color: const Color.fromARGB(255, 245, 245, 245),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['event_name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppUtils.formatStringDate(event['day']),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTimeline(event),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 237, 231, 246),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => {},
                icon: const Icon(Icons.visibility_outlined),
                label: const Text(
                  'View Event',
                  style: TextStyle(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 44, 2, 51),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(Map<String, dynamic> event) {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 18, color: Colors.blue),
        const SizedBox(width: 6),
        Text(
          'Start: ${event['start_time']}',
          style: const TextStyle(fontSize: 12, color: Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.red],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.access_time, size: 18, color: Colors.red),
        const SizedBox(width: 6),
        Text(
          'End: ${event['end_time']}',
          style: const TextStyle(fontSize: 12, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(5, (index) => _buildShimmerCard()),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 180,
                width: double.infinity,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                    width: 150,
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(
                    height: 14,
                    width: 100,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const SizedBox(
                        height: 14,
                        width: 50,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const SizedBox(
                        height: 14,
                        width: 50,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 237, 231, 246),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Center(
                child: SizedBox(
                  height: 45,
                  width: 120,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

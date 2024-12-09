class Event {
  final int id;
  final String eventName;
  final String location;
  final String day;
  final String startTime;
  final String endTime;
  final List<String> images;
  final List<String> tags;

  Event({
    required this.id,
    required this.eventName,
    required this.location,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.images,
    required this.tags,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      eventName: json['event_name'],
      location: json['location'],
      day: json['day'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      images: List<String>.from(json['images']),
      tags: List<String>.from(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_name': eventName,
      'location': location,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'images': images,
      'tags': tags,
    };
  }
}

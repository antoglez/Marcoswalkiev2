import 'dart:convert';

class PTTProfile {
  final String id;
  final String name;
  final String startAction;
  final String stopAction;
  final Map<String, dynamic> extras;

  PTTProfile({
    required this.id,
    required this.name,
    required this.startAction,
    required this.stopAction,
    this.extras = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startAction': startAction,
      'stopAction': stopAction,
      'extras': jsonEncode(extras),
    };
  }

  factory PTTProfile.fromMap(Map<String, dynamic> map) {
    return PTTProfile(
      id: map['id'],
      name: map['name'],
      startAction: map['startAction'],
      stopAction: map['stopAction'],
      extras: map['extras'] != null ? jsonDecode(map['extras']) : {},
    );
  }

  PTTProfile copyWith({
    String? name,
    String? startAction,
    String? stopAction,
    Map<String, dynamic>? extras,
  }) {
    return PTTProfile(
      id: id,
      name: name ?? this.name,
      startAction: startAction ?? this.startAction,
      stopAction: stopAction ?? this.stopAction,
      extras: extras ?? this.extras,
    );
  }
}

import 'dart:convert';

class TrakteerBroadcastNotification {
  final String tipId;
  final String? supporterName;
  final String unit;
  final int quantity;
  final String? supporterMessage;
  final String? supporterAvatar;
  final String? unitIcon;
  final String price;
  final String id;
  final String type;

  TrakteerBroadcastNotification({
    required this.tipId,
    this.supporterName,
    required this.unit,
    required this.quantity,
    this.supporterMessage,
    this.supporterAvatar,
    this.unitIcon,
    required this.price,
    required this.id,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'tip_id': tipId});
    result.addAll({'supporter_name': supporterName});
    result.addAll({'unit': unit});
    result.addAll({'quantity': quantity});
    if (supporterMessage != null) {
      result.addAll({'supporter_message': supporterMessage});
    }
    if (supporterAvatar != null) {
      result.addAll({'supporter_avatar': supporterAvatar});
    }
    if (unitIcon != null) {
      result.addAll({'unit_icon': unitIcon});
    }
    result.addAll({'price': price});
    result.addAll({'id': id});
    result.addAll({'type': type});

    return result;
  }

  factory TrakteerBroadcastNotification.fromMap(Map<String, dynamic> map) {
    return TrakteerBroadcastNotification(
      tipId: map['tip_id'] ?? '',
      supporterName: map['supporter_name'],
      unit: map['unit'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      supporterMessage: map['supporter_message'],
      supporterAvatar: map['supporter_avatar'],
      unitIcon: map['unit_icon'],
      price: map['price'] ?? '',
      id: map['id'] ?? '',
      type: map['type'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TrakteerBroadcastNotification.fromJson(String source) =>
      TrakteerBroadcastNotification.fromMap(json.decode(source));
}

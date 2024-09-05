class SocketModel {
  final int type;
  final double presentLat;
  final double presentLng;
  final double destinationDistance;

  SocketModel({
    required this.type,
    required this.presentLat,
    required this.presentLng,
    required this.destinationDistance,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'presentLat': presentLat,
      'presentLng': presentLng,
      'destinationDistance': destinationDistance,
    };
  }
}

class Boat {
  final String id;
  final String name;
  final String code;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime lastUpdated;
  final String? portName;
  final String? boatType; // Added boat type for different markers

  Boat({
    required this.id,
    required this.name,
    required this.code,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.lastUpdated,
    this.portName,
    this.boatType,
  });

  factory Boat.fromMap(Map<String, dynamic> map) {
    return Boat(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'unknown',
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
      portName: map['portName'],
      boatType: map['boatType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'lastUpdated': lastUpdated.toIso8601String(),
      'portName': portName,
      'boatType': boatType,
    };
  }

  static List<Boat> sampleBoats = [
    // Australia
    Boat(
      id: '1',
      name: 'Perth Pioneer',
      code: 'PP-001',
      latitude: -32.0397,  // Fremantle Port
      longitude: 115.7395,
      status: 'docked',
      lastUpdated: DateTime.now(),
      portName: 'Fremantle Port, Australia',
      boatType: 'cargo',
    ),
    Boat(
      id: '2',
      name: 'Darwin Voyager',
      code: 'DV-002',
      latitude: -12.4634,  // Darwin Port
      longitude: 130.8456,
      status: 'docked',
      lastUpdated: DateTime.now(),
      portName: 'Port of Darwin, Australia',
      boatType: 'tanker',
    ),

    // Madagascar
    Boat(
      id: '3',
      name: 'Toamasina Trader',
      code: 'TT-003',
      latitude: -18.1495,  // Toamasina Port
      longitude: 49.4024,
      status: 'docked',
      lastUpdated: DateTime.now(),
      portName: 'Port of Toamasina, Madagascar',
      boatType: 'container',
    ),
    Boat(
      id: '4',
      name: 'Mahajanga Mariner',
      code: 'MM-004',
      latitude: -15.7167,  // Mahajanga Port
      longitude: 46.3167,
      status: 'docked',
      lastUpdated: DateTime.now(),
      portName: 'Port of Mahajanga, Madagascar',
      boatType: 'fishing',
    ),

    // Active Ships in Indian Ocean
    Boat(
      id: '5',
      name: 'Ocean Explorer',
      code: 'OE-005',
      latitude: -15.9,
      longitude: 75.3,
      status: 'active',
      lastUpdated: DateTime.now(),
      boatType: 'research',
    ),
    Boat(
      id: '6',
      name: 'Indian Voyager',
      code: 'IV-006',
      latitude: -12.5,
      longitude: 80.2,
      status: 'active',
      lastUpdated: DateTime.now(),
      boatType: 'cargo',
    ),

    // Other Ports
    Boat(
      id: '7',
      name: 'Mumbai Merchant',
      code: 'MM-007',
      latitude: 18.9398,  // Mumbai Port
      longitude: 72.8583,
      status: 'docked',
      lastUpdated: DateTime.now(),
      portName: 'Mumbai Port, India',
      boatType: 'container',
    ),
    Boat(
      id: '8',
      name: 'Dubai Deliverance',
      code: 'DD-008',
      latitude: 25.2697,  // Port Rashid
      longitude: 55.2708,
      status: 'docked',
      lastUpdated: DateTime.now(),
      portName: 'Port Rashid, Dubai',
      boatType: 'luxury',
    ),
    Boat(
      id: '9',
      name: 'Singapore Star',
      code: 'SS-009',
      latitude: 1.2655,  // Port of Singapore
      longitude: 103.8240,
      status: 'docked',
      lastUpdated: DateTime.now(),
      portName: 'Port of Singapore',
      boatType: 'tanker',
    ),
    Boat(
      id: '10',
      name: 'Colombo Carrier',
      code: 'CC-010',
      latitude: 6.9417,  // Port of Colombo
      longitude: 79.8425,
      status: 'docked',
      lastUpdated: DateTime.now(),
      portName: 'Port of Colombo, Sri Lanka',
      boatType: 'cargo',
    ),
    Boat(
      id: '11',
      name: 'Mombasa Master',
      code: 'MM-011',
      latitude: -4.0435,  // Port of Mombasa
      longitude: 39.6682,
      status: 'docked',
      lastUpdated: DateTime.now(),
      portName: 'Port of Mombasa, Kenya',
      boatType: 'container',
    ),
    Boat(
      id: '12',
      name: 'Cape Town Cruiser',
      code: 'CT-012',
      latitude: -33.9062,  // Port of Cape Town
      longitude: 18.4355,
      status: 'docked',
      lastUpdated: DateTime.now(),
      portName: 'Port of Cape Town, South Africa',
      boatType: 'passenger',
    ),
  ];
}

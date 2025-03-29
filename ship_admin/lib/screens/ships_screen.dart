import 'package:flutter/material.dart';
import '../models/boat.dart';
import '../widgets/ship_details_card.dart';

// Define a callback type for showing a boat on the map
typedef ShowBoatCallback = void Function(Boat boat);

class ShipsScreen extends StatefulWidget {
  final List<Boat> boats;
  final ShowBoatCallback? onShowBoat;
  
  const ShipsScreen({
    Key? key, 
    required this.boats,
    this.onShowBoat,
  }) : super(key: key);

  @override
  State<ShipsScreen> createState() => _ShipsScreenState();
}

class _ShipsScreenState extends State<ShipsScreen> {
  String _searchQuery = '';
  Set<String> _selectedTypes = {};
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ship Fleet'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _buildShipList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search ships by name, code, or port',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final boatTypes = [
      {'emoji': '📦', 'type': 'cargo'},
      {'emoji': '🏭', 'type': 'container'},
      {'emoji': '⛽', 'type': 'tanker'},
      {'emoji': '🚢', 'type': 'passenger'},
      {'emoji': '🎣', 'type': 'fishing'},
      {'emoji': '🛥️', 'type': 'luxury'},
      {'emoji': '🔬', 'type': 'research'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: boatTypes.map((type) {
          final isSelected = _selectedTypes.contains(type['type']);
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Text(type['emoji']!),
              label: Text(type['type']!.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTypes.add(type['type']!);
                  } else {
                    _selectedTypes.remove(type['type']!);
                  }
                });
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue.shade900,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShipList() {
    final filteredBoats = _filterBoats();
    
    if (filteredBoats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No ships match your search',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredBoats.length,
      itemBuilder: (context, index) {
        final boat = filteredBoats[index];
        return ShipDetailsCard(
          boat: boat,
          onShowOnMap: () {
            widget.onShowBoat?.call(boat);
          },
        );
      },
    );
  }

  List<Boat> _filterBoats() {
    return widget.boats.where((boat) {
      final matchesSearch = boat.name.toLowerCase().contains(_searchQuery) ||
          boat.code.toLowerCase().contains(_searchQuery) ||
          (boat.portName?.toLowerCase() ?? '').contains(_searchQuery);

      final matchesType = _selectedTypes.isEmpty ||
          _selectedTypes.contains(boat.boatType?.toLowerCase() ?? 'unknown');

      return matchesSearch && matchesType;
    }).toList();
  }
}

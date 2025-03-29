import 'package:flutter/material.dart';
import '../models/boat.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Boat> boats;

  const StatisticsScreen({Key? key, required this.boats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fleet Statistics'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            SizedBox(height: 24),
            _buildShipTypeDistribution(),
            SizedBox(height: 24),
            _buildPortDistribution(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final activeBoats = boats.where((b) => b.status == 'active').length;
    final dockedBoats = boats.where((b) => b.status == 'docked').length;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Ships',
          boats.length.toString(),
          Icons.directions_boat,
          Colors.blue.shade900,
        ),
        _buildStatCard(
          'Active Ships',
          activeBoats.toString(),
          Icons.local_shipping,
          Colors.green.shade700,
        ),
        _buildStatCard(
          'Docked Ships',
          dockedBoats.toString(),
          Icons.anchor,
          Colors.orange.shade700,
        ),
        _buildStatCard(
          'Ports',
          boats.where((b) => b.portName != null).map((b) => b.portName).toSet().length.toString(),
          Icons.location_on,
          Colors.purple.shade700,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShipTypeDistribution() {
    // Count boats by type
    final typeCount = <String, int>{};
    for (var boat in boats) {
      final type = boat.boatType ?? 'Other';
      typeCount[type] = (typeCount[type] ?? 0) + 1;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ship Types Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...typeCount.entries.map((entry) {
              final percentage = (entry.value / boats.length * 100).toStringAsFixed(1);
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${entry.key}: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${entry.value} ships (${percentage}%)'),
                      ],
                    ),
                    SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / boats.length,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getColorForBoatType(entry.key),
                      ),
                      minHeight: 8,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPortDistribution() {
    // Count boats by port
    final portCount = <String, int>{};
    for (var boat in boats) {
      if (boat.portName != null) {
        portCount[boat.portName!] = (portCount[boat.portName!] ?? 0) + 1;
      }
    }

    final totalDockedBoats = portCount.values.fold(0, (sum, count) => sum + count);

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ships per Port',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...portCount.entries.map((entry) {
              final percentage = totalDockedBoats > 0 
                ? (entry.value / totalDockedBoats * 100).toStringAsFixed(1)
                : '0.0';
                
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${entry.key}: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${entry.value} ships (${percentage}%)'),
                      ],
                    ),
                    SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: totalDockedBoats > 0 ? entry.value / totalDockedBoats : 0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.primaries[portCount.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                      ),
                      minHeight: 8,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getColorForBoatType(String boatType) {
    switch (boatType.toLowerCase()) {
      case 'cargo':
        return Colors.blue;
      case 'container':
        return Colors.orange;
      case 'tanker':
        return Colors.red;
      case 'passenger':
        return Colors.purple;
      case 'fishing':
        return Colors.cyan;
      case 'luxury':
        return Colors.pink;
      case 'research':
        return Colors.yellow.shade800;
      default:
        return Colors.blue.shade200;
    }
  }
}

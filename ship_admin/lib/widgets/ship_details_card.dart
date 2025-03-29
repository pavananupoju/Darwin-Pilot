import 'package:flutter/material.dart';
import '../models/boat.dart';

class ShipDetailsCard extends StatelessWidget {
  final Boat boat;
  final VoidCallback? onShowOnMap;

  const ShipDetailsCard({
    Key? key,
    required this.boat,
    this.onShowOnMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: boat.status == 'active' ? Colors.green : Colors.blue,
          child: Text(boat.name[0]),
        ),
        title: Text(boat.name),
        subtitle: Text(boat.code),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Status', boat.status.toUpperCase()),
                _buildInfoRow('Type', boat.boatType?.toUpperCase() ?? 'N/A'),
                if (boat.portName != null)
                  _buildInfoRow('Port', boat.portName!),
                _buildInfoRow('Location', '${boat.latitude.toStringAsFixed(4)}, ${boat.longitude.toStringAsFixed(4)}'),
                _buildInfoRow('Last Updated', _formatDateTime(boat.lastUpdated)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onShowOnMap != null)
                      ElevatedButton.icon(
                        onPressed: onShowOnMap,
                        icon: Icon(Icons.map),
                        label: Text('Show on Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

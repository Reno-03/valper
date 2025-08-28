import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ParkingScreen extends StatelessWidget {
  const ParkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Parking Slot - Samar, PH')),
        body: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(11.7756, 124.8862), // Coordinates for Catbalogan City, Samar
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.valper',
            ),
            const MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(11.7756, 124.8862),
                  width: 40,
                  height: 40,
                  child: Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
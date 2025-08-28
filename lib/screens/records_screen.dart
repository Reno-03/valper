import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    // You might want to handle cases where the user is not logged in more gracefully
    // For now, let's assume supabase.auth.currentUser is not null in typical usage.
    final user = supabase.auth.currentUser;
    if (user == null) {
      // Handle not logged in case, e.g., navigate to login, show an error.
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final profileResponse = await supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .single();

      final username = profileResponse['username'];

      final data = await supabase
          .from('license_verify')
          .select()
          .eq('name', username)
          .order('created_at', ascending: false);

      setState(() {
        _records = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching records: $e');
      setState(() {
        _isLoading = false;
        // Optionally, show an error message to the user
      });
    }
  }

  Widget _buildRecordTile(Map<String, dynamic> record) {
    final date = DateTime.parse(record['created_at']);
    final formattedDate = DateFormat('MM/dd/yyyy h:mm a').format(date);

    // Assuming 'direction' and 'face_recognized' (or similar) fields exist in your Supabase table
    // If not, you'll need to adjust your Supabase table schema or default these values.
    final direction = record['direction'] ?? 'IN'; // Default to 'IN' if not present
    final faceRecognized = record['name'] ?? 'N/A'; // Use 'name' from your fetch logic

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF004A8F), // Matching the blue from your app bar
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Direction
            Expanded(
              flex: 2,
              child: Text(
                direction,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            // Timestamp
            Expanded(
              flex: 4,
              child: Text(
                formattedDate,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center, // Center align timestamp
              ),
            ),
            // Face Recognized
            Expanded(
              flex: 3,
              child: Text(
                faceRecognized,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.right, // Right align face recognized
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Image.asset('assets/valper_logo.png', height: 60),
                        const SizedBox(height: 10),
                        Text(
                          'Records',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF004A8F), // Match app bar color
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Header Row for the records
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0), // Adjust padding to match tiles
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Direction',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Timestamp',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Face Recognized',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8), // Space between header and first record
                    Expanded(
                      child: _records.isEmpty
                          ? Center(
                              child: Text(
                                'No records found.',
                                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _records.length,
                              itemBuilder: (context, index) {
                                return _buildRecordTile(_records[index]);
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
      // Remove the BottomNavigationBar from RecordsScreen
      // because it's handled by the HomeScreen's Scaffold.
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 1, // Assuming Records is the second tab (index 1)
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Records'),
      //     BottomNavigationBarItem(icon: Icon(Icons.local_parking), label: 'Parking Slot'),
      //     BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
      //   ],
      //   onTap: (index) {
      //     // This onTap should ideally trigger the HomeScreen's _currentIndex update.
      //     // For now, it's commented out as HomeScreen manages navigation.
      //   },
      // ),
    );
  }
}
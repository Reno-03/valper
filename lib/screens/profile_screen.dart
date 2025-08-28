import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentUser = Supabase.instance.client.auth.currentUser;
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    if (_currentUser == null) {
      setState(() {
        _errorMessage = 'User not logged in.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('user_details')
          .select()
          .eq('id', _currentUser!.id)
          .single();

      setState(() {
        _userDetails = response;
        _isLoading = false;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _errorMessage = 'Error fetching user details: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        // Navigate to login or initial screen after logout
        Navigator.of(context).pushReplacementNamed('/login'); // Assuming you have a login route
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF004A8F),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _userDetails == null
                  ? Center(
                      child: Text(
                        'No user details found.',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24.0),
                            color: Colors.blue[800], // Darker blue for the header
                            child: Column(
                              children: [
                                const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Color(0xFF004A8F),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _userDetails!['full_name'] ?? 'N/A',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                    'VID', _currentUser?.id.substring(0, 8) ?? 'N/A'), // Shorten UID for display
                                _buildDetailRow(
                                    'ROLE',
                                    (_userDetails!['is_student'] ?? false)
                                        ? 'Student'
                                        : 'Faculty'),
                              ],
                            ),
                          ),
                          Container(
                            color: Colors.white, // White background for the body
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                _buildInfoCard(
                                  label: 'Full Name',
                                  value: _userDetails!['full_name'] ?? 'N/A',
                                  icon: Icons.person_outline,
                                ),
                                _buildInfoCard(
                                  label: 'Email',
                                  value: _userDetails!['email'] ?? 'N/A',
                                  icon: Icons.email_outlined,
                                ),
                                _buildInfoCard(
                                  label: 'Contact',
                                  value: _userDetails!['contact'] ?? 'N/A',
                                  icon: Icons.phone_outlined,
                                ),
                                _buildInfoCard(
                                  label: 'Birthday',
                                  value: _userDetails!['birthday'] != null
                                      ? DateTime.parse(_userDetails!['birthday']).toLocal().toString().split(' ')[0]
                                      : 'N/A',
                                  icon: Icons.calendar_today_outlined,
                                ),
                                _buildInfoCard(
                                  label: 'SSU ID',
                                  value: _userDetails!['ssu_id'] ?? 'N/A',
                                  icon: Icons.credit_card_outlined,
                                ),
                                _buildInfoCard(
                                  label: 'College',
                                  value: _userDetails!['college'] ?? 'N/A',
                                  icon: Icons.school_outlined,
                                ),
                                if (!(_userDetails!['is_student'] ?? true)) // Show designation only for faculty
                                  _buildInfoCard(
                                    label: 'Designation',
                                    value: _userDetails!['designation'] ?? 'N/A',
                                    icon: Icons.work_outline,
                                  ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // TODO: Implement "Rate the App" functionality
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Rate the App pressed!')),
                                    );
                                  },
                                  icon: const Icon(Icons.thumb_up_alt_outlined, color: Color(0xFF004A8F)),
                                  label: Text(
                                    'Rate the App',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: const Color(0xFF004A8F),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF004A8F),
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(11.5),
                                      side: const BorderSide(color: Color(0xFF004A8F), width: 2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _signOut,
                                  icon: const Icon(Icons.logout, color: Colors.white),
                                  label: Text(
                                    'Logout',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDC3545), // Red for logout
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(11.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String label, required String value, required IconData icon}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF004A8F)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
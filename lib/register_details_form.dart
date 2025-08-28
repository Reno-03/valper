import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterDetailsForm extends StatefulWidget {
  final bool isStudent;

  const RegisterDetailsForm({super.key, required this.isStudent});

  @override
  State<RegisterDetailsForm> createState() => _RegisterDetailsFormState();
}

class _RegisterDetailsFormState extends State<RegisterDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _ssuIdController = TextEditingController();

  String? _selectedCollege;
  String? _selectedDesignation;

  final List<String> colleges = [
    'College of Graduate Studies',
    'College of Engineering',
    'College of Nursing and Health Sciences',
    'College of Education',
    'College of Arts and Sciences',
    'College of Industrial Technology and Architecture',
    'Laboratory School (Secondary Department)',
    'University Administration',
  ];

  final List<String> facultyDesignations = [
    'Instructor I',
    'Instructor II',
    'Instructor III',
    'Assistant Professor I',
    'Assistant Professor II',
    'Assistant Professor III',
    'Associate Professor I',
    'Associate Professor II',
    'Professor I',
    'Professor II',
    'Professor III',
    'Department Chair',
    'Dean',
    'University Administrator',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _ssuIdController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final isStudent = widget.isStudent;

    final data = {
      'id': user.id,
      'full_name': _fullNameController.text.trim(),
      'contact': _contactController.text.trim(),
      'email': _emailController.text.trim(),
      'is_student': isStudent,
      'birthday': isStudent ? _birthdayController.text.trim() : null,
      'ssu_id': isStudent ? _ssuIdController.text.trim() : null,
      'college': _selectedCollege,
      'designation': isStudent ? null : _selectedDesignation,
    };

    try {
      await supabase.from('user_details').upsert(data).select();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details saved successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.isStudent;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isStudent ? 'Student Registration' : 'Faculty Registration',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/valper_logo.png',
                  height: 200,
                ),
              ),
              const SizedBox(height: 24),

              _buildTextField(_fullNameController, 'Full Name'),
              const SizedBox(height: 16),

              if (isStudent) ...[
                _buildDateField(_birthdayController, 'Date of Birth'),
                const SizedBox(height: 16),
                _buildTextField(_ssuIdController, 'Student ID Number'),
                const SizedBox(height: 16),
                _buildTextField(_contactController, 'Mobile Number'),
                const SizedBox(height: 16),
                _buildEmailField(_emailController, 'Institutional Email Address'),
                const SizedBox(height: 16),
                _buildCollegeDropdown(),
              ] else ...[
                _buildTextField(_contactController, 'Mobile Number'),
                const SizedBox(height: 16),
                _buildEmailField(_emailController, 'Institutional Email Address'),
                const SizedBox(height: 16),
                _buildCollegeDropdown(),
                const SizedBox(height: 16),
                _buildDesignationDropdown(),
              ],

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'Submit',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        border: const OutlineInputBorder(),
      ),
      style: GoogleFonts.poppins(),
      validator: (value) =>
          value == null || value.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildEmailField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        border: const OutlineInputBorder(),
      ),
      style: GoogleFonts.poppins(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        } else if (!value.trim().toLowerCase().endsWith('@ssu.edu.ph')) {
          return 'Email must be an institutional address (@ssu.edu.ph)';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      style: GoogleFonts.poppins(),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          final formattedDate = "${pickedDate.month.toString().padLeft(2, '0')}/"
              "${pickedDate.day.toString().padLeft(2, '0')}/"
              "${pickedDate.year}";
          setState(() {
            controller.text = formattedDate;
          });
        }
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select a date' : null,
    );
  }

  Widget _buildCollegeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCollege,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Select College',
        labelStyle: GoogleFonts.poppins(),
        border: const OutlineInputBorder(),
      ),
      items: colleges.map((college) {
        return DropdownMenuItem<String>(
          value: college,
          child: Text(
            college,
            style: GoogleFonts.poppins(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCollege = value;
        });
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select a college' : null,
    );
  }

  Widget _buildDesignationDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDesignation,
      decoration: InputDecoration(
        labelText: 'Designation / Position',
        labelStyle: GoogleFonts.poppins(),
        border: const OutlineInputBorder(),
      ),
      items: facultyDesignations.map((position) {
        return DropdownMenuItem<String>(
          value: position,
          child: Text(position, style: GoogleFonts.poppins()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDesignation = value;
        });
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select a designation' : null,
    );
  }
}
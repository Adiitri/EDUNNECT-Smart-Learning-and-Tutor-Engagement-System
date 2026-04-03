import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../services/user_session.dart';
import '../student/student_dashboard.dart';
import '../tutor/tutor_dashboard.dart';
import '../admin/admin_dashboard.dart';
import 'pick_location_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  final bool isNewUser; // Helps us decide where to navigate after saving

  const CompleteProfileScreen({super.key, this.isNewUser = false});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _phoneController = TextEditingController();

  // Multiple location fields for detailed address input
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  // Dropdown values
  String? _selectedState;
  String? _selectedCountry;

  // Valid dropdown options
  final List<String> _countries = [
    'India', 'United States', 'United Kingdom', 'Canada', 'Australia',
    'Germany', 'France', 'Japan', 'South Korea', 'Singapore'
  ];

  final Map<String, List<String>> _statesByCountry = {
    'India': [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
      'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
      'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
      'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
      'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
      'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Delhi'
    ],
    'United States': [
      'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
      'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
      'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa',
      'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland',
      'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri',
      'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
      'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio',
      'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina',
      'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont',
      'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
    ],
    'United Kingdom': [
      'England', 'Scotland', 'Wales', 'Northern Ireland'
    ],
    'Canada': [
      'Alberta', 'British Columbia', 'Manitoba', 'New Brunswick',
      'Newfoundland and Labrador', 'Northwest Territories', 'Nova Scotia',
      'Nunavut', 'Ontario', 'Prince Edward Island', 'Quebec', 'Saskatchewan',
      'Yukon'
    ],
    'Australia': [
      'Australian Capital Territory', 'New South Wales', 'Northern Territory',
      'Queensland', 'South Australia', 'Tasmania', 'Victoria', 'Western Australia'
    ],
    'Germany': [
      'Baden-Württemberg', 'Bavaria', 'Berlin', 'Brandenburg', 'Bremen',
      'Hamburg', 'Hesse', 'Lower Saxony', 'Mecklenburg-Vorpommern',
      'North Rhine-Westphalia', 'Rhineland-Palatinate', 'Saarland',
      'Saxony', 'Saxony-Anhalt', 'Schleswig-Holstein', 'Thuringia'
    ],
    'France': [
      'Auvergne-Rhône-Alpes', 'Bourgogne-Franche-Comté', 'Brittany', 'Centre-Val de Loire',
      'Corsica', 'Grand Est', 'Hauts-de-France', 'Île-de-France', 'Normandy',
      'Nouvelle-Aquitaine', 'Occitanie', 'Pays de la Loire', 'Provence-Alpes-Côte d\'Azur'
    ],
    'Japan': [
      'Hokkaido', 'Aomori', 'Iwate', 'Miyagi', 'Akita', 'Yamagata', 'Fukushima',
      'Ibaraki', 'Tochigi', 'Gunma', 'Saitama', 'Chiba', 'Tokyo', 'Kanagawa',
      'Niigata', 'Toyama', 'Ishikawa', 'Fukui', 'Yamanashi', 'Nagano',
      'Gifu', 'Shizuoka', 'Aichi', 'Mie', 'Shiga', 'Kyoto', 'Osaka',
      'Hyogo', 'Nara', 'Wakayama', 'Tottori', 'Shimane', 'Okayama',
      'Hiroshima', 'Yamaguchi', 'Tokushima', 'Kagawa', 'Ehime', 'Kochi',
      'Fukuoka', 'Saga', 'Nagasaki', 'Kumamoto', 'Oita', 'Miyazaki', 'Kagoshima', 'Okinawa'
    ],
    'South Korea': [
      'Seoul', 'Busan', 'Daegu', 'Incheon', 'Gwangju', 'Daejeon', 'Ulsan',
      'Sejong', 'Gyeonggi', 'Gangwon', 'Chungbuk', 'Chungnam', 'Jeonbuk',
      'Jeonnam', 'Gyeongbuk', 'Gyeongnam', 'Jeju'
    ],
    'Singapore': [
      'Singapore'
    ]
  };

  double? _latitude; // to store selected coordinates
  double? _longitude;
  bool _isPincodeValid = true;

  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _classController =
      TextEditingController(); // For Students
  final TextEditingController _expertiseController =
      TextEditingController(); // For Tutors

  Future<String?> _reverseGeocode(LatLng position) async {
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&addressdetails=1');
      final response = await http.get(uri, headers: {
        'User-Agent': 'EdunnectApp/1.0',
        'Accept-Language': 'en'
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['address'] != null) {
          final address = data['address'];

          // Extract components from structured address
          final street = [
            address['house_number'],
            address['road'],
            address['suburb'],
            address['neighbourhood']
          ].where((s) => s != null && s.toString().isNotEmpty).join(' ').trim();

          final city = address['city'] ?? address['town'] ?? address['village'] ?? address['municipality'] ?? '';
          final state = address['state'] ?? address['province'] ?? address['region'] ?? '';
          final country = address['country'] ?? '';
          final postcode = address['postcode'] ?? '';

          // Update the fields directly
          setState(() {
            _streetController.text = street;
            _cityController.text = city;
            _selectedCountry = _countries.contains(country) ? country : null;
            // Ensure selected state only if it matches current country options
            if (_selectedCountry != null &&
                _statesByCountry[_selectedCountry]?.contains(state) == true) {
              _selectedState = state;
            } else {
              _selectedState = null;
            }
            _pincodeController.text = postcode;
          });

          return data['display_name'];
        }
      }
    } catch (e) {
      // Ignore -- fallback to lat/lng text
    }
    return null;
  }

  Future<bool> _geocodeLocationText() async {
    // Build primary query from multiple fields
    final street = _streetController.text.trim();
    final city = _cityController.text.trim();
    final state = _selectedState ?? '';
    final country = _selectedCountry ?? '';
    final pincode = _pincodeController.text.trim();

    final candidates = <String>[];
    final fullAddress = [street, city, state, country, pincode]
        .where((part) => part.isNotEmpty)
        .join(', ');
    if (fullAddress.isNotEmpty) candidates.add(fullAddress);

    // Add fallbacks in decreasing specificity
    if (pincode.isNotEmpty) candidates.add(pincode);
    if (city.isNotEmpty && country.isNotEmpty) candidates.add('$city, $country');
    if (street.isNotEmpty && city.isNotEmpty && country.isNotEmpty) {
      candidates.add('$street, $city, $country');
    }
    if (city.isNotEmpty && state.isNotEmpty && country.isNotEmpty) {
      candidates.add('$city, $state, $country');
    }

    for (final query in candidates) {
      try {
        final uri = Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&limit=1&q=${Uri.encodeComponent(query)}');
        final response = await http.get(uri, headers: {
          'User-Agent': 'EdunnectApp/1.0',
          'Accept-Language': 'en'
        });

        if (response.statusCode == 200) {
          final results = jsonDecode(response.body);
          if (results is List && results.isNotEmpty) {
            final item = results[0];
            final lat = double.tryParse(item['lat']?.toString() ?? '');
            final lon = double.tryParse(item['lon']?.toString() ?? '');
            if (lat != null && lon != null) {
              _latitude = lat;
              _longitude = lon;
              return true;
            }
          }
        }
      } catch (e) {
        // ignore a single query failure, try next fallback
      }
    }

    return false;
  }

  bool _isLoading = false;
  late String _userRole;
  late String _userId;

  @override
  void initState() {
    super.initState();
    // Pre-fill data if it exists in the session
    final user = UserSession.currentUser;
    _userId = user?['_id'] ?? '';
    _userRole = user?['role'] ?? 'student';

    _phoneController.text = user?['phone'] ?? '';

    // For backward compatibility, if location is a single string, put it in city field
    final locationText = user?['location'] ?? '';
    if (locationText.isNotEmpty && !locationText.contains(',')) {
      // Simple case: just city name
      _cityController.text = locationText;
    } else if (locationText.contains(',')) {
      // Try to parse comma-separated address
      final parts = locationText.split(',').map((s) => s.trim()).toList();
      if (parts.length >= 1) _streetController.text = parts[0];
      if (parts.length >= 2) _cityController.text = parts[1];
      if (parts.length >= 3) _selectedState = parts[2];
      if (parts.length >= 4) _selectedCountry = parts[3];
      if (parts.length >= 5) _pincodeController.text = parts[4];
    }

    // prefill lat/lng if available
    _latitude = user?['latitude'];
    _longitude = user?['longitude'];
    _aboutController.text = user?['about'] ?? '';
    _expertiseController.text = user?['expertise'] ?? '';
    _classController.text = user?['classGrade'] ?? '';
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    // Validate pincode before proceeding
    if (_pincodeController.text.isNotEmpty && !_isPincodeValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Pincode must be exactly 6 digits."),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }

    // Check if any location fields are filled
    final hasLocationInput = [
      _streetController.text.trim(),
      _cityController.text.trim(),
      _selectedState ?? '',
      _selectedCountry ?? '',
      _pincodeController.text.trim(),
    ].any((field) => field.isNotEmpty);

    // If the user provided location details, geocode them each time so manual updates overwrite old coordinates.
    if (hasLocationInput) {
      final geocoded = await _geocodeLocationText();
      if (!geocoded && (_latitude == null || _longitude == null)) {
        // If coordinates are not available, show warning; otherwise keep existing map coordinates.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Location not found by address search. Please verify your address details or use map picker."),
            backgroundColor: Colors.orange,
          ));
        }
      }
    }

    // Build full location string from fields
    final locationParts = [
      _streetController.text.trim(),
      _cityController.text.trim(),
      _selectedState ?? '',
      _selectedCountry ?? '',
      _pincodeController.text.trim(),
    ].where((part) => part.isNotEmpty);
    final fullLocation = locationParts.join(', ');

    // Validate pincode if provided
    if (_pincodeController.text.isNotEmpty && !RegExp(r'^\d{6}$').hasMatch(_pincodeController.text)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pincode must be exactly 6 digits"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(
          "http://127.0.0.1:5000/api/auth/update",
        ), // Adjust route as needed
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": _userId,
          "phone": _phoneController.text,
          "location": fullLocation,
          "about": _aboutController.text, // Used for 'Subjects of Interest'
          "classGrade": _classController.text,
          "expertise": _expertiseController.text,
          "latitude": _latitude,
          "longitude": _longitude,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        // Update local session data
        final updatedData = jsonDecode(response.body)['user'];
        UserSession.setUser(updatedData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile Saved!"),
              backgroundColor: Colors.green,
            ),
          );

          // If they just registered, take them to their dashboard
          if (widget.isNewUser) {
            if (_userRole == 'student') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const StudentDashboard()),
              );
            } else if (_userRole == 'tutor') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TutorDashboard()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboard()),
              );
            }
          } else {
            // If they opened this from the dashboard, just go back
            Navigator.pop(context);
          }
        }
      } else {
        throw Exception("Failed to update profile");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error saving profile."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.isNewUser ? "Complete Your Profile" : "Edit Profile",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF4A00E0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tell us a bit about yourself",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This helps us personalize your experience.",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            _buildTextField(
              "Phone Number",
              Icons.phone_rounded,
              _phoneController,
            ),
            const SizedBox(height: 16),

            // Multiple location fields for detailed address input
            Text(
              "Location Details",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter your address details. We'll automatically find the coordinates.",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              "Street Address",
              Icons.home_rounded,
              _streetController,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    "City",
                    Icons.location_city_rounded,
                    _cityController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownField(
                    "State/Province",
                    Icons.map_rounded,
                    _selectedState,
                    _selectedCountry != null ? _statesByCountry[_selectedCountry] ?? [] : [],
                    (value) {
                      setState(() {
                        _selectedState = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    "Country",
                    Icons.flag_rounded,
                    _selectedCountry,
                    _countries,
                    (value) {
                      setState(() {
                        _selectedCountry = value;
                        _selectedState = null; // Reset state when country changes
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPincodeField(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Map picker button (alternative to typing address)
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final coords = await Navigator.push<LatLng>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PickLocationScreen()),
                  );
                  if (coords != null) {
                    _latitude = coords.latitude;
                    _longitude = coords.longitude;

                    await _reverseGeocode(coords);
                    // Note: _reverseGeocode now updates the fields directly via setState
                  }
                },
                icon: const Icon(Icons.map),
                label: const Text("Pick Location on Map"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // DYNAMIC FIELD: Only show Class if Student
            if (_userRole == 'student') ...[
              _buildTextField(
                "Class / Grade (e.g. 10th, College)",
                Icons.school_rounded,
                _classController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Subjects of Interest",
                Icons.menu_book_rounded,
                _aboutController,
                maxLines: 3,
              ),
            ],

            // DYNAMIC FIELD: Only show Expertise if Tutor
            if (_userRole == 'tutor') ...[
              _buildTextField(
                "Your Expertise (e.g. Math, Python)",
                Icons.workspace_premium_rounded,
                _expertiseController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Bio / About You",
                Icons.person_outline_rounded,
                _aboutController,
                maxLines: 3,
              ),
            ],

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (_isLoading || !_isPincodeValid) ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.isNewUser
                            ? "Save & Go to Dashboard"
                            : "Save Changes",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            // Skip button for new users
            if (widget.isNewUser) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    if (_userRole == 'student') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentDashboard(),
                        ),
                      );
                    } else if (_userRole == 'tutor') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TutorDashboard(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Skip for now",
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            bottom: maxLines > 1 ? 45.0 : 0,
          ), // Align icon to top if multi-line
          child: Icon(icon, color: Colors.deepPurpleAccent),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    IconData icon,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    final safeValue = (value != null && items.contains(value)) ? value : null;
    return DropdownButtonFormField<String>(
      initialValue: safeValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Icon(icon, color: Colors.deepPurpleAccent),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      hint: Text("Select $label"),
    );
  }

  Widget _buildPincodeField() {
    return TextField(
      controller: _pincodeController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: "Pincode/Zip (6 digits)",
        counterText: "",
        errorText: !_isPincodeValid ? "Pincode must be exactly 6 digits" : null,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Icon(Icons.pin_drop_rounded, color: Colors.deepPurpleAccent),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _isPincodeValid = value.isEmpty || RegExp(r'^\d{6}$').hasMatch(value);
        });
      },
    );
  }
}

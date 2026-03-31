import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:feast/core/constants/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordVisible = false;
  bool _agreedToTerms = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedLocation;
  String? _selectedGender;

  final List<String> _locations = ['Almanza Dos, Las Piñas City'];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2A7A38),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2A7A38);
    const lightYellow = Color(0xFFFFF7BE);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: lightYellow),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // ─── Login / Register Toggle ───
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Login (inactive)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                          child: Container(
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Register (active)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─── First Name ───
                _buildTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                  hintText: 'Juan',
                  prefixIcon: Icons.person_outline,
                  showClear: true,
                ),
                const SizedBox(height: 16),

                // ─── Middle Name (If Applicable) ───
                _buildTextField(
                  label: 'Middle Name (If Applicable)',
                  controller: _middleNameController,
                  hintText: 'Santos',
                  prefixIcon: Icons.person_outline,
                  showClear: true,
                ),
                const SizedBox(height: 16),

                // ─── Last Name ───
                _buildTextField(
                  label: 'Last Name',
                  controller: _lastNameController,
                  hintText: 'De La Cruz',
                  prefixIcon: Icons.person_outline,
                  showClear: true,
                ),
                const SizedBox(height: 16),

                // ─── Location (Dropdown) ───
                _buildDropdownField(
                  label: 'Location',
                  value: _selectedLocation,
                  hintText: 'Almanza Dos, Las Piñas City',
                  prefixIcon: Icons.location_on_outlined,
                  items: _locations,
                  onChanged: (val) {
                    setState(() => _selectedLocation = val);
                  },
                ),
                const SizedBox(height: 16),

                // ─── Contact Number ───
                _buildTextField(
                  label: 'Contact Number',
                  controller: _contactController,
                  hintText: '+63 XXX XXX XXXX',
                  prefixIcon: Icons.phone_outlined,
                  showClear: true,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // ─── Gender (Dropdown) ───
                _buildDropdownField(
                  label: 'Gender',
                  value: _selectedGender,
                  hintText: '-- Select --',
                  prefixIcon: Icons.favorite_border,
                  items: _genders,
                  onChanged: (val) {
                    setState(() => _selectedGender = val);
                  },
                ),
                const SizedBox(height: 16),

                // ─── Date of Birth ───
                _buildDateField(
                  label: 'Date of Birth',
                  controller: _dobController,
                  hintText: 'MM/DD/YYYY',
                ),
                const SizedBox(height: 16),

                // ─── Email ───
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  hintText: 'name@email.com',
                  prefixIcon: Icons.mail_outline,
                  showClear: true,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // ─── Password ───
                _buildPasswordField(
                  label: 'Password',
                  controller: _passwordController,
                  hintText: '*********',
                ),
                const SizedBox(height: 20),

                // ─── Terms & Conditions ───
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        activeColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: "I've read the ",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: 'terms and conditions',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Open terms and conditions
                                },
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ─── Sign In Button ───
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Perform registration
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Reusable text field builder ───
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool showClear = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ' $label',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: Icon(prefixIcon, color: Colors.black54),
              suffixIcon: showClear
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black54,
                        size: 20,
                      ),
                      onPressed: () {
                        controller.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Dropdown field builder ───
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hintText,
    required IconData prefixIcon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ' $label',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: Icon(prefixIcon, color: Colors.black54),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // ─── Date field builder ───
  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ' $label',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            readOnly: true,
            onTap: _pickDate,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(
                Icons.calendar_today_outlined,
                color: Colors.black54,
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.black54,
                  size: 20,
                ),
                onPressed: _pickDate,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Password field builder ───
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ' $label',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.black54,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

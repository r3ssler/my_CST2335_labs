// Import the encrypted shared preferences package for secure local storage
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

// UserRepository class - Handles encrypted storage and retrieval of user profile data
class UserRepository {
  // Instance of EncryptedSharedPreferences for secure data storage
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  // User profile fields with default empty values
  String firstName = '';       // Stores user's first name
  String lastName = '';        // Stores user's last name
  String phoneNumber = '';     // Stores user's phone number
  String email = '';           // Stores user's email address

  // Loads user data from encrypted shared preferences
  // Returns a Future that completes when data is loaded
  Future<void> loadData() async {
    // Retrieve each field from secure storage with empty string as fallback
    firstName = await _prefs.getString('firstName') ?? '';
    lastName = await _prefs.getString('lastName') ?? '';
    phoneNumber = await _prefs.getString('phoneNumber') ?? '';
    email = await _prefs.getString('email') ?? '';
  }

  // Saves current user data to encrypted shared preferences
  // Returns a Future that completes when data is saved
  Future<void> saveData() async {
    // Store each field in secure storage
    await _prefs.setString('firstName', firstName);
    await _prefs.setString('lastName', lastName);
    await _prefs.setString('phoneNumber', phoneNumber);
    await _prefs.setString('email', email);
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_repository.dart';
import 'profile_page.dart';

// LoginPage widget that handles user authentication
class LoginPage extends StatefulWidget {
  // Repository for managing user profile data
  final UserRepository userRepository = UserRepository();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for login form fields
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // SharedPreferences instance for storing login credentials
  late SharedPreferences _prefs;

  // Path to the image displayed based on login status
  String imageSource = "images/question.png";

  @override
  void initState() {
    super.initState();
    // Initialize preferences and load saved data when widget is created
    _initPrefs().then((_) {
      widget.userRepository.loadData(); // Load profile data when app starts
    });
  }

  // Initialize SharedPreferences instance
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedCredentials();
  }

  // Load saved username and password from SharedPreferences
  Future<void> _loadSavedCredentials() async {
    try {
      final String? savedUsername = _prefs.getString('username');
      final String? savedPassword = _prefs.getString('password');

      // If credentials exist, populate the text fields
      if (savedUsername != null && savedPassword != null) {
        setState(() {
          _loginController.text = savedUsername;
          _passwordController.text = savedPassword;
        });

        // Show notification that credentials were loaded
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Previous login credentials have been loaded.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading credentials: $e');
    }
  }

  // Save current credentials to SharedPreferences
  Future<void> _saveCredentials() async {
    try {
      await _prefs.setString('username', _loginController.text);
      await _prefs.setString('password', _passwordController.text);
    } catch (e) {
      print('Error saving credentials: $e');
    }
  }

  // Remove saved credentials from SharedPreferences
  Future<void> _clearCredentials() async {
    try {
      await _prefs.remove('username');
      await _prefs.remove('password');
    } catch (e) {
      print('Error clearing credentials: $e');
    }
  }

  // Show dialog asking user if they want to save credentials
  void _showSaveCredentialsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Credentials'),
          content: const Text('Would you like to save your username and password for next time?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                _clearCredentials();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                _saveCredentials();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Navigate to profile page if login is successful
  void _navigateToProfilePage() {
    if (_passwordController.text == "QWERTY123") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            loginName: _loginController.text,
            userRepository: widget.userRepository,
          ),
        ),
      );
      // Show welcome message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome Back ${_loginController.text}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Update displayed image based on login status
  void _updateImage() {
    setState(() {
      if (_passwordController.text == "QWERTY123") {
        imageSource = "images/idea.png"; // Success image
        _navigateToProfilePage();
      } else {
        imageSource = "images/stop.png"; // Error image
      }
    });
    _showSaveCredentialsDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Username input field
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(
                labelText: 'Login name',
              ),
            ),
            // Password input field
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true, // Hide password characters
            ),
            const SizedBox(height: 20),
            // Login button
            ElevatedButton(
              onPressed: _updateImage,
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            // Status image
            Image.asset(
              imageSource,
              width: 300,
              height: 300,
            )
          ],
        ),
      ),
    );
  }
}

// Import necessary Flutter material package and login page
import 'package:flutter/material.dart';
import 'login_page.dart';

// Main function - Entry point of the Flutter application
void main() {
  // Run the application with MyApp widget as root
  runApp(MyApp());
}

// MyApp widget - Root widget of the application
class MyApp extends StatelessWidget {
  // Build method - Describes the part of UI represented by this widget
  @override
  Widget build(BuildContext context) {
    // MaterialApp widget provides fundamental app design elements
    return MaterialApp(
      // Hide debug banner in top-right corner
      debugShowCheckedModeBanner: false,

      // Set LoginPage as the initial screen (home screen)
      home: LoginPage(),
    );
  }
}


// Import required Flutter material components and URL launcher package
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'user_repository.dart';

// ProfilePage widget - Displays and manages user profile information
class ProfilePage extends StatefulWidget {
  // The username passed from login screen
  final String loginName;

  // Repository for storing/loading profile data
  final UserRepository userRepository;

  // Constructor with required parameters
  const ProfilePage({
    required this.loginName,
    required this.userRepository,
    Key? key,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

// State class for ProfilePage that manages the widget's state and behavior
class _ProfilePageState extends State<ProfilePage> {
  // Controllers for form text fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;

  // Loading state flag
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load profile data when widget initializes
    _loadProfileData();
  }

  // Asynchronously loads profile data from repository
  Future<void> _loadProfileData() async {
    // Wait for data to load from persistent storage
    await widget.userRepository.loadData();

    // Update state with loaded data
    setState(() {
      // Initialize controllers with loaded values
      _firstNameController = TextEditingController(text: widget.userRepository.firstName);
      _lastNameController = TextEditingController(text: widget.userRepository.lastName);
      _phoneNumberController = TextEditingController(text: widget.userRepository.phoneNumber);
      _emailController = TextEditingController(text: widget.userRepository.email);

      // Mark loading as complete
      _isLoading = false;
    });

    // Add listeners to automatically save changes
    _firstNameController.addListener(_saveFirstName);
    _lastNameController.addListener(_saveLastName);
    _phoneNumberController.addListener(_savePhoneNumber);
    _emailController.addListener(_saveEmail);
  }

  @override
  void dispose() {
    // Clean up controllers when widget is disposed
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Save first name to repository when changed
  void _saveFirstName() {
    widget.userRepository.firstName = _firstNameController.text;
    widget.userRepository.saveData();
  }

  // Save last name to repository when changed
  void _saveLastName() {
    widget.userRepository.lastName = _lastNameController.text;
    widget.userRepository.saveData();
  }

  // Save phone number to repository when changed
  void _savePhoneNumber() {
    widget.userRepository.phoneNumber = _phoneNumberController.text;
    widget.userRepository.saveData();
  }

  // Save email to repository when changed
  void _saveEmail() {
    widget.userRepository.email = _emailController.text;
    widget.userRepository.saveData();
  }

  // Launches URL for phone calls, SMS or email
  Future<void> _launchUrl(String url) async {
    try {
      // Check if device can handle the URL scheme
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        // Show error if URL scheme not supported
        _showUrlNotSupportedDialog(url);
      }
    } catch (e) {
      _showUrlNotSupportedDialog(url);
    }
  }

  // Shows dialog when URL scheme is not supported
  void _showUrlNotSupportedDialog(String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('This device does not support $url URLs'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while data is loading
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile Page')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Main profile page layout
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message with username
            Text(
              'Welcome Back ${widget.loginName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // First Name input field
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Last Name input field
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone Number input with call and SMS buttons
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 8),
                // Call button
                ElevatedButton(
                  onPressed: () => _launchUrl('tel:${_phoneNumberController.text}'),
                  child: const Icon(Icons.phone),
                ),
                const SizedBox(width: 8),
                // SMS button
                ElevatedButton(
                  onPressed: () => _launchUrl('sms:${_phoneNumberController.text}'),
                  child: const Icon(Icons.message),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Email input with mail button
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 8),
                // Email button
                ElevatedButton(
                  onPressed: () => _launchUrl('mailto:${_emailController.text}'),
                  child: const Icon(Icons.mail),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
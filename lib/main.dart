import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

// Secure storage instance
final _storage = FlutterSecureStorage();

// Repository for profile data with per-username keys
class ProfileRepository {
  Future<void> saveProfile({
    required String username,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String emailAddress,
  }) async {
    await _storage.write(key: 'firstName_$username', value: firstName);
    await _storage.write(key: 'lastName_$username', value: lastName);
    await _storage.write(key: 'phoneNumber_$username', value: phoneNumber);
    await _storage.write(key: 'emailAddress_$username', value: emailAddress);
  }

  Future<Map<String, String>> loadProfile(String username) async {
    final firstName = await _storage.read(key: 'firstName_$username') ?? '';
    final lastName = await _storage.read(key: 'lastName_$username') ?? '';
    final phoneNumber = await _storage.read(key: 'phoneNumber_$username') ?? '';
    final emailAddress = await _storage.read(key: 'emailAddress_$username') ?? '';
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
    };
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 04 - Login with Storage',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Lab 04 - Login Image'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String imagePath = "assets/images/question-mark.png";

  @override
  void initState() {
    super.initState();
    _loadLoginData();
  }

  void _loadLoginData() async {
    String? savedUsername = await _storage.read(key: 'username');
    String? savedPassword = await _storage.read(key: 'password');
    String? savedImagePath = await _storage.read(key: 'imagePath');

    if (savedUsername != null && savedPassword != null && savedImagePath != null) {
      setState(() {
        _loginController.text = savedUsername;
        _passwordController.text = savedPassword;
        imagePath = savedImagePath;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login info loaded from storage")),
        );
      }
    }
  }

  void _handleLogin() {
    String password = _passwordController.text;

    if (password == "QWERTY1234" || password == "hi") {
      setState(() {
        imagePath = "assets/images/idea.png";
      });
      _showSaveDialog();
    } else {
      setState(() {
        imagePath = "assets/images/stop.png";
      });
    }
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save Login Info"),
        content: const Text("Do you want to save your username and password?"),
        actions: [
          TextButton(
            onPressed: () async {
              // Only delete login info keys, not all storage!
              await _storage.delete(key: 'username');
              await _storage.delete(key: 'password');
              await _storage.delete(key: 'imagePath');
              if (mounted) Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(username: _loginController.text),
                ),
              );
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              await _storage.write(key: 'username', value: _loginController.text);
              await _storage.write(key: 'password', value: _passwordController.text);
              await _storage.write(key: 'imagePath', value: imagePath);
              if (mounted) Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(username: _loginController.text),
                ),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _loginController,
                decoration: const InputDecoration(
                  labelText: 'Login',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text("Login"),
              ),
              const SizedBox(height: 24),
              Image.asset(
                imagePath,
                height: 250,
                width: 250,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String username;
  const ProfilePage({super.key, required this.username});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRepository _repo = ProfileRepository();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome Back! ${widget.username}')),
      );
    });
  }

  Future<void> _loadProfile() async {
    final data = await _repo.loadProfile(widget.username);
    setState(() {
      _firstNameController.text = data['firstName'] ?? '';
      _lastNameController.text = data['lastName'] ?? '';
      _phoneController.text = data['phoneNumber'] ?? '';
      _emailController.text = data['emailAddress'] ?? '';
    });
  }

  Future<void> _saveProfile() async {
    await _repo.saveProfile(
      username: widget.username,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phoneNumber: _phoneController.text,
      emailAddress: _emailController.text,
    );
  }

  Future<void> _launchUrl(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Could not launch ${uri.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        backgroundColor: Colors.deepPurple[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _saveProfile(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _saveProfile(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => _saveProfile(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.sms),
                  tooltip: 'Send SMS',
                  onPressed: () {
                    final phone = _phoneController.text;
                    if (phone.isNotEmpty) {
                      _launchUrl(Uri(scheme: 'sms', path: phone));
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.phone),
                  tooltip: 'Call',
                  onPressed: () {
                    final phone = _phoneController.text;
                    if (phone.isNotEmpty) {
                      _launchUrl(Uri(scheme: 'tel', path: phone));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => _saveProfile(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.mail),
                  tooltip: 'Send Email',
                  onPressed: () {
                    final email = _emailController.text;
                    if (email.isNotEmpty) {
                      _launchUrl(Uri(
                        scheme: 'mailto',
                        path: email,
                      ));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

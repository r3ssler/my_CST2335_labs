import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

// Secure storage instance
final _storage = FlutterSecureStorage();

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login info loaded from storage")),
      );
    }
  }

  void _handleLogin() {
    String password = _passwordController.text;

    setState(() {
      if (password == "QWERTY1234" || password == "hi") {
        imagePath = "assets/images/idea.png";
      } else {
        imagePath = "assets/images/stop.png";
      }
    });

    _showSaveDialog();
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
              await _storage.deleteAll(); // remove saved data
              Navigator.pop(context);
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              await _storage.write(key: 'username', value: _loginController.text);
              await _storage.write(key: 'password', value: _passwordController.text);
              await _storage.write(key: 'imagePath', value: imagePath);
              Navigator.pop(context);
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

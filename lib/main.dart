import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleverTap Push Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  late CleverTapPlugin _clevertapPlugin; // 👈 instance for CleverTap

  @override
  void initState() {
    super.initState();
    CleverTapPlugin.setDebugLevel(3);
    _clevertapPlugin = CleverTapPlugin();

    _askNotificationPermission();
    _initCleverTap();
    _listenForNotificationClicks();
  }

  /// Ask push permission on launch
  Future<void> _askNotificationPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    } else if (Platform.isIOS) {
      CleverTapPlugin.registerForPush();
    }
  }

  /// Initialize CleverTap and set FCM token
  Future<void> _initCleverTap() async {
    await CleverTapPlugin.createNotificationChannel(
      "flutterdemo", "Flutter Demo", "Demo Channel", 3, true);

    CleverTapPlugin.registerForPush();

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await CleverTapPlugin.setPushToken(token);
      debugPrint("Push token synced at app init: $token");
    }
  }

  /// Listen for CleverTap push click payload
  void _listenForNotificationClicks() {
    _clevertapPlugin.setCleverTapPushClickedPayloadReceivedHandler(
      (Map<String, dynamic>? payload) {
        debugPrint("Notification clicked payload: $payload");
        if (payload != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HomePageWithPayload(payload: payload),
            ),
          );
        }
      },
    );
  }

  /// Handle login
  Future<void> _login() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    // Identify the user in CleverTap
    await CleverTapPlugin.onUserLogin({
      'Identity': email,
      'Email': email,
    });

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Enter your email"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: const Center(
        child: Text("Welcome! Push is enabled with CleverTap."),
      ),
    );
  }
}

class HomePageWithPayload extends StatelessWidget {
  final Map<String, dynamic> payload;
  const HomePageWithPayload({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Clicked")),
      body: Center(
        child: Text("Payload: $payload"),
      ),
    );
  }
}

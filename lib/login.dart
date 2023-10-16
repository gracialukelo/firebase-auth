import 'package:anmeldung/firebase_options.dart';
import 'package:anmeldung/media.dart';
import 'package:anmeldung/password_reset.dart';
import 'package:anmeldung/verify_email.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> createUserWithEmailPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        if (userCredential.user != null) {
          _showDialogy('Willkommen bei OMBA',
              'Bitte überprüfen Sie Ihre E-Mail und klicken Sie auf den Bestätigungslink.');
        } else {
          _showDialog('Registrierung fehlgeschlagen',
              'Die Registrierung ist fehlgeschlagen. Bitte versuchen Sie es erneut.');
        }
      } catch (e) {
        _showDialog('Registrierung fehlgeschlagen',
            'Die Registrierung ist fehlgeschlagen. Bitte überprüfen Sie Ihre Daten und versuchen Sie es erneut.');
      }
    }
  }

  // Melde User ein mit Password und E-Mail
  Future<void> logInUserWithEmailPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (userCredential.user != null) {
          _showDialogx('Erfolgreich angemeldet', 'Sie sind jetzt angemeldet.');
        } else {
          _showDialog('Anmeldung fehlgeschlagen',
              'Die Anmeldung mit E-Mail und Passwort ist fehlgeschlagen.');
        }
      } catch (e) {
        _showDialog('Anmeldung fehlgeschlagen',
            'Die Anmeldung mit E-Mail und Passwort ist fehlgeschlagen.');
      }
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return authResult;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> handleSignInWithGoogle() async {
    try {
      UserCredential userCredential = await signInWithGoogle();

      if (userCredential.user != null) {
        _showDialogx('Erfolgreich angemeldet', 'Sie sind jetzt angemeldet.');
      }
    } catch (e) {
      _showDialog('Anmeldung fehlgeschlagen',
          'Die Anmeldung mit Google ist fehlgeschlagen.');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDialogx(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MediePage(),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDialogy(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const VerifyScreen(),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anmeldung'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'E-Mail',
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  } else if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Passwort',
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 32,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: createUserWithEmailPassword,
                    child: const Text('Registrieren'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: logInUserWithEmailPassword,
                    child: const Text('Anmelden'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SignInButton(
                Buttons.google,
                text: 'Mit Google anmelden',
                onPressed: handleSignInWithGoogle,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ResetPassword()));
                  },
                  child: const Text("Password vergesse? "))
            ],
          ),
        ),
      ),
    );
  }
}

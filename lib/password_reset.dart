import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final auth = FirebaseAuth.instance;

  Future<void> resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await auth.sendPasswordResetEmail(email: emailController.text);
        _showDialog('Passwort zurücksetzen angefordert',
            'Überprüfen Sie Ihre E-Mails für weitere Anweisungen.');
      } catch (e) {
        _showDialog('Fehler beim Zurücksetzen des Passworts',
            'Das Zurücksetzen des Passworts ist fehlgeschlagen. Bitte überprüfen Sie Ihre Daten und versuchen Sie es erneut.');
      }
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
                Navigator.popUntil(
                  context,
                  ModalRoute.withName('/'),
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
        title: const Text('Passwort zurücksetzen'),
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
                    return 'Bitte geben Sie eine E-Mail-Adresse ein.';
                  } else if (!value.contains('@') || !value.contains('.')) {
                    return 'Bitte geben Sie eine gültige E-Mail-Adresse ein.';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 32,
              ),
              ElevatedButton(
                onPressed: resetPassword,
                child: const Text('Anfrage senden'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

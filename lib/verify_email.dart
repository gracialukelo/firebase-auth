import 'dart:async';
import 'package:anmeldung/media.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final auth = FirebaseAuth.instance;
  late User user;
  late Timer timer;

  Future<void> emailVerified() async {
    user = auth.currentUser!;
    await user.reload();
    if (!mounted) {
      return;
    } else if (user.emailVerified) {
      timer.cancel();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MediePage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    user = auth.currentUser!;
    user.sendEmailVerification();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      emailVerified();
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
            "Die E-Mail wurde an ${user.email} gesendet. Bitte überprüfen Sie Ihre E-Mail und klicken Sie auf den Bestätigungslink."),
      ),
    );
  }
}

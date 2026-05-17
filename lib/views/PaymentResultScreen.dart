import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentResultScreen extends StatefulWidget {
  final bool isSuccess;
  final String message;

  const PaymentResultScreen({
    Key? key,
    required this.isSuccess,
    required this.message,
  }) : super(key: key);

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  int countdown = 3;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    _startAutoRedirect();
  }

  void _startAutoRedirect() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown == 1) {
        t.cancel();
        // Get.offAll(() => BottomNavigationBarScreen());
        Get.back();
        Get.back();
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  Color get bgColor =>
      widget.isSuccess ? Colors.green.shade50 : Colors.red.shade50;

  Color get primaryColor => widget.isSuccess ? Colors.green : Colors.red;

  IconData get icon => widget.isSuccess ? Icons.check_circle : Icons.cancel;

  String get title =>
      widget.isSuccess ? "Payment Successful" : "Payment Failed";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // ❌ prevent back
      child: Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔥 Animated Icon
                ScaleTransition(
                  scale: scaleAnimation,
                  child: Icon(
                    icon,
                    size: 110,
                    color: primaryColor,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                FadeTransition(
                  opacity: fadeAnimation,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Message
                FadeTransition(
                  opacity: fadeAnimation,
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ⏳ Countdown text
                FadeTransition(
                  opacity: fadeAnimation,
                  child: Text(
                    "Redirecting in $countdown sec...",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Optional loader
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

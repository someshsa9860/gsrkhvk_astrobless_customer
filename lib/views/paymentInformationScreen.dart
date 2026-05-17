// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:callvcal/controllers/astromallController.dart';
import 'package:callvcal/controllers/splashController.dart';
import 'package:callvcal/controllers/walletController.dart';
import 'package:callvcal/utils/global.dart' as global;
import 'package:callvcal/utils/services/api_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'PaymentResultScreen.dart';

class PaymentInformationScreen extends StatefulWidget {
  final double amount;
  final int? flag;
  final int? cashback;

  const PaymentInformationScreen({
    Key? key,
    required this.amount,
    this.flag,
    this.cashback = 0,
  }) : super(key: key);

  @override
  State<PaymentInformationScreen> createState() =>
      _PaymentInformationScreenState();
}

class _PaymentInformationScreenState extends State<PaymentInformationScreen> {
  final walletController = Get.find<WalletController>();
  final splashController = Get.find<SplashController>();
  final astromallController = Get.find<AstromallController>();
  final apiHelper = APIHelper();

  late Razorpay _razorpay;

  bool isLoading = false;

  double get gstAmount =>
      widget.amount *
      double.parse(global.getSystemFlagValue(global.systemFlagNameList.gst)) /
      100;

  double get totalPayable => widget.amount + gstAmount;

  double get cashbackAmount => widget.cashback == 0
      ? 0
      : widget.amount * (int.tryParse(widget.cashback.toString()) ?? 0) / 100;

  double get finalAmount => widget.amount + cashbackAmount;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ================= PAYMENT FLOW =================

  Future<void> _processPayment() async {
    if (isLoading) return;

    try {
      setState(() => isLoading = true);

      final value = await apiHelper.addAmountInWallet(
        amount: double.parse(totalPayable.toStringAsFixed(2)),
        cashback: widget.cashback == 0
            ? 0
            : int.parse((int.parse(widget.amount.toString().split(".").first) *
                    ((int.tryParse(widget.cashback.toString()) ?? 0) / 100))
                .toString()
                .split(".")
                .first),
      );

      if (value['status'] == 200) {
        final data = value['data'];
        _openRazorpayCheckout(data);
      } else {
        _showError(value['message'] ?? "Payment failed");
      }
    } catch (e) {
      log("Payment Error: $e");
      _showError("Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _openRazorpayCheckout(dynamic data) {
    var options = {
      'key': data['key'],
      'amount': data['amount'],
      'currency': data['currency'],
      'order_id': data['razorpay_order_id'],
      'name': 'Astrobless',
      'description': 'Wallet Recharge',
      'prefill': {
        'contact': data['contact'],
        'email': data['email'],
      },
      'theme': {'color': '#3399cc'},
      'notes': {
        'internal_pay_id': data['payment_id'].toString(),
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      log("Razorpay error: $e");
      _showError("Unable to open payment gateway");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log("SUCCESS: ${response.paymentId}");

    Get.find<SplashController>().getCurrentUserData();

    Get.to(() => PaymentResultScreen(
          isSuccess: true,
          message: "Your payment was completed successfully.",
        ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    log("ERROR: ${response.message}");

    Get.to(() => PaymentResultScreen(
          isSuccess: false,
          message: response.message ?? "Payment failed. Please try again.",
        ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log("WALLET: ${response.walletName}");
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Get.theme.primaryColor,
        title: const Text(
          'Payment Information',
          style: TextStyle(fontWeight: FontWeight.w600),
        ).tr(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔶 Top Section (Summary)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Get.theme.primaryColor,
                    Get.theme.primaryColor.withOpacity(0.85),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Payable",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ).tr(),
                  const SizedBox(height: 6),
                  Text(
                    '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${totalPayable.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔒 Secure Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          "100% Secure & Encrypted",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔶 Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _paymentDetailsCard(),
                    const SizedBox(height: 20),

                    // 🔐 Trust Section
                    _securityInfoCard(),
                  ],
                ),
              ),
            ),

            // 🔶 Bottom Pay Button
            _payButton(),
          ],
        ),
      ),
    );
  }

  Widget _securityInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.verified_user,
                  color: Get.theme.primaryColor, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Your payment is secured with industry-standard encryption",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.shield, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Powered by Razorpay Secure Payment Gateway",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.blueGrey, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "We do not store your card or UPI details",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Text('Amount to Pay', style: TextStyle(color: Colors.white))
              .tr(),
          const SizedBox(height: 8),
          Text(
            '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${totalPayable.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _paymentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _row("Total Amount", widget.amount),
          _row("GST", gstAmount),
          _row("Total Payable", totalPayable, bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label).tr(),
          Text(
            '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _payButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : _processPayment,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Pay ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${totalPayable.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
      ),
    ).paddingSymmetric(horizontal: 16, vertical: 16);
  }
}

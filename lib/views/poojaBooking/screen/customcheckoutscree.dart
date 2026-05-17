// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:callvcal/controllers/bottomNavigationController.dart';
import 'package:callvcal/controllers/history_controller.dart';
import 'package:callvcal/controllers/walletController.dart';
import 'package:callvcal/model/custompujamodel.dart';
import 'package:callvcal/model/user_address_model.dart';
import 'package:callvcal/utils/global.dart' as global;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../controllers/astromallController.dart';
import '../../../utils/services/api_helper.dart';
import '../../bottomNavigationBarScreen.dart';

class CustomCheckoutscreen extends StatefulWidget {
  final UserAddressModel? address;
  final CustomPujaModel? poojadetail;
  final int index;

  const CustomCheckoutscreen({
    super.key,
    this.address,
    this.poojadetail,
    required this.index,
  });

  @override
  State<CustomCheckoutscreen> createState() => _CheckoutscreenState();
}

class _CheckoutscreenState extends State<CustomCheckoutscreen> {
  double? gst = 0;
  double? totalamount = 0.0;
  final apiHelper = APIHelper();
  final historyController = Get.find<HistoryController>();
  final bottomnavController = Get.find<BottomNavigationController>();
  final walletcontroller = Get.find<WalletController>();
  late Razorpay _razorpay;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _openRazorpayCheckout(dynamic data) {
    var options = {
      'key': data['key'],
      'amount': data['amount'],
      'currency': data['currency'],
      'order_id': data['razorpay_order_id'],
      'name': 'Custom Puja Booking',
      'description': widget.poojadetail?.pujaTitle ?? '',
      'prefill': {
        'contact': data['contact'],
        'email': data['email'],
      },
      'theme': {'color': '#F57C00'},
      'notes': {
        'internal_pay_id': data['payment_id'].toString(),
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      log("Razorpay Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    log("SUCCESS: ${response.paymentId}");

    await walletcontroller.getAmount();

    Get.offAll(() => BottomNavigationBarScreen(index: 0));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    log("ERROR: ${response.message}");

    Get.snackbar("Payment Failed", response.message ?? "Try again");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log("WALLET: ${response.walletName}");
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: GetBuilder<AstromallController>(
        builder: (mallcontroller) => mallcontroller.userAddress.isNotEmpty
            ? InkWell(
                onTap: () async {
                  if (isLoading) return;

                  try {
                    setState(() => isLoading = true);

                    global.showOnlyLoaderDialog(Get.context);

                    final value = await apiHelper.placedPujaOrderCustom(
                      pujaid: widget.poojadetail!.id!,
                      addressid: widget.address!.id!,
                      astrologerid: widget.poojadetail!.astrologerId,
                      pujaprice: widget.poojadetail!.pujaPrice!,
                    );

                    global.hideLoader();

                    if (value['status'] == 200) {
                      if (value['message'] == "Pay Online.") {
                        final data = value['data'];

                        _openRazorpayCheckout(data);
                      } else {
                        global.showToast(
                          message: value['message'],
                          textColor: Colors.black,
                          bgColor: Colors.white,
                        );

                        global.splashController.getCurrentUserData();
                        await walletcontroller.getAmount();
                        await historyController.getChatHistory(
                            global.currentUserId!, false);

                        Get.off(() => BottomNavigationBarScreen(index: 0));
                      }
                    }
                  } catch (e) {
                    global.hideLoader();
                    log("Custom checkout error: $e");
                  } finally {
                    setState(() => isLoading = false);
                  }
                },
                child: Container(
                  width: 100.w,
                  height: 8.h,
                  margin: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.orange.shade200,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Buy Now',
                            style: Get.textTheme.titleMedium!.copyWith(
                              fontSize: 18.sp,
                              color: Colors.white,
                            ),
                          ).tr(),
                        ),
                        SizedBox(width: 3.w),
                      ]),
                ),
              )
            : SizedBox(),
      ),
      appBar: AppBar(
        title: Text('Checkout').tr(),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 55.h,
              width: 100.w,
              child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 7.w),
                  elevation: 1.w,
                  child: Column(
                    children: [
                      SizedBox(height: 3.h),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.w),
                            color: Color(0xffe7f1ff),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ]),
                        child: Center(
                          child: Text(
                            'Product Details',
                            style: Get.textTheme.titleMedium!.copyWith(
                              fontSize: 18.sp,
                              color: Color(0xff79b4fd),
                            ),
                          ).tr(),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Text('${widget.poojadetail!.pujaTitle}',
                            style: Get.textTheme.titleMedium),
                      ),
                      SizedBox(height: 1.h),
                      _buildbannerwidget(
                          widget.poojadetail!.pujaImages[0].toString()),
                      SizedBox(height: 1.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price',
                              style: Get.textTheme.titleMedium,
                            ),
                            Text(
                              '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${widget.poojadetail?.pujaPrice}',
                              style: Get.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '(incl of all taxes)',
                              style: Get.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Container(
                        width: double.infinity,
                        height: 0.2,
                        margin: EdgeInsets.symmetric(horizontal: 6.w),
                        color: Colors.black,
                      ),
                      SizedBox(height: 3.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: Get.textTheme.titleMedium,
                            ),
                            Text(
                              '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${widget.poojadetail?.pujaPrice.toString()}',
                              style: Get.textTheme.titleMedium!.copyWith(
                                  fontSize: 17.sp,
                                  color: Color(0xff79b4fd),
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Container _buildbannerwidget(String pujaimage) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      width: 100.w,
      height: 20.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          "${pujaimage}",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

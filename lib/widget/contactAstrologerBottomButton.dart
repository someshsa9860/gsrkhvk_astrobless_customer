import 'package:callvcal/views/bottomNavigationBarScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../controllers/bottomNavigationController.dart';

const orangeColor = Colors.orange;

class ContactAstrologerCottomButton extends StatelessWidget {
  const ContactAstrologerCottomButton({Key? key, this.isHome = false})
      : super(key: key);

  final bool isHome;

  @override
  Widget build(BuildContext context) {
    if (isHome) {
      return buildRow();
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(top: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: buildRow(),
    );
  }

  Widget buildRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                BottomNavigationController bottomNavigationController =
                    Get.find<BottomNavigationController>();
                bottomNavigationController.setIndex(1, 0);
                Get.to(() => BottomNavigationBarScreen(index: 1));
              },
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: orangeColor,
                  borderRadius: BorderRadius.circular(30.w),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        'Contact Astrologer',
                        style: Get.theme.primaryTextTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                            wordSpacing: 0,
                            color: Colors.white),
                      ).tr(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                BottomNavigationController bottomNavigationController =
                    Get.find<BottomNavigationController>();
                bottomNavigationController.setIndex(3, 0);
                Get.to(() => BottomNavigationBarScreen(
                      index: 3,
                    ));
              },
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(30.w),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        'Contact Counsellor',
                        style: Get.theme.primaryTextTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                            wordSpacing: 0,
                            color: Colors.white),
                      ).tr(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactAstrologerCottomButtonHome extends StatelessWidget {
  const ContactAstrologerCottomButtonHome(
      {Key? key,
      this.isHome = false,
      required this.onTapChat,
      required this.onTapCall})
      : super(key: key);

  final bool isHome;
  final VoidCallback onTapChat, onTapCall;

  @override
  Widget build(BuildContext context) {
    if (isHome) {
      return buildRow();
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(top: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: buildRow(),
    );
  }

  Widget buildRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTapChat,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: orangeColor,
                  borderRadius: BorderRadius.circular(30.w),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        'Contact Astrologer',
                        style: Get.theme.primaryTextTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                            wordSpacing: 0,
                            color: Colors.white),
                      ).tr(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTapCall,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(30.w),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        'Contact Counsellor',
                        style: Get.theme.primaryTextTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                            wordSpacing: 0,
                            color: Colors.white),
                      ).tr(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

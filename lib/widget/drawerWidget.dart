// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:callvcal/controllers/bottomNavigationController.dart';
import 'package:callvcal/controllers/callController.dart';
import 'package:callvcal/controllers/follow_astrologer_controller.dart';
import 'package:callvcal/controllers/history_controller.dart';
import 'package:callvcal/controllers/homeController.dart';
import 'package:callvcal/controllers/splashController.dart';
import 'package:callvcal/controllers/userProfileController.dart';
import 'package:callvcal/controllers/walletController.dart';
import 'package:callvcal/utils/global.dart' as global;
import 'package:callvcal/utils/services/api_helper.dart';
import 'package:callvcal/views/ReferAndEarnScreen.dart';
import 'package:callvcal/views/addMoneyToWallet.dart';
import 'package:callvcal/views/getReportScreen.dart';
import 'package:callvcal/views/languageScreen.dart';
import 'package:callvcal/views/multiDesignLayout/home_widget/feedbackScreen.dart';
import 'package:callvcal/views/myFollowingScreen.dart';
import 'package:callvcal/views/profile/editUserProfileScreen.dart';
import 'package:callvcal/views/settings/settingsScreen.dart';
import 'package:callvcal/widget/CanvasStyle/wavydivider.dart';
import 'package:callvcal/widget/commonDialogWidget%20copy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/advancedPanchangController.dart';
import '../controllers/astrologer_assistant_controller.dart';
import '../controllers/customer_support_controller.dart';
import '../utils/images.dart';
import '../views/customer_support/customerSupportChatScreen.dart';
import '../views/loginScreen.dart';
import 'appversionwidget.dart';

class DrawerWidget extends StatefulWidget {
  DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final splashController = Get.find<SplashController>();
  final callController = Get.put(CallController());
  final panchangController = Get.find<PanchangController>();
  final userProfileController = Get.find<UserProfileController>();
  final historyController = Get.find<HistoryController>();
  final googleTranslator = GoogleTranslator();
  final homeController = Get.find<HomeController>();
  final walletController = Get.find<WalletController>();
  final apiHelper = APIHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        child: SingleChildScrollView(
          child: GetBuilder<SplashController>(builder: (splashController) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                      style: Get.theme.textTheme.bodyMedium!.copyWith(
                          color: Get.theme.primaryColor,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700),
                      text: "Astro",
                      children: [
                        TextSpan(
                            style: Get.theme.textTheme.bodyMedium!.copyWith(
                                color: Colors.black,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w400),
                            text: "bless")
                      ]),
                ),
                SizedBox(height: 30),
                global.currentUserId != null
                    ? SizedBox()
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        padding: EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Get.offAll(() => LoginScreen());
                            },
                            child: _drawerItem(
                                icon: CupertinoIcons.square_arrow_right,
                                title: 'Login')),
                      ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    bool isLogin = await global.isLogin();
                    if (isLogin) {
                      global.showOnlyLoaderDialog(context);
                      await splashController.getCurrentUserData();
                      await userProfileController.getZodicImg();
                      global.hideLoader();
                      Get.to(() => EditUserProfile());
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          bool isLogin = await global.isLogin();
                          if (isLogin) {
                            global.showOnlyLoaderDialog(context);
                            await splashController.getCurrentUserData();
                            await userProfileController.getZodicImg();
                            global.hideLoader();
                            Get.to(() => EditUserProfile());
                          }
                        },
                        child: _drawerItem(
                            icon: CupertinoIcons.person_alt_circle,
                            title: tr('My Profile'))),
                  ),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    bool isLogin = await global.isLogin();
                    global.showOnlyLoaderDialog(context);
                    await global.splashController.getCurrentUserData();
                    await walletController.getAmount();
                    walletController.update();
                    splashController.update();
                    global.hideLoader();
                    if (isLogin) {
                      Get.to(() => AddmoneyToWallet());
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InkWell(
                        onTap: () async {
                          bool isLogin = await global.isLogin();
                          global.showOnlyLoaderDialog(context);
                          await global.splashController.getCurrentUserData();
                          await walletController.getAmount();
                          walletController.update();
                          splashController.update();
                          global.hideLoader();
                          if (isLogin) {
                            Get.to(() => AddmoneyToWallet());
                          }
                        },
                        child: _drawerItem(
                            svgPath:
                                'assets/images/money-rupee-circle-line.svg',
                            icon: null,
                            title: tr('My Wallet'))),
                  ),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    homeController.lan = [];
                    await homeController.getLanguages();
                    await homeController.updateLanIndex();
                    Get.to(() => Languagescreen());
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          homeController.lan = [];
                          await homeController.getLanguages();
                          await homeController.updateLanIndex();
                          Get.to(() => Languagescreen());
                        },
                        child: _drawerItem(
                            icon: CupertinoIcons.globe,
                            iconColor: Colors.grey,
                            title: tr('App Language'))),
                  ),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    final bottomNavigationController =
                        Get.find<BottomNavigationController>();
                    bottomNavigationController.astrologerList = [];
                    bottomNavigationController.astrologerList.clear();
                    bottomNavigationController.isAllDataLoaded = false;
                    bottomNavigationController.update();
                    global.showOnlyLoaderDialog(context);
                    await bottomNavigationController.getAstrologerList(
                        isLazyLoading: false);
                    global.hideLoader();
                    Get.to(() => GetReportScreen());
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              final bottomNavigationController =
                                  Get.find<BottomNavigationController>();
                              bottomNavigationController.astrologerList = [];
                              bottomNavigationController.astrologerList.clear();
                              bottomNavigationController.isAllDataLoaded =
                                  false;
                              bottomNavigationController.update();
                              global.showOnlyLoaderDialog(context);
                              await bottomNavigationController
                                  .getAstrologerList(isLazyLoading: false);
                              global.hideLoader();
                              Get.to(() => GetReportScreen());
                            },
                            child: _drawerItem(
                                icon: CupertinoIcons.doc_text_viewfinder,
                                title: 'Get Report')),
                        splashController.currentUser == null ||
                                splashController.currentUser == ""
                            ? const SizedBox()
                            : InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  Get.to(() => ReferAndEarnScreen());
                                },
                                child: _drawerItem(
                                    icon:
                                        CupertinoIcons.arrowshape_turn_up_right,
                                    title: tr('Invite a Friend'))),
                        InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              bool isLogin = await global.isLogin();
                              if (isLogin) {
                                final FollowAstrologerController
                                    followAstrologerController =
                                    Get.find<FollowAstrologerController>();
                                followAstrologerController.followedAstrologer
                                    .clear();
                                followAstrologerController.isAllDataLoaded =
                                    false;
                                global.showOnlyLoaderDialog(context);
                                await followAstrologerController
                                    .getFollowedAstrologerList(false);
                                global.hideLoader();
                                Get.to(() => MyFollowingScreen());
                              }
                            },
                            child: _drawerItem(
                                icon: CupertinoIcons.arrow_turn_down_right,
                                title: 'My Following')),
                        InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              bool isLogin = await global.isLogin();
                              if (isLogin) {
                                Get.to(() => FeedbackScreen());
                              } else {
                                global.showToast(
                                    message: 'Please login first',
                                    textColor: Colors.white,
                                    bgColor: Colors.black);
                              }
                            },
                            child: _drawerItem(
                                icon: CupertinoIcons.arrow_3_trianglepath,
                                title: tr('FeedBack'))),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(children: [
                    // global.currentUserId != null
                    //     ? InkWell(
                    //         onTap: () async {
                    //           Navigator.pop(context);
                    //           launchUrl(Uri.parse(termsconditionUrl));
                    //         },
                    //         child: _drawerItem(
                    //             icon: CupertinoIcons.arrow_up_right_diamond,
                    //             title: 'Terms & Conditions'))
                    //     : SizedBox(),
                    // SizedBox(height: 5),
                    // global.currentUserId != null
                    //     ? InkWell(
                    //         onTap: () async {
                    //           Navigator.pop(context);
                    //           launchUrl(Uri.parse(refundpolicy));
                    //         },
                    //         child: _drawerItem(
                    //             icon: CupertinoIcons.refresh,
                    //             title: 'Refund Policies',
                    //             iconColor: Colors.grey[700]))
                    //     : SizedBox(),
                    InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          Get.to(() => SettingListScreen());
                        },
                        child: _drawerItem(
                            icon: CupertinoIcons.settings,
                            title: 'Settings',
                            iconColor: Colors.grey[700])),
                    SizedBox(height: 5),
                    InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        bool isLogin = await global.isLogin();
                        if (isLogin) {
                          CustomerSupportController customerSupportController =
                              Get.find<CustomerSupportController>();
                          AstrologerAssistantController
                              astrologerAssistantController =
                              Get.find<AstrologerAssistantController>();
                          global.showOnlyLoaderDialog(context);
                          Future.wait<void>([
                            customerSupportController.getCustomerTickets(),
                            astrologerAssistantController
                                .getChatWithAstrologerAssisteant()
                          ]);
                          global.hideLoader();
                          Get.to(() => CustomerSupportChat());
                        }
                      },
                      child: _drawerItem(
                          icon: CupertinoIcons.headphones,
                          title: 'Support Chat'),
                    ),
                  ]),
                ),
                SizedBox(height: 15.w),
                WavyDivider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    "Our Social Media Handles",
                    textAlign: TextAlign.center,
                    style: Get.theme.textTheme.bodyMedium!.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 17.sp),
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        if (!await launchUrl(Uri.parse(
                            "${global.getSystemFlagValueForLogin(global.systemFlagNameList.facebook)}"))) {
                          throw Exception(
                              'Could not launch ${global.getSystemFlagValueForLogin(global.systemFlagNameList.facebook)}');
                        }
                      },
                      child: Image.asset(Images.facebook,
                          fit: BoxFit.cover, height: 24.sp),
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    global.getSystemFlagValueForLogin(
                                global.systemFlagNameList.instra) ==
                            ""
                        ? SizedBox()
                        : InkWell(
                            onTap: () async {
                              if (!await launchUrl(Uri.parse(
                                  "${global.getSystemFlagValueForLogin(global.systemFlagNameList.instra)}"))) {
                                throw Exception(
                                    'Could not launch ${global.getSystemFlagValueForLogin(global.systemFlagNameList.instra)}');
                              }
                            },
                            child: Image.asset(Images.instagram,
                                fit: BoxFit.cover, height: 24.sp),
                          ),
                    SizedBox(
                      width: 2.w,
                    ),
                    global.getSystemFlagValueForLogin(
                                global.systemFlagNameList.linkedin) ==
                            ""
                        ? SizedBox()
                        : InkWell(
                            onTap: () async {
                              log('clicked ${global.getSystemFlagValueForLogin(global.systemFlagNameList.linkedin)}');
                              if (!await launchUrl(Uri.parse(
                                  "${global.getSystemFlagValueForLogin(global.systemFlagNameList.linkedin)}"))) {
                                throw Exception(
                                    'Could not launch ${global.getSystemFlagValueForLogin(global.systemFlagNameList.linkedin)}');
                              }
                            },
                            child: Image.asset(Images.linkedin,
                                fit: BoxFit.cover, height: 24.sp),
                          ),
                    SizedBox(
                      width: 2.w,
                    ),
                    global.getSystemFlagValueForLogin(
                                global.systemFlagNameList.youtube) ==
                            ""
                        ? SizedBox()
                        : InkWell(
                            onTap: () async {
                              if (!await launchUrl(Uri.parse(
                                  "${global.getSystemFlagValueForLogin(global.systemFlagNameList.youtube)}"))) {
                                throw Exception(
                                    'Could not launch ${global.getSystemFlagValueForLogin(global.systemFlagNameList.youtube)}');
                              }
                            },
                            child: Image.asset(Images.youTube,
                                fit: BoxFit.cover, height: 24.sp),
                          ),
                    SizedBox(width: 2.w),
                    SizedBox(width: 2.w),
                  ],
                ),
                SizedBox(height: 1.5.h),
                AppVersionWidget(),
                SizedBox(height: 8),
                global.currentUserId != null
                    ? Container(
                        alignment: Alignment.centerLeft,
                        padding:
                            EdgeInsets.symmetric(horizontal: 4.w, vertical: 8),
                        child: InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            showCommonDialog(
                              title: "Are you sure you want to logout?",
                              primaryButtonText: "Yes",
                              primaryButtonColor: Colors.red,
                              secondaryButtonText: "No",
                              onPrimaryPressed: () {
                                HistoryController historyController =
                                    Get.find<HistoryController>();
                                historyController.chatHistoryList.clear();
                                historyController.astroMallHistoryList.clear();
                                historyController.reportHistoryList.clear();
                                historyController.callHistoryList.clear();
                                historyController.paymentLogsList.clear();
                                historyController.walletTransactionList.clear();
                                global.logoutUser();
                              },
                              onSecondaryPressed: () {
                                Get.back(); // Just close the dialog
                              },
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 2.w),
                              Text(
                                'Log Out',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ).tr(),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: Get.width * 0.10),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _drawerItem(
      {String? svgPath,
      required IconData? icon,
      required String title,
      Color? iconColor}) {
    return Container(
      width: 70.w,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 8),
      child: Row(children: [
        if (svgPath == null) Icon(icon, size: 20, color: Colors.black87),
        if (svgPath != null)
          SvgPicture.asset(
            svgPath,
            width: 20,
            height: 20,
            color: Colors.black87,
          ),
        SizedBox(width: 15),
        Text(title,
                style: Get.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: 15.sp))
            .tr(),
        Spacer(),
        Icon(
          CupertinoIcons.forward,
          size: 18,
          color: Colors.grey,
        ),
      ]),
    );
  }
}

String formatEmail(String email) {
  if (email.length <= 15) return email;

  List<String> parts = email.split('@');
  if (parts.length != 2) return email; // Fallback if not a valid email format

  String username = parts[0];
  String domain = parts[1];

  if (username.length > 10) {
    return '${username.substring(0, 10)}..@$domain';
  } else {
    return '$username@$domain'; // No modification needed
  }
}

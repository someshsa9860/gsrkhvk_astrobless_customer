// // ignore_for_file: must_be_immutable, deprecated_member_use, invalid_use_of_protected_member, unused_element

// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'package:callvcal/controllers/astrologerCategoryController.dart';
// import 'package:callvcal/controllers/astrologyBlogController.dart';
// import 'package:callvcal/controllers/astromallController.dart';
// import 'package:callvcal/controllers/bottomNavigationController.dart';
// import 'package:callvcal/controllers/callController.dart';
// import 'package:callvcal/controllers/dailyHoroscopeController.dart';
// import 'package:callvcal/controllers/history_controller.dart';
// import 'package:callvcal/controllers/homeController.dart';
// import 'package:callvcal/controllers/kundliController.dart';
// import 'package:callvcal/controllers/liveController.dart';
// import 'package:callvcal/controllers/reviewController.dart';
// import 'package:callvcal/model/kundli_model.dart';
// import 'package:callvcal/utils/AppColors.dart';
// import 'package:callvcal/utils/config.dart';
// import 'package:callvcal/utils/date_converter.dart';
// import 'package:callvcal/utils/global.dart' as global;
// import 'package:callvcal/utils/images.dart';
// import 'package:callvcal/views/addMoneyToWallet.dart';
// import 'package:callvcal/views/astroBlog/astrologyBlogListScreen.dart';
// import 'package:callvcal/views/astroBlog/astrologyDetailScreen.dart';
// import 'package:callvcal/views/astrologerNews.dart';
// import 'package:callvcal/views/astrologerProfile/astrologerProfile.dart';
// import 'package:callvcal/views/astrologerVideo.dart';
// import 'package:callvcal/views/astromall/astromallScreen.dart';
// import 'package:callvcal/views/astromall/productDetailScreen.dart';
// import 'package:callvcal/views/blog_screen.dart';
// import 'package:callvcal/views/call/onetooneAudio/call_history_detail_screen.dart';
// import 'package:callvcal/views/callScreen.dart';
// import 'package:callvcal/views/chat/AcceptChatScreen.dart';
// import 'package:callvcal/views/kudali/kundliScreen.dart';
// import 'package:callvcal/views/kundliMatching/kundliMatchingScreen.dart';
// import 'package:callvcal/views/liveAstrologerList.dart';
// import 'package:callvcal/views/live_astrologer/live_astrologer_screen.dart';
// import 'package:callvcal/views/panchang/panchangScreen.dart';
// import 'package:callvcal/views/paymentInformationScreen.dart';
// import 'package:callvcal/views/profile/editUserProfileScreen.dart';
// import 'package:callvcal/views/recommendedpujadetailscreen.dart';
// import 'package:callvcal/views/stories/viewStories.dart';
// import 'package:callvcal/widget/commonDialogWidget%20copy.dart';
// import 'package:callvcal/widget/completeProfileDialog.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:skeletonizer/skeletonizer.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../controllers/IntakeController.dart';
// import '../../../controllers/advancedPanchangController.dart';
// import '../../../controllers/chatController.dart';
// import '../../../controllers/splashController.dart';
// import '../../../controllers/walletController.dart';
// import '../../../utils/CornerBanner.dart';
// import '../../../utils/fonts.dart';
// import '../../../utils/services/api_helper.dart';
// import '../../../widget/videoPlayerWidget.dart';
// import '../../CustomText.dart';
// import '../../RemcommendedViewAllScreen.dart';
// import '../../astromall/astroProductScreen.dart';
// import '../../call/hms/HMSLiveScreen.dart';
// import '../../callIntakeFormScreen.dart';
// import '../../chatScreen.dart';
// import '../../chatwithAI/aichatscreen.dart';
// import '../../chatwithAI/controllers/aiChatController.dart';
// import '../../daily_horoscope/dailyHoroscopeScreen.dart';
// import '../../poojaBooking/controller/poojaController.dart';
// import '../../poojaBooking/screen/PujaCategoryScreen.dart';
// import '../../poojaBooking/screen/addpoojadeveryaddress.dart';

// class HomeScreen extends StatefulWidget {
//   final KundliModel? userDetails;
//   HomeScreen({a, o, this.userDetails}) : super();
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final homeController = Get.find<HomeController>();
//   final astrologerCategoryController = Get.find<AstrologerCategoryController>();
//   final bottomControllerMain = Get.find<BottomNavigationController>();
//   final liveController = Get.find<LiveController>();
//   final kundliController = Get.find<KundliController>();
//   final panchangController = Get.find<PanchangController>();
//   final splashController = Get.find<SplashController>();
//   final walletController = Get.find<WalletController>();
//   final astromallController = Get.find<AstromallController>();
//   final callController = Get.find<CallController>();
//   final bottomNavigationController = Get.find<BottomNavigationController>();
//   final chatController = Get.find<ChatController>();
//   final aicontroller = Get.put(AiChatController());
//   final pujaController = Get.find<PoojaController>();
//   final apiHelper = APIHelper();
//   final historyController = Get.find<HistoryController>();
//   final walletcontroller = Get.find<WalletController>();

//   List<Color> listcolor = [
//     Colors.red.shade50,
//     Colors.green.shade50,
//     Colors.blue.shade50,
//   ];

//   final pageController = PageController(viewportFraction: 0.75, initialPage: 2);
//   ValueNotifier<int> viewer = ValueNotifier<int>(0);
//   Timer? autoScrollTimer;

//   @override
//   void initState() {
//     super.initState();
//     print('user id ${global.user.id}');
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       fetchAppVersion();
//       pageController.addListener(() {
//         currentPage.value = pageController.page!;
//       });
//       Future.wait<void>([
//         homeController.getAllStories(),
//         homeController.gethistorydetails(),
//         pujaController.getCustomPujaList(),
//       ]);
//     });
//     startAutoScroll();
//     _initDialog();
//   }

//   void _initDialog() {
//     bool? isProfileUpdated = global.sp!.getBool("isProfileUpdated") ?? false;
//     debugPrint("Complete Profile From HomeDesing default$isProfileUpdated");
//     if (!isProfileUpdated) {
//       Future.delayed(const Duration(seconds: 15), () {
//         if (mounted) {
//           showCompleteProfileDialog(context);
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     autoScrollTimer?.cancel();
//     pageController.dispose();
//     viewer.dispose();
//     super.dispose();
//   }

//   void startAutoScroll() {
//     autoScrollTimer = Timer.periodic(Duration(seconds: 4), (_) {
//       if (!pageController.hasClients) return;
//       int nextPage = (viewer.value + 1) % homeController.bannerList.length;
//       pageController.animateToPage(
//         nextPage,
//         duration: Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     });
//   }

//   Future fetchAppVersion() async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     String myappLocalversion =
//         global.getSystemFlagValueForLogin(global.systemFlagNameList.appVersion);
//     print('appversion from web is $myappLocalversion');
//     print('appversion from device local is ${packageInfo.version}');
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     DateTime lastCheckedTime = DateTime.fromMillisecondsSinceEpoch(
//         prefs.getInt('lastUpdateCheck') ?? 0);
//     // Check if 24 hours have passed since the last check
//     if (DateTime.now().difference(lastCheckedTime).inHours >= 24) {
//       if (_isUpdateAvailable(myappLocalversion, packageInfo.version)) {
//         showCommonDialog(
//           title: "Update Available",
//           subtitle:
//               "A new version (${global.getSystemFlagValueForLogin(global.systemFlagNameList.appVersion)}) is available. Please update.",
//           primaryButtonText: "Update",
//           secondaryButtonText: "Later",
//           onPrimaryPressed: () async {
//             final appUrl = Platform.isAndroid
//                 ? "https://play.google.com/store/apps/details?id=${global.getSystemFlagValueForLogin(global.systemFlagNameList.androidpackage)}"
//                 : "https://apps.apple.com/app/${global.getSystemFlagValueForLogin(global.systemFlagNameList.iOSpackage)}";
//             if (await canLaunch(appUrl)) {
//               await launch(appUrl);
//               Get.back();
//             } else {
//               throw "Could not launch $appUrl";
//             }
//           },
//           onSecondaryPressed: () {
//             Get.back();
//           },
//         );
//         prefs.setInt('lastUpdateCheck', DateTime.now().millisecondsSinceEpoch);
//       }
//     }
//   }

//   void showUpdateDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text("Update Available",
//             style: TextStyle(color: Colors.black, fontSize: 22.sp)),
//         content: Text(
//             "A new version (${global.getSystemFlagValueForLogin(global.systemFlagNameList.appVersion)}) is available. Please update."),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text("Later",
//                 style: TextStyle(color: Colors.red, fontSize: 16.sp)),
//           ),
//           TextButton(
//             onPressed: () async {
//               print(
//                   'android packagename is ${global.getSystemFlagValueForLogin(global.systemFlagNameList.androidpackage)}');
//               print(
//                   'ios packagename is ${global.getSystemFlagValueForLogin(global.systemFlagNameList.iOSpackage)}');

//               final appUrl = Platform.isAndroid
//                   ? "https://play.google.com/store/apps/details?id=${global.getSystemFlagValueForLogin(global.systemFlagNameList.androidpackage)}"
//                   : "https://apps.apple.com/app/${global.getSystemFlagValueForLogin(global.systemFlagNameList.iOSpackage)}";

//               if (await canLaunch(appUrl)) {
//                 await launch(appUrl);
//                 Get.back();
//               } else {
//                 throw "Could not launch $appUrl";
//               }
//             },
//             child: Text("Update Now",
//                 style: TextStyle(color: Colors.red, fontSize: 16.sp)),
//           ),
//         ],
//       ),
//     );
//   }

//   bool _isUpdateAvailable(String webVersion, String localVersion) {
//     List<int> webVer = webVersion.split('.').map(int.parse).toList();
//     List<int> localVer = localVersion.split('.').map(int.parse).toList();

//     for (int i = 0; i < webVer.length; i++) {
//       if (webVer[i] > localVer[i]) return true;
//       if (webVer[i] < localVer[i]) return false;
//     }
//     return false;
//   }

//   void _logedIn(context, isLogin, index, audio, dynamic charge) async {
//     if (isLogin) {
//       if (bottomNavigationController.astrologerList[index].call_sections
//               .toString() ==
//           "0") {
//         Get.snackbar("Note",
//             "${global.getSystemFlagValueForLogin(global.systemFlagNameList.professionTitle)} disabled Call",
//             backgroundColor: Colors.orange, colorText: Colors.white);
//       } else {
//         //_checkAstrologerAvailability(index);
//         await bottomNavigationController.getAstrologerbyId(
//             bottomNavigationController.astrologerList[index].id);
//         print(
//             'charge${global.splashController.currentUser!.walletAmount! * 5}');
//         if (double.parse(charge.toString()) * 5.0 <=
//                 double.parse(global.splashController.currentUser!.walletAmount!
//                     .toString()) ||
//             bottomNavigationController.astrologerList[index].isFreeAvailable ==
//                 true) {
//           await bottomNavigationController.checkAlreadyInReqForCall(
//               bottomNavigationController.astrologerList[index].id);
//           if (bottomNavigationController.isUserAlreadyInCallReq == false) {
//             if (bottomNavigationController.astrologerList[index].callStatus ==
//                 "Online") {
//               global.showOnlyLoaderDialog(context);

//               await Get.to(() => CallIntakeFormScreen(
//                     astrologerProfile: bottomNavigationController
//                         .astrologerList[index].profileImage
//                         .toString(),
//                     type: audio ? "Call" : "Videocall",
//                     astrologerId:
//                         bottomNavigationController.astrologerList[index].id,
//                     astrologerName: bottomNavigationController
//                         .astrologerList[index].name
//                         .toString(),
//                     isFreeAvailable: bottomNavigationController
//                         .astrologerList[index].isFreeAvailable,
//                     rate: audio
//                         ? bottomNavigationController
//                             .astrologerList[index].charge
//                             .toString()
//                         : bottomNavigationController
//                             .astrologerList[index].videoCallRate
//                             .toString(),
//                   ));

//               global.hideLoader();
//             } else if (bottomNavigationController
//                         .astrologerList[index].callStatus ==
//                     "Offline" ||
//                 bottomNavigationController.astrologerList[index].callStatus ==
//                     "Busy" ||
//                 bottomNavigationController.astrologerList[index].callStatus ==
//                     "Wait Time") {
//               bottomNavigationController.dialogForJoinInWaitList(
//                   context,
//                   bottomNavigationController.astrologerList[index].name
//                       .toString(),
//                   true,
//                   charge.toString(),
//                   bottomNavigationController.astrologerList[index].profileImage
//                       .toString());
//             }
//           } else {
//             bottomNavigationController.dialogForNotCreatingSession(context);
//           }
//         } else {
//           global.showOnlyLoaderDialog(context);
//           await walletController.getAmount();
//           global.hideLoader();
//           openBottomSheetRechrage(context, (charge * 5).toString(),
//               '${bottomNavigationController.astrologerList[index].name}');
//         }
//       }
//     }
//   }

//   void openBottomSheetRechrage(
//       BuildContext context, String minBalance, String astrologer) {
//     Get.bottomSheet(
//       Container(
//         height: 40.h,
//         width: MediaQuery.of(context).size.width,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   SizedBox(
//                                     width: Get.width * 0.85,
//                                     child: minBalance != ''
//                                         ? Text('Minimum balance of 5 minutes(${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} $minBalance) is required to start call with $astrologer ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.w500,
//                                                     fontFamily:
//                                                         'Poppins-Regular',
//                                                     color: Colors.red))
//                                             .tr()
//                                         : const SizedBox(),
//                                   ),
//                                   GestureDetector(
//                                     child: Padding(
//                                       padding: minBalance == ''
//                                           ? const EdgeInsets.only(top: 8)
//                                           : const EdgeInsets.only(top: 0),
//                                       child: Icon(Icons.close, size: 18),
//                                     ),
//                                     onTap: () {
//                                       Get.back();
//                                     },
//                                   ),
//                                 ],
//                               ),
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.only(top: 8.0, bottom: 5),
//                                 child: Text('Recharge Now',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.w500))
//                                     .tr(),
//                               ),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(right: 5),
//                                     child: Icon(Icons.lightbulb_rounded,
//                                         color: Get.theme.primaryColor,
//                                         size: 13),
//                                   ),
//                                   Expanded(
//                                       child: Text(
//                                           'Minimum balance required ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} $minBalance',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             fontFamily: 'Poppins-Regular',
//                                           )).tr())
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//                 child: GridView.builder(
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 3.8 / 2.3,
//                       crossAxisSpacing: 1,
//                       mainAxisSpacing: 1,
//                     ),
//                     physics: NeverScrollableScrollPhysics(),
//                     padding: EdgeInsets.all(8),
//                     shrinkWrap: true,
//                     itemCount: walletController.rechrage.length,
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () {
//                           Get.to(() => PaymentInformationScreen(
//                               flag: 0,
//                               amount: double.parse(
//                                   walletController.payment[index])));
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.all(8.0),
//                           child: Container(
//                             height: 30,
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey),
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: Center(
//                                 child: Text(
//                               '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${walletController.rechrage[index]}',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 fontFamily: 'Poppins-Regular',
//                               ),
//                             )),
//                           ),
//                         ),
//                       );
//                     }))
//           ],
//         ),
//       ),
//       barrierColor: Colors.black.withOpacity(0.8),
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(10),
//           topRight: Radius.circular(10),
//         ),
//       ),
//     );
//   }

//   ValueNotifier<double> currentPage = ValueNotifier<double>(0.0);

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         bool isExit = await homeController.onBackPressed();
//         if (isExit) {
//           exit(0);
//         }
//         return isExit;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.lightBlueAccent,
//         body: RefreshIndicator(
//           onRefresh: () async {
//             await Future.wait<void>([
//               homeController.getBanner(),
//               homeController.getBlog(),
//               homeController.getAstroNews(),
//               homeController.getMyOrder(),
//               homeController.getAstrologyVideos(),
//               homeController.getClientsTestimonals(),
//               homeController.getAllStories(),
//               homeController.getrecomendedProductList(),
//               homeController.getrecomendedPujaList(),
//               bottomControllerMain.getLiveAstrologerList(),
//               astromallController.getAstromallCategory(false),
//               global.splashController.getCurrentUserData(),
//               walletController.getAmount(),
//               bottomNavigationController.getAstrologerList(
//                   isLazyLoading: true, isShuffle: false),
//               pujaController.getCustomPujaList(),
//             ]);
//           },
//           child: GetBuilder<BottomNavigationController>(
//               builder: (bottomController) {
//             debugPrint(
//                 'design number ${global.getSystemFlagValueForLogin(global.systemFlagNameList.appDesignId)}');
//             return Stack(
//               alignment: Alignment.bottomCenter,
//               children: [
//                 SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ///freeservice
//                       Card(
//                         elevation: 0,
//                         margin: EdgeInsets.all(0),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.zero,
//                         ),
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(
//                                 vertical: 15, horizontal: 4.w),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   children: [
//                                     GetBuilder<KundliController>(
//                                       builder: (kundliController) {
//                                         return GestureDetector(
//                                           onTap: () async {
//                                             bool isLogin =
//                                                 await global.isLogin();
//                                             if (isLogin) {
//                                               Get.to(
//                                                   () => PujaCategoryScreen());
//                                             }
//                                           },
//                                           child: Container(
//                                             height: 11.h,
//                                             width: 11.h,
//                                             decoration: BoxDecoration(
//                                               color: const Color.fromARGB(
//                                                   255, 203, 221, 241),
//                                               borderRadius:
//                                                   BorderRadius.circular(2.w),
//                                               border: Border.all(
//                                                 width: 0.3,
//                                                 color: const Color(0xFFffe8e5),
//                                               ),
//                                             ),
//                                             child: Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 /// Image with Shimmer effect
//                                                 CachedNetworkImage(
//                                                   height: 5.h,
//                                                   width: 6.h,
//                                                   imageUrl: global.buildImageUrl(
//                                                       '${global.getSystemFlagValueForLogin(global.systemFlagNameList.puja)}'),
//                                                   errorWidget:
//                                                       (context, url, error) =>
//                                                           const Icon(
//                                                               Icons.no_accounts,
//                                                               size: 20),
//                                                   placeholder: (context, url) =>
//                                                       Center(
//                                                           child: Skeletonizer(
//                                                     enabled: true,
//                                                     child: Container(
//                                                       height: 5.h,
//                                                       width: 6.h,
//                                                       color: Colors.white,
//                                                     ),
//                                                   )),
//                                                 ),

//                                                 SizedBox(height: 1.w),

//                                                 /// Text with Shimmer effect
//                                                 Text(
//                                                   'Puja\nBooking',
//                                                   textAlign: TextAlign.center,
//                                                   style: Get.theme.textTheme
//                                                       .titleSmall!
//                                                       .copyWith(
//                                                     height: 1,
//                                                     fontSize: 15.sp,
//                                                     fontWeight: FontWeight.w400,
//                                                     letterSpacing: 0,
//                                                     color: Colors.black,
//                                                   ),
//                                                 ).tr(),
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(width: 5),
//                                 Column(
//                                   children: [
//                                     GestureDetector(
//                                       onTap: () async {
//                                         Get.find<DailyHoroscopeController>()
//                                             .selectZodic(0);
//                                         await Get.find<
//                                                 DailyHoroscopeController>()
//                                             .getHoroscopeList(
//                                                 horoscopeId: Get.find<
//                                                             DailyHoroscopeController>()
//                                                         .signId ??
//                                                     13);
//                                         Get.to(() => DailyHoroscopeScreen());
//                                       },
//                                       child: Container(
//                                           height: 11.h,
//                                           width: 11.h,
//                                           decoration: BoxDecoration(
//                                               border: Border.all(
//                                                   width: 0.3,
//                                                   color:
//                                                       Get.theme.primaryColor),
//                                               color: Color(0xFFfff7df),
//                                               borderRadius:
//                                                   BorderRadius.circular(2.w)),
//                                           child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Center(
//                                                 child: SizedBox(
//                                                   height: 5.h,
//                                                   width: 5.h,
//                                                   child: ClipRRect(
//                                                     clipBehavior: Clip.none,
//                                                     child: CachedNetworkImage(
//                                                       imageUrl:
//                                                           global.buildImageUrl(
//                                                               '${global.getSystemFlagValueForLogin(global.systemFlagNameList.dailyHoroscope)}'),
//                                                       errorWidget: (context,
//                                                               url, error) =>
//                                                           Icon(
//                                                               Icons.no_accounts,
//                                                               size: 20),
//                                                       placeholder: (context,
//                                                               url) =>
//                                                           Center(
//                                                               child:
//                                                                   Skeletonizer(
//                                                         enabled: true,
//                                                         child: Container(
//                                                           height: 5.h,
//                                                           width: 5.h,
//                                                           color: Colors.white,
//                                                         ),
//                                                       )),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(height: 1.w),
//                                               Text(
//                                                 'Daily\nHoroscope',
//                                                 textAlign: TextAlign.center,
//                                                 style: Get
//                                                     .theme.textTheme.titleSmall!
//                                                     .copyWith(
//                                                   height: 1,
//                                                   fontSize: 15.sp,
//                                                   fontWeight: FontWeight.w400,
//                                                   letterSpacing: 0,
//                                                 ),
//                                               ).tr(),
//                                             ],
//                                           )),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(width: 5),
//                                 Column(
//                                   children: [
//                                     GetBuilder<KundliController>(
//                                         builder: (kundliController) {
//                                       return GestureDetector(
//                                           onTap: () async {
//                                             bool isLogin =
//                                                 await global.isLogin();
//                                             if (isLogin) {
//                                               global.showOnlyLoaderDialog(
//                                                   Get.context);
//                                               await kundliController
//                                                   .getKundliList();
//                                               global.hideLoader();
//                                               Get.to(() => KundaliScreen());
//                                             }
//                                           },
//                                           child: Container(
//                                             height: 11.h,
//                                             width: 11.h,
//                                             decoration: BoxDecoration(
//                                                 border: Border.all(
//                                                     width: 0.3,
//                                                     color:
//                                                         Get.theme.primaryColor),
//                                                 color: Color(0xFFffe8e5),
//                                                 borderRadius:
//                                                     BorderRadius.circular(2.w)),
//                                             child: Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 CachedNetworkImage(
//                                                   height: 5.h,
//                                                   width: 5.h,
//                                                   imageUrl: global.buildImageUrl(
//                                                       '${global.getSystemFlagValueForLogin(global.systemFlagNameList.freeKundli)}'),
//                                                   errorWidget: (context, url,
//                                                           error) =>
//                                                       Icon(Icons.no_accounts,
//                                                           size: 20),
//                                                   placeholder: (context, url) =>
//                                                       Center(
//                                                           child: Skeletonizer(
//                                                     enabled: true,
//                                                     child: Container(
//                                                       height: 5.h,
//                                                       width: 5.h,
//                                                       color: Colors.white,
//                                                     ),
//                                                   )),
//                                                 ),
//                                                 SizedBox(height: 1.w),
//                                                 Text(
//                                                   'Free\nKundali',
//                                                   textAlign: TextAlign.center,
//                                                   style: Get.theme.textTheme
//                                                       .titleSmall!
//                                                       .copyWith(
//                                                     height: 1,
//                                                     fontSize: 15.sp,
//                                                     fontWeight: FontWeight.w400,
//                                                     letterSpacing: 0,
//                                                   ),
//                                                 ).tr(),
//                                               ],
//                                             ),
//                                           ));
//                                     }),
//                                   ],
//                                 ),
//                                 SizedBox(width: 5),
//                                 Column(
//                                   children: [
//                                     GetBuilder<KundliController>(
//                                         builder: (kundliController) {
//                                       return GestureDetector(
//                                           onTap: () async {
//                                             bool isLogin =
//                                                 await global.isLogin();
//                                             if (isLogin) {
//                                               global.showOnlyLoaderDialog(
//                                                   Get.context);
//                                               await kundliController
//                                                   .getKundliList();
//                                               global.hideLoader();
//                                               Get.to(
//                                                   () => KundliMatchingScreen());
//                                             }
//                                           },
//                                           child: Container(
//                                             height: 11.h,
//                                             width: 11.h,
//                                             decoration: BoxDecoration(
//                                                 border: Border.all(
//                                                     width: 0.3,
//                                                     color:
//                                                         Get.theme.primaryColor),
//                                                 color: Color(0xFFe7ffdf),
//                                                 borderRadius:
//                                                     BorderRadius.circular(2.w)),
//                                             child: Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 CachedNetworkImage(
//                                                   height: 5.h,
//                                                   width: 5.h,
//                                                   imageUrl: global.buildImageUrl(
//                                                       '${global.getSystemFlagValueForLogin(global.systemFlagNameList.kundliMatching)}'),
//                                                   errorWidget: (context, url,
//                                                           error) =>
//                                                       Icon(Icons.no_accounts,
//                                                           size: 20),
//                                                   placeholder: (context, url) =>
//                                                       Center(
//                                                           child: Skeletonizer(
//                                                     enabled: true,
//                                                     child: Container(
//                                                       height: 5.h,
//                                                       width: 5.h,
//                                                       color: Colors.white,
//                                                     ),
//                                                   )),
//                                                 ),
//                                                 SizedBox(height: 1.w),
//                                                 Text(
//                                                   'Kundali\nMatching',
//                                                   textAlign: TextAlign.center,
//                                                   style: Get.theme.textTheme
//                                                       .titleSmall!
//                                                       .copyWith(
//                                                     height: 1,
//                                                     fontSize: 15.sp,
//                                                     fontWeight: FontWeight.w400,
//                                                     letterSpacing: 0,
//                                                   ),
//                                                 ).tr(),
//                                               ],
//                                             ),
//                                           ));
//                                     }),
//                                   ],
//                                 ),
//                                 SizedBox(width: 5),
//                                 Column(
//                                   children: [
//                                     GestureDetector(
//                                       onTap: () async {
//                                         DateTime dateBasic = DateTime.now();
//                                         int formattedYear = int.parse(
//                                             DateFormat('yyyy')
//                                                 .format(dateBasic));
//                                         int formattedDay = int.parse(
//                                             DateFormat('dd').format(dateBasic));
//                                         int formattedMonth = int.parse(
//                                             DateFormat('MM').format(dateBasic));
//                                         int formattedHour = int.parse(
//                                             DateFormat('HH').format(dateBasic));
//                                         int formattedMint = int.parse(
//                                             DateFormat('mm').format(dateBasic));

//                                         bool logedin = await global.isLogin();
//                                         if (logedin) {
//                                           String? ipadddress = await apiHelper
//                                               .getPublicIPAddress();
//                                           global.showOnlyLoaderDialog(context);
//                                           await kundliController
//                                               .getBasicPanchangDetail(
//                                                   day: formattedDay,
//                                                   hour: formattedHour,
//                                                   min: formattedMint,
//                                                   month: formattedMonth,
//                                                   year: formattedYear,
//                                                   lat: 21.1255,
//                                                   lon: 73.1122,
//                                                   tzone: 5);
//                                           panchangController.getPanchangVedic(
//                                               DateTime.now(), ipadddress);
//                                           global.hideLoader();
//                                           Get.to(() => PanchangScreen());
//                                         }
//                                       },
//                                       child: Container(
//                                         height: 11.h,
//                                         width: 11.h,
//                                         decoration: BoxDecoration(
//                                             border: Border.all(
//                                                 width: 0.3,
//                                                 color: Get.theme.primaryColor),
//                                             color: Color(0xFFfff7df),
//                                             borderRadius:
//                                                 BorderRadius.circular(2.w)),
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             CachedNetworkImage(
//                                               height: 5.h,
//                                               width: 5.h,
//                                               imageUrl: global.buildImageUrl(
//                                                   '${global.getSystemFlagValueForLogin(global.systemFlagNameList.todayPanchang)}'),
//                                               errorWidget:
//                                                   (context, url, error) => Icon(
//                                                       Icons.no_accounts,
//                                                       size: 20),
//                                               placeholder: (context, url) =>
//                                                   Center(
//                                                       child: Skeletonizer(
//                                                 enabled: true,
//                                                 child: Container(
//                                                   height: 5.h,
//                                                   width: 5.h,
//                                                   color: Colors.white,
//                                                 ),
//                                               )),
//                                             ),
//                                             SizedBox(height: 1.w),
//                                             Text(
//                                               'Panchang',
//                                               textAlign: TextAlign.center,
//                                               style: Get
//                                                   .theme.textTheme.titleSmall!
//                                                   .copyWith(
//                                                 height: 1,
//                                                 fontSize: 15.sp,
//                                                 fontWeight: FontWeight.w400,
//                                                 letterSpacing: 0,
//                                               ),
//                                             ).tr(),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),

//                       ///Stories

//                       SizedBox(height: 1.h),
//                       GetBuilder<HomeController>(builder: (homeController) {
//                         return Column(
//                           children: [
//                             homeController.allStories.length == 0
//                                 ? SizedBox()
//                                 : Container(
//                                     margin: EdgeInsets.only(left: 10),
//                                     height: 100,
//                                     child: ListView.builder(
//                                         shrinkWrap: false,
//                                         itemCount:
//                                             homeController.allStories.length,
//                                         scrollDirection: Axis.horizontal,
//                                         itemBuilder: (context, index) {
//                                           return Container(
//                                             margin: EdgeInsets.only(left: 4),
//                                             alignment: Alignment.center,
//                                             child: InkWell(
//                                                 onTap: () {
//                                                   homeController
//                                                       .getAstroStory(
//                                                           homeController
//                                                               .allStories[index]
//                                                               .astrologerId
//                                                               .toString())
//                                                       .then((value) {
//                                                     Get.to(() =>
//                                                         ViewStoriesScreen(
//                                                           profile:
//                                                               "${homeController.allStories[index].profileImage}",
//                                                           name: homeController
//                                                               .allStories[index]
//                                                               .name
//                                                               .toString(),
//                                                           isprofile: false,
//                                                           astroId: int.parse(
//                                                               homeController
//                                                                   .allStories[
//                                                                       index]
//                                                                   .astrologerId
//                                                                   .toString()),
//                                                         ));
//                                                   });
//                                                 },
//                                                 child: Column(
//                                                   children: [
//                                                     CircleAvatar(
//                                                       radius: 30,
//                                                       backgroundColor: homeController
//                                                                   .allStories[
//                                                                       index]
//                                                                   .allStoriesViewed
//                                                                   .toString() ==
//                                                               "1"
//                                                           ? Colors.grey
//                                                           : Colors.green,
//                                                       child: homeController
//                                                                       .allStories[
//                                                                           index]
//                                                                       .profileImage !=
//                                                                   null &&
//                                                               homeController
//                                                                   .allStories[
//                                                                       index]
//                                                                   .profileImage!
//                                                                   .isNotEmpty
//                                                           ? CircleAvatar(
//                                                               radius: 27,
//                                                               backgroundColor: Get
//                                                                   .theme
//                                                                   .primaryColor,
//                                                               backgroundImage:
//                                                                   NetworkImage(
//                                                                       "${homeController.allStories[index].profileImage}"),
//                                                             )
//                                                           : CircleAvatar(
//                                                               radius: 27,
//                                                               backgroundColor:
//                                                                   Colors.white,
//                                                               backgroundImage:
//                                                                   AssetImage(
//                                                                 Images
//                                                                     .deafultUser,
//                                                               ),
//                                                             ),
//                                                     ),
//                                                     Container(
//                                                       alignment:
//                                                           Alignment.center,
//                                                       width: 16.w,
//                                                       child: Text(
//                                                         textAlign:
//                                                             TextAlign.center,
//                                                         homeController
//                                                             .allStories[index]
//                                                             .name
//                                                             .toString(),
//                                                         maxLines: 2,
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                         style: TextStyle(
//                                                             fontSize: 15.sp),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 )),
//                                           );
//                                         }),
//                                   ),
//                           ],
//                         );
//                       }),
//                       SizedBox(
//                         height: 1.h,
//                       ),

//                       // Custom puja modeule
//                       GetBuilder<PoojaController>(
//                         builder: (pujaController) {
//                           return Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               pujaController.custompoojalist == null ||
//                                       pujaController.custompoojalist!.isEmpty
//                                   ? SizedBox()
//                                   : Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         pujaController.custompoojalist ==
//                                                     null ||
//                                                 pujaController
//                                                     .custompoojalist!.isEmpty
//                                             ? SizedBox()
//                                             : Padding(
//                                                 padding: EdgeInsets.symmetric(
//                                                     horizontal: 5.w,
//                                                     vertical: 1),
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     Text(
//                                                       'Suggested Puja',
//                                                       style: Get
//                                                           .theme
//                                                           .primaryTextTheme
//                                                           .titleMedium!
//                                                           .copyWith(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w500),
//                                                     ).tr(),
//                                                   ],
//                                                 ),
//                                               ),
//                                         SizedBox(height: 1.h),
//                                         Container(
//                                           height: 20.h,
//                                           margin: EdgeInsets.only(left: 2.w),
//                                           padding: EdgeInsets.all(2.w),
//                                           child: ListView.builder(
//                                             itemCount: pujaController
//                                                 .custompoojalist?.length,
//                                             scrollDirection: Axis.horizontal,
//                                             itemBuilder: (context, index) {
//                                               final puja = pujaController
//                                                   .custompoojalist![index];
//                                               return Container(
//                                                 width: 60.w,
//                                                 padding: EdgeInsets.all(10),
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.white,
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                   border: Border.all(
//                                                       color:
//                                                           Colors.grey.shade300),
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Colors.grey
//                                                           .withOpacity(0.3),
//                                                       blurRadius: 6,
//                                                       offset: Offset(0, 4),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     // Top Row: Title + Icons
//                                                     Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceBetween,
//                                                       children: [
//                                                         Expanded(
//                                                           child: Text(
//                                                             puja.pujaTitle ??
//                                                                 'No Title',
//                                                             style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                               fontSize: 14,
//                                                             ),
//                                                             maxLines: 1,
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                           ),
//                                                         ),
//                                                         Row(
//                                                           children: [
//                                                             // Accept Icon
//                                                             InkWell(
//                                                               onTap: () async {
//                                                                 // Handle purchase here
//                                                                 Get.to(
//                                                                   () =>
//                                                                       AddPoojaDeliveryAddress(
//                                                                     selectedpackage:
//                                                                         null,
//                                                                     poojadetail:
//                                                                         pujaController
//                                                                             .custompoojalist![index],
//                                                                     index:
//                                                                         index,
//                                                                     isfrommycustomproduct:
//                                                                         true,
//                                                                   ),
//                                                                 );
//                                                               },
//                                                               child: Icon(
//                                                                   Icons
//                                                                       .check_circle,
//                                                                   color: Colors
//                                                                       .green),
//                                                             ),
//                                                             SizedBox(width: 6),
//                                                             // Delete Icon
//                                                             InkWell(
//                                                               onTap: () {
//                                                                 showDialog(
//                                                                   context:
//                                                                       context,
//                                                                   builder:
//                                                                       (context) =>
//                                                                           AlertDialog(
//                                                                     title: Text(
//                                                                         "Confirm Deletion"),
//                                                                     content: Text(
//                                                                         "Are you sure you want to delete this pooja?"),
//                                                                     actions: [
//                                                                       TextButton(
//                                                                         onPressed:
//                                                                             () =>
//                                                                                 Navigator.pop(context), // Close the dialog
//                                                                         child: Text(
//                                                                             "Cancel"),
//                                                                       ),
//                                                                       TextButton(
//                                                                         onPressed:
//                                                                             () {
//                                                                           pujaController.deletePooja(pujaController
//                                                                               .custompoojalist![index]
//                                                                               .pujaSuggestedId);
//                                                                           Get.back();
//                                                                           log('removed clicked ${pujaController.custompoojalist![index].id}');
//                                                                         },
//                                                                         child: Text(
//                                                                             "Delete",
//                                                                             style:
//                                                                                 TextStyle(color: Colors.red)),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 );
//                                                               },
//                                                               child: Icon(
//                                                                   Icons.cancel,
//                                                                   color: Colors
//                                                                       .red),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),

//                                                     SizedBox(height: 8),

//                                                     // Price
//                                                     Text(
//                                                       'Price: ₹${puja.pujaPrice ?? 'N/A'}',
//                                                       style: TextStyle(
//                                                         color: Colors.black87,
//                                                         fontWeight:
//                                                             FontWeight.w600,
//                                                       ),
//                                                     ),

//                                                     SizedBox(height: 6),
//                                                     Text(
//                                                       'Start Date: ${puja.pujaStartDatetime}',
//                                                       style: TextStyle(
//                                                           fontSize: 12,
//                                                           color:
//                                                               Colors.black45),
//                                                     ),

//                                                     // Astrologer name
//                                                     Text(
//                                                       'By ${puja.astrologername ?? 'Astrologer'}',
//                                                       style: TextStyle(
//                                                           fontSize: 12,
//                                                           color: Colors.grey),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                             ],
//                           );
//                         },
//                       ),

//                       //    --------------------------------------TOP BANNER-----------------------------------------------------------------------------

//                       GetBuilder<HomeController>(
//                         builder: (homeController) {
//                           return homeController.bannerList.isEmpty
//                               ? const SizedBox()
//                               : ValueListenableBuilder<double>(
//                                   valueListenable: currentPage,
//                                   builder: (context, value, _) {
//                                     return Container(
//                                       // margin: const EdgeInsets.symmetric(
//                                       //     horizontal: 10),
//                                       height: 25.h,
//                                       child: Stack(
//                                         children: [
//                                           PageView.builder(
//                                             controller: pageController,
//                                             itemCount: homeController
//                                                 .bannerList.length,
//                                             onPageChanged: (index) {
//                                               viewer.value = index;
//                                             },
//                                             itemBuilder: (context, index) {
//                                               final scale =
//                                                   (1 - (value - index).abs())
//                                                       .clamp(0.96, 1.6);
//                                               final banner = homeController
//                                                   .bannerList[index];
//                                               return Transform.scale(
//                                                 scale: scale,
//                                                 child: GestureDetector(
//                                                   onTap: () async {
//                                                     if (banner.bannerType ==
//                                                         'Astrologer') {
//                                                       global
//                                                           .showOnlyLoaderDialog(
//                                                               context);
//                                                       bottomController
//                                                           .astrologerList
//                                                           .clear();
//                                                       bottomController
//                                                               .isAllDataLoaded =
//                                                           false;
//                                                       bottomController.update();
//                                                       await bottomController
//                                                           .getAstrologerList(
//                                                               isLazyLoading:
//                                                                   false);
//                                                       global.hideLoader();
//                                                       bottomController
//                                                           .persistentTabController!
//                                                           .jumpToTab(1);
//                                                     } else if (banner
//                                                             .bannerType ==
//                                                         'Astroshop') {
//                                                       final AstromallController
//                                                           astromallController =
//                                                           Get.find<
//                                                               AstromallController>();
//                                                       astromallController
//                                                           .astroCategory
//                                                           .clear();
//                                                       astromallController
//                                                               .isAllDataLoaded =
//                                                           false;
//                                                       astromallController
//                                                           .update();
//                                                       global
//                                                           .showOnlyLoaderDialog(
//                                                               context);
//                                                       await astromallController
//                                                           .getAstromallCategory(
//                                                               false);
//                                                       global.hideLoader();
//                                                       Get.to(() =>
//                                                           AstromallScreen());
//                                                     }
//                                                   },
//                                                   child: CachedNetworkImage(
//                                                     imageUrl: global.buildImageUrl(
//                                                         '${banner.bannerImage}'),
//                                                     imageBuilder: (context,
//                                                         imageProvider) {
//                                                       return homeController
//                                                               .checkBannerValid(
//                                                         startDate:
//                                                             banner.fromDate,
//                                                         endDate: banner.toDate,
//                                                       )
//                                                           ? Card(
//                                                               child: Container(
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               10),
//                                                                   image:
//                                                                       DecorationImage(
//                                                                     fit: BoxFit
//                                                                         .cover,
//                                                                     image:
//                                                                         imageProvider,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             )
//                                                           : Container(
//                                                               color:
//                                                                   Colors.green);
//                                                     },
//                                                     placeholder:
//                                                         (context, url) =>
//                                                             Skeletonizer(
//                                                       enabled: true,
//                                                       child: Container(
//                                                         height: 25.h,
//                                                         width: double.infinity,
//                                                       ),
//                                                     ),
//                                                     errorWidget:
//                                                         (context, url, error) =>
//                                                             Card(
//                                                       child: Container(
//                                                         color: Colors
//                                                             .grey.shade400,
//                                                         child: Center(
//                                                           child: Column(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .center,
//                                                             children: [
//                                                               Icon(Icons.error,
//                                                                   color: Colors
//                                                                       .red,
//                                                                   size: 30.sp),
//                                                               Text(
//                                                                 'banner Loading error',
//                                                                 style: TextStyle(
//                                                                     fontSize:
//                                                                         14.sp,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w400),
//                                                               )
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                           ),

//                                           // Optional: Dot Indicator
//                                           Positioned(
//                                             bottom: 8,
//                                             left: 0,
//                                             right: 0,
//                                             child: ValueListenableBuilder<int>(
//                                               valueListenable: viewer,
//                                               builder: (context, value, _) {
//                                                 return Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: List.generate(
//                                                     homeController
//                                                         .bannerList.length,
//                                                     (index) => Container(
//                                                       margin: const EdgeInsets
//                                                           .symmetric(
//                                                           horizontal: 2),
//                                                       width: value == index
//                                                           ? 10
//                                                           : 6,
//                                                       height: value == index
//                                                           ? 10
//                                                           : 6,
//                                                       decoration: BoxDecoration(
//                                                         color: value == index
//                                                             ? Colors.white
//                                                             : Colors.grey,
//                                                         shape: BoxShape.circle,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 );
//                                               },
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   });
//                         },
//                       ),

//                       // --------------------------------------MY ORDER---------------------------------

//                       GetBuilder<HomeController>(builder: (homeController) {
//                         return homeController.myOrders.isEmpty
//                             ? const SizedBox()
//                             : SizedBox(
//                                 height: 160,
//                                 child: Card(
//                                   elevation: 0,
//                                   margin: EdgeInsets.only(top: 6),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.zero),
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 10),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 10),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Text(
//                                                     'My orders',
//                                                     style: Get
//                                                         .theme
//                                                         .primaryTextTheme
//                                                         .titleMedium!
//                                                         .copyWith(
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .w500),
//                                                   ).tr(),
//                                                 ],
//                                               ),
//                                               GestureDetector(
//                                                 onTap: () async {
//                                                   final HistoryController
//                                                       historyController =
//                                                       Get.find<
//                                                           HistoryController>();
//                                                   global.showOnlyLoaderDialog(
//                                                       context);
//                                                   historyController
//                                                       .chatHistoryList = [];
//                                                   historyController
//                                                       .chatHistoryList
//                                                       .clear();
//                                                   historyController
//                                                           .chatAllDataLoaded =
//                                                       false;
//                                                   historyController.update();
//                                                   await historyController
//                                                       .getChatHistory(
//                                                           global.currentUserId!,
//                                                           false);
//                                                   global.hideLoader();
//                                                   bottomController
//                                                       .setBottomIndex(4, 0);
//                                                   bottomController
//                                                       .persistentTabController!
//                                                       .jumpToTab(4);
//                                                   callController
//                                                       .tabController!.index = 3;
//                                                   callController.update();
//                                                 },
//                                                 child: Text(
//                                                   'View All',
//                                                   style: Get
//                                                       .theme
//                                                       .primaryTextTheme
//                                                       .bodySmall!
//                                                       .copyWith(
//                                                     fontWeight: FontWeight.w400,
//                                                     color: Colors.blue[500],
//                                                   ),
//                                                 ).tr(),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         GetBuilder<HomeController>(
//                                           builder: (HomeController) {
//                                             return Expanded(
//                                               child: ListView.builder(
//                                                 itemCount: homeController
//                                                     .myOrders.length,
//                                                 shrinkWrap: true,
//                                                 scrollDirection:
//                                                     Axis.horizontal,
//                                                 padding: EdgeInsets.only(
//                                                     top: 5, left: 10),
//                                                 itemBuilder: (context, index) {
//                                                   return GestureDetector(
//                                                       onTap: () async {
//                                                         if (homeController
//                                                                 .myOrders[index]
//                                                                 .orderType ==
//                                                             "call") {
//                                                           if (homeController
//                                                                   .myOrders[
//                                                                       index]
//                                                                   .callId !=
//                                                               0) {
//                                                             IntakeController
//                                                                 intakeController =
//                                                                 Get.find<
//                                                                     IntakeController>();
//                                                             HistoryController
//                                                                 historyController =
//                                                                 Get.find<
//                                                                     HistoryController>();
//                                                             global
//                                                                 .showOnlyLoaderDialog(
//                                                                     context);
//                                                             await intakeController
//                                                                 .getFormIntakeData();
//                                                             await historyController
//                                                                 .getCallHistoryById(
//                                                                     homeController
//                                                                         .myOrders[
//                                                                             index]
//                                                                         .callId!);
//                                                             global.hideLoader();
//                                                             Get.to(() =>
//                                                                 CallHistoryDetailScreen(
//                                                                   astrologerId: homeController
//                                                                       .myOrders[
//                                                                           index]
//                                                                       .astrologerId!,
//                                                                   astrologerProfile:
//                                                                       homeController
//                                                                               .myOrders[index]
//                                                                               .profileImage ??
//                                                                           "",
//                                                                   index: index,
//                                                                   callType: homeController
//                                                                           .myOrders[
//                                                                               index]
//                                                                           .call_type ??
//                                                                       0,
//                                                                 ));
//                                                           }
//                                                         } else if (homeController
//                                                                 .myOrders[index]
//                                                                 .orderType ==
//                                                             "chat") {
//                                                           if (homeController
//                                                                   .myOrders[
//                                                                       index]
//                                                                   .firebaseChatId !=
//                                                               "") {
//                                                             ChatController
//                                                                 chatController =
//                                                                 Get.find<
//                                                                     ChatController>();
//                                                             global
//                                                                 .showOnlyLoaderDialog(
//                                                                     context);
//                                                             await chatController
//                                                                 .getuserReview(
//                                                                     homeController
//                                                                         .myOrders[
//                                                                             index]
//                                                                         .astrologerId!);
//                                                             global.hideLoader();
//                                                             Get.to(() =>
//                                                                 AcceptChatScreen(
//                                                                   flagId: 0,
//                                                                   profileImage:
//                                                                       homeController
//                                                                               .myOrders[index]
//                                                                               .profileImage ??
//                                                                           "",
//                                                                   astrologerName: homeController
//                                                                           .myOrders[
//                                                                               index]
//                                                                           .astrologerName ??
//                                                                       "Astrologer",
//                                                                   fireBasechatId: homeController
//                                                                       .myOrders[
//                                                                           index]
//                                                                       .firebaseChatId!,
//                                                                   astrologerId: homeController
//                                                                       .myOrders[
//                                                                           index]
//                                                                       .astrologerId!,
//                                                                   chatId: homeController
//                                                                       .myOrders[
//                                                                           index]
//                                                                       .id!,
//                                                                   duration: int.parse(homeController
//                                                                               .myOrders[index]
//                                                                               .totalMin ??
//                                                                           "100")
//                                                                       .toString(),
//                                                                 ));
//                                                           } else {
//                                                             print(
//                                                                 "firbaseid null");
//                                                           }
//                                                         }
//                                                       },
//                                                       child: Card(
//                                                         child: Row(
//                                                           children: [
//                                                             Container(
//                                                               height: 65,
//                                                               width: 65,
//                                                               margin:
//                                                                   const EdgeInsets
//                                                                       .all(10),
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                 border: Border.all(
//                                                                     color: Get
//                                                                         .theme
//                                                                         .primaryColor),
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             2.w),
//                                                               ),
//                                                               child: homeController
//                                                                           .myOrders[
//                                                                               index]
//                                                                           .profileImage ==
//                                                                       ""
//                                                                   ? ClipRRect(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               1.5.w),
//                                                                       child: Image
//                                                                           .asset(
//                                                                         Images
//                                                                             .deafultUser,
//                                                                         fit: BoxFit
//                                                                             .cover,
//                                                                         height:
//                                                                             65,
//                                                                         width:
//                                                                             65,
//                                                                       ),
//                                                                     )
//                                                                   : ClipRRect(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               1.5.w),
//                                                                       child:
//                                                                           CachedNetworkImage(
//                                                                         imageUrl:
//                                                                             global.buildImageUrl('${homeController.myOrders[index].profileImage}'),
//                                                                         placeholder:
//                                                                             (context, url) =>
//                                                                                 const Center(child: CircularProgressIndicator()),
//                                                                         errorWidget: (context,
//                                                                                 url,
//                                                                                 error) =>
//                                                                             Image.asset(
//                                                                           Images
//                                                                               .deafultUser,
//                                                                           fit: BoxFit
//                                                                               .cover,
//                                                                           height:
//                                                                               65,
//                                                                           width:
//                                                                               65,
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                             ),
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(2.0),
//                                                               child: Column(
//                                                                 mainAxisSize:
//                                                                     MainAxisSize
//                                                                         .min,
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .start,
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: [
//                                                                   Text('${homeController.myOrders[index].astrologerName}')
//                                                                       .tr(),
//                                                                   Text(
//                                                                     DateConverter.dateTimeStringToDateOnly(homeController
//                                                                         .myOrders[
//                                                                             index]
//                                                                         .createdAt
//                                                                         .toString()),
//                                                                     style: TextStyle(
//                                                                         color: Colors
//                                                                             .grey,
//                                                                         fontSize:
//                                                                             10),
//                                                                   ),
//                                                                   SizedBox(
//                                                                     height: 1.h,
//                                                                   ),
//                                                                   Row(
//                                                                     children: [
//                                                                       GestureDetector(
//                                                                         onTap:
//                                                                             () async {
//                                                                           if (homeController.myOrders[index].orderType ==
//                                                                               "call") {
//                                                                             if (homeController.myOrders[index].callId !=
//                                                                                 0) {
//                                                                               IntakeController intakeController = Get.find<IntakeController>();
//                                                                               HistoryController historyController = Get.find<HistoryController>();
//                                                                               global.showOnlyLoaderDialog(context);
//                                                                               await intakeController.getFormIntakeData();
//                                                                               await historyController.getCallHistoryById(homeController.myOrders[index].callId!);
//                                                                               global.hideLoader();
//                                                                               Get.to(() => CallHistoryDetailScreen(
//                                                                                     astrologerId: homeController.myOrders[index].astrologerId!,
//                                                                                     astrologerProfile: homeController.myOrders[index].profileImage ?? "",
//                                                                                     index: index,
//                                                                                     callType: homeController.myOrders[index].call_type ?? 10,
//                                                                                   ));
//                                                                             }
//                                                                           } else if (homeController.myOrders[index].orderType ==
//                                                                               "chat") {
//                                                                             if (homeController.myOrders[index].firebaseChatId !=
//                                                                                 "") {
//                                                                               ChatController chatController = Get.find<ChatController>();
//                                                                               global.showOnlyLoaderDialog(context);
//                                                                               await chatController.getuserReview(homeController.myOrders[index].astrologerId!);
//                                                                               global.hideLoader();
//                                                                               Get.to(() => AcceptChatScreen(
//                                                                                     flagId: 0,
//                                                                                     profileImage: homeController.myOrders[index].profileImage ?? "",
//                                                                                     astrologerName: homeController.myOrders[index].astrologerName ?? "Astrologer",
//                                                                                     fireBasechatId: homeController.myOrders[index].firebaseChatId!,
//                                                                                     astrologerId: homeController.myOrders[index].astrologerId!,
//                                                                                     chatId: int.parse(homeController.myOrders[index].id!.toString()),
//                                                                                     duration: int.parse(homeController.myOrders[index].totalMin ?? "100").toString(),
//                                                                                   ));
//                                                                             }
//                                                                           }
//                                                                         },
//                                                                         child: CircleAvatar(
//                                                                             radius:
//                                                                                 13,
//                                                                             child: homeController.myOrders[index].orderType == "call"
//                                                                                 ? Icon(Icons.play_arrow, size: 13)
//                                                                                 : Icon(Icons.message, size: 13)),
//                                                                       ),
//                                                                       const SizedBox(
//                                                                         width:
//                                                                             10,
//                                                                       ),
//                                                                       GestureDetector(
//                                                                           onTap:
//                                                                               () async {
//                                                                             global.showOnlyLoaderDialog(context);
//                                                                             final BottomNavigationController
//                                                                                 bottomNavigationController =
//                                                                                 Get.find<BottomNavigationController>();
//                                                                             Get.find<ReviewController>().getReviewData(homeController.myOrders[index].astrologerId ??
//                                                                                 0);
//                                                                             await bottomNavigationController.getAstrologerbyId(homeController.myOrders[index].astrologerId ??
//                                                                                 0);
//                                                                             global.hideLoader();
//                                                                             if (bottomNavigationController.astrologerbyId.isNotEmpty) {
//                                                                               Get.to(() => AstrologerProfile(
//                                                                                     index: index,
//                                                                                   ));
//                                                                             }
//                                                                           },
//                                                                           child:
//                                                                               CircleAvatar(
//                                                                             radius:
//                                                                                 13,
//                                                                             child:
//                                                                                 Icon(
//                                                                               Icons.call,
//                                                                               size: 13,
//                                                                             ),
//                                                                           )),
//                                                                     ],
//                                                                   )
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ));
//                                                 },
//                                               ),
//                                             );
//                                           },
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                       }),
//                       //--------------------------------------LIVE ASTROLOGER LIST---------------------------------

//                       GetBuilder<BottomNavigationController>(
//                           builder: (bottomControllerMain) {
//                         return bottomControllerMain
//                                     .listliveAstrologer!.length ==
//                                 0
//                             ? const SizedBox()
//                             : SizedBox(
//                                 height: 25.h,
//                                 child: Card(
//                                   elevation: 0,
//                                   margin: EdgeInsets.only(top: 6),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.zero),
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 10),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 10),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Text(
//                                                     'Live Astrologers',
//                                                     style: Get
//                                                         .theme
//                                                         .primaryTextTheme
//                                                         .titleMedium!
//                                                         .copyWith(
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .w500),
//                                                   ).tr(),
//                                                   Padding(
//                                                     padding: EdgeInsets.only(
//                                                         left: 5),
//                                                     child: GestureDetector(
//                                                       onTap: () async {
//                                                         global
//                                                             .showOnlyLoaderDialog(
//                                                                 context);
//                                                         await bottomControllerMain
//                                                             .getLiveAstrologerList();
//                                                         global.hideLoader();
//                                                       },
//                                                       child: Icon(
//                                                         Icons.refresh,
//                                                         size: 20,
//                                                       ),
//                                                     ),
//                                                   )
//                                                 ],
//                                               ),
//                                               GestureDetector(
//                                                 onTap: () async {
//                                                   Get.to(() =>
//                                                       LiveAstrologerListScreen());
//                                                 },
//                                                 child: Text(
//                                                   'View All',
//                                                   style: Get
//                                                       .theme
//                                                       .primaryTextTheme
//                                                       .bodySmall!
//                                                       .copyWith(
//                                                     fontWeight: FontWeight.w400,
//                                                     color: Colors.blue[500],
//                                                   ),
//                                                 ).tr(),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         GetBuilder<BottomNavigationController>(
//                                           builder: (bottomControllerMain) {
//                                             return Expanded(
//                                               child: ListView.builder(
//                                                 itemCount: bottomControllerMain
//                                                     .listliveAstrologer!.length,
//                                                 shrinkWrap: true,
//                                                 scrollDirection:
//                                                     Axis.horizontal,
//                                                 padding: EdgeInsets.only(
//                                                     top: 10, left: 10),
//                                                 itemBuilder: (context, index) {
//                                                   return GestureDetector(
//                                                       onTap: () async {
//                                                         bottomControllerMain
//                                                             .anotherLiveAstrologers = Get
//                                                                 .find<
//                                                                     BottomNavigationController>()
//                                                             .listliveAstrologer!
//                                                             .where((element) =>
//                                                                 element
//                                                                     .astrologerId !=
//                                                                 Get.find<
//                                                                         BottomNavigationController>()
//                                                                     .listliveAstrologer![
//                                                                         index]
//                                                                     .astrologerId)
//                                                             .toList();
//                                                         bottomControllerMain
//                                                             .update();
//                                                         print("channel name");
//                                                         print(
//                                                             "${bottomControllerMain.listliveAstrologer![index].channelName}");
//                                                         await liveController.getWaitList(
//                                                             bottomControllerMain
//                                                                 .listliveAstrologer![
//                                                                     index]
//                                                                 .channelName);
//                                                         int index2 = liveController
//                                                             .waitList
//                                                             .indexWhere((element) =>
//                                                                 element
//                                                                     .userId ==
//                                                                 global
//                                                                     .currentUserId);
//                                                         if (index2 != -1) {
//                                                           liveController
//                                                                   .isImInWaitList =
//                                                               true;
//                                                           liveController
//                                                               .update();
//                                                         } else {
//                                                           liveController
//                                                                   .isImInWaitList =
//                                                               false;
//                                                           liveController
//                                                               .update();
//                                                         }
//                                                         liveController
//                                                             .isImInLive = true;
//                                                         liveController
//                                                                 .isJoinAsChat =
//                                                             false;
//                                                         liveController
//                                                                 .isLeaveCalled =
//                                                             false;
//                                                         liveController.update();
//                                                         bool isLogin =
//                                                             await global
//                                                                 .isLogin();
//                                                         if (isLogin) {
//                                                           if (bottomControllerMain
//                                                                   .liveAstrologerModel!
//                                                                   .callMethod ==
//                                                               'hms') {
//                                                             Get.to(() =>
//                                                                 HMSLiveScreen(
//                                                                   hmsToken: bottomControllerMain
//                                                                       .listliveAstrologer![
//                                                                           index]
//                                                                       .token,
//                                                                   channel: bottomControllerMain
//                                                                       .listliveAstrologer![
//                                                                           index]
//                                                                       .channelName,
//                                                                   astrologerId: bottomControllerMain
//                                                                       .listliveAstrologer![
//                                                                           index]
//                                                                       .astrologerId,
//                                                                   charge: bottomControllerMain
//                                                                       .listliveAstrologer![
//                                                                           index]
//                                                                       .charge,
//                                                                   videoCallCharge: bottomControllerMain
//                                                                       .listliveAstrologer![
//                                                                           index]
//                                                                       .videoCallRate,
//                                                                 ));
//                                                           } else if (bottomControllerMain
//                                                                   .liveAstrologerModel!
//                                                                   .callMethod ==
//                                                               'agora') {
//                                                             Get.to(
//                                                               () =>
//                                                                   LiveAstrologerScreen(
//                                                                 token: bottomControllerMain
//                                                                     .listliveAstrologer![
//                                                                         index]
//                                                                     .token,
//                                                                 channel: bottomControllerMain
//                                                                     .listliveAstrologer![
//                                                                         index]
//                                                                     .channelName,
//                                                                 astrologerName:
//                                                                     bottomControllerMain
//                                                                         .listliveAstrologer![
//                                                                             index]
//                                                                         .name,
//                                                                 astrologerProfile:
//                                                                     bottomControllerMain
//                                                                         .listliveAstrologer![
//                                                                             index]
//                                                                         .profileImage,
//                                                                 astrologerId: bottomControllerMain
//                                                                     .listliveAstrologer![
//                                                                         index]
//                                                                     .astrologerId,
//                                                                 isFromHome:
//                                                                     true,
//                                                                 charge: bottomControllerMain
//                                                                     .listliveAstrologer![
//                                                                         index]
//                                                                     .charge,
//                                                                 isForLiveCallAcceptDecline:
//                                                                     false,
//                                                                 isFromNotJoined:
//                                                                     false,
//                                                                 isFollow: bottomControllerMain
//                                                                     .listliveAstrologer![
//                                                                         index]
//                                                                     .isFollow!,
//                                                                 videoCallCharge:
//                                                                     bottomControllerMain
//                                                                         .listliveAstrologer![
//                                                                             index]
//                                                                         .videoCallRate,
//                                                               ),
//                                                             );
//                                                           }
//                                                         } else {
//                                                           log('callmethod not getting or set in homescreen');
//                                                         }
//                                                       },
//                                                       child: Container(
//                                                           padding: EdgeInsets
//                                                               .symmetric(
//                                                                   horizontal:
//                                                                       1.5.w),
//                                                           decoration: BoxDecoration(
//                                                               borderRadius: BorderRadius
//                                                                   .circular(FontSizes(
//                                                                           context)
//                                                                       .width2()),
//                                                               color:
//                                                                   Colors.white,
//                                                               boxShadow: [
//                                                                 BoxShadow(
//                                                                     color: Colors
//                                                                         .grey,
//                                                                     offset:
//                                                                         Offset(
//                                                                             1,
//                                                                             2),
//                                                                     spreadRadius:
//                                                                         2,
//                                                                     blurRadius:
//                                                                         2)
//                                                               ]),
//                                                           margin: EdgeInsets.symmetric(
//                                                               horizontal:
//                                                                   FontSizes(
//                                                                           context)
//                                                                       .width1()),
//                                                           child: Column(
//                                                             children: [
//                                                               Stack(
//                                                                 alignment: Alignment
//                                                                     .bottomLeft,
//                                                                 children: [
//                                                                   bottomControllerMain
//                                                                               .listliveAstrologer![
//                                                                                   index]
//                                                                               .profileImage !=
//                                                                           ""
//                                                                       ? CircleAvatar(
//                                                                           radius: 30
//                                                                               .sp,
//                                                                           backgroundImage:
//                                                                               NetworkImage("${bottomControllerMain.listliveAstrologer![index].profileImage}"))
//                                                                       : CircleAvatar(
//                                                                           backgroundColor:
//                                                                               Colors.grey,
//                                                                           radius:
//                                                                               30.sp,
//                                                                           backgroundImage:
//                                                                               AssetImage(
//                                                                             Images.deafultUser,
//                                                                           ),
//                                                                         ),
//                                                                   Positioned(
//                                                                     top: FontSizes(
//                                                                             context)
//                                                                         .height01(),
//                                                                     child: Container(
//                                                                         padding: EdgeInsets.symmetric(horizontal: FontSizes(context).width2()),
//                                                                         decoration: BoxDecoration(borderRadius: BorderRadius.circular(FontSizes(context).width2()), color: Get.theme.primaryColor),
//                                                                         child: CustomText(
//                                                                           text:
//                                                                               "Live",
//                                                                           fontWeight:
//                                                                               FontWeight.w600,
//                                                                           color:
//                                                                               whiteColor,
//                                                                         )),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                               Column(
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .center,
//                                                                 children: [
//                                                                   CustomText(
//                                                                     text:
//                                                                         "${bottomControllerMain.listliveAstrologer![index].name}",
//                                                                     color:
//                                                                         blackColor,
//                                                                     maxLine: 1,
//                                                                     fontsize: FontSizes(
//                                                                             context)
//                                                                         .font4(),
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w700,
//                                                                   ),
//                                                                   CustomText(
//                                                                     text:
//                                                                         "${bottomControllerMain.listliveAstrologer![index].videoCallRate}/min",
//                                                                     color: Get
//                                                                         .theme
//                                                                         .primaryColor,
//                                                                     maxLine: 1,
//                                                                     fontsize: FontSizes(
//                                                                             context)
//                                                                         .font3(),
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w600,
//                                                                   ),
//                                                                 ],
//                                                               )
//                                                             ],
//                                                           )));
//                                                 },
//                                               ),
//                                             );
//                                           },
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                       }),

//                       //---------- Recommended Products ----------------------------------------

//                       SizedBox(height: 5),

//                       GetBuilder<HomeController>(
//                         builder: (homecontroller) =>
//                             homecontroller.recomendedList != null &&
//                                     homecontroller.recomendedList != '' &&
//                                     homecontroller.recomendedList!.length > 0
//                                 ? getRecommendedView(homecontroller)
//                                 : SizedBox(),
//                       ),

//                       //---------- ASTROLOGERS BLOCK----------------------------------------
//                       bottomNavigationController.astrologerList.isEmpty
//                           ? SizedBox()
//                           : Padding(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 1.h),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Top rated astrologer',
//                                     style: Get
//                                         .theme.primaryTextTheme.titleMedium!
//                                         .copyWith(fontWeight: FontWeight.w500),
//                                   ).tr(),
//                                   GestureDetector(
//                                     onTap: () async {
//                                       //astrologer list clicked
//                                       // bottomController.bottomNavIndex = 1;
//                                       // bottomController.update();
//                                       bottomController.persistentTabController!
//                                           .jumpToTab(1);
//                                     },
//                                     child: Text(
//                                       'View All',
//                                       style: Get
//                                           .theme.primaryTextTheme.bodySmall!
//                                           .copyWith(
//                                         fontWeight: FontWeight.w400,
//                                         color: Colors.blue[500],
//                                       ),
//                                     ).tr(),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                       SizedBox(
//                         height: 1.h,
//                       ),
//                       _buildAstrologerslistwidget(context),

//                       ///panchang
//                       Card(
//                         elevation: 0,
//                         margin: EdgeInsets.only(top: 6),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.zero),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 10, horizontal: 10),
//                           child: SizedBox(
//                             height: 110,
//                             child: Stack(
//                               children: [
//                                 GestureDetector(
//                                   onTap: () async {
//                                     DateTime dateBasic = DateTime.now();
//                                     int formattedYear = int.parse(
//                                         DateFormat('yyyy').format(dateBasic));
//                                     int formattedDay = int.parse(
//                                         DateFormat('dd').format(dateBasic));
//                                     int formattedMonth = int.parse(
//                                         DateFormat('MM').format(dateBasic));
//                                     int formattedHour = int.parse(
//                                         DateFormat('HH').format(dateBasic));
//                                     int formattedMint = int.parse(
//                                         DateFormat('mm').format(dateBasic));
//                                     String? ipadddress =
//                                         await apiHelper.getPublicIPAddress();
//                                     global.showOnlyLoaderDialog(context);
//                                     await kundliController
//                                         .getBasicPanchangDetail(
//                                             day: formattedDay,
//                                             hour: formattedHour,
//                                             min: formattedMint,
//                                             month: formattedMonth,
//                                             year: formattedYear,
//                                             lat: 21.1255,
//                                             lon: 73.1122,
//                                             tzone: 5);
//                                     panchangController.getPanchangVedic(
//                                         DateTime.now(), ipadddress);
//                                     global.hideLoader();
//                                     Get.to(() => PanchangScreen());
//                                   },
//                                   child: Container(
//                                     width: Get.width,
//                                     decoration: BoxDecoration(
//                                       color: Get.theme.primaryColor,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     padding: EdgeInsets.only(right: 20),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Padding(
//                                           padding:
//                                               const EdgeInsets.only(right: 25),
//                                           child: Text(
//                                             "Today's Panchang",
//                                             style: Get
//                                                 .theme.textTheme.bodyMedium!
//                                                 .copyWith(
//                                                     fontWeight: FontWeight.w500,
//                                                     fontSize: 16.sp,
//                                                     color: Colors.white),
//                                           ).tr(),
//                                         ),
//                                         Container(
//                                           height: 25,
//                                           width: 90,
//                                           margin: EdgeInsets.only(
//                                               right: 38, top: 5),
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 5),
//                                           decoration: BoxDecoration(
//                                             color: Colors.black,
//                                             borderRadius:
//                                                 BorderRadius.circular(7),
//                                           ),
//                                           alignment: Alignment.center,
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Text(
//                                                 'Check Now',
//                                                 style: TextStyle(
//                                                   fontSize: 10,
//                                                   fontWeight: FontWeight.w500,
//                                                   color: Colors.white,
//                                                   letterSpacing: -0.2,
//                                                   wordSpacing: 0,
//                                                 ),
//                                               ).tr(),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Container(
//                                   height: 110,
//                                   width: 130,
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.only(
//                                       topRight: Radius.circular(45),
//                                       bottomRight: Radius.circular(45),
//                                       topLeft: Radius.circular(10),
//                                       bottomLeft: Radius.circular(10),
//                                     ),
//                                     child: CachedNetworkImage(
//                                       imageUrl: global.buildImageUrl(
//                                           '${global.getSystemFlagValueForLogin(global.systemFlagNameList.todayPanchang)}'),
//                                       imageBuilder: (context, imageProvider) =>
//                                           Image.network(
//                                         '${global.getSystemFlagValueForLogin(global.systemFlagNameList.todayPanchang)}',
//                                         fit: BoxFit.fill,
//                                       ),
//                                       placeholder: (context, url) =>
//                                           const Center(
//                                               child:
//                                                   CircularProgressIndicator()),
//                                       errorWidget: (context, url, error) =>
//                                           Icon(Icons.no_accounts, size: 20),
//                                     ),
//                                   ),
//                                   decoration: BoxDecoration(
//                                       color: Colors.black,
//                                       borderRadius: BorderRadius.only(
//                                         topRight: Radius.circular(45),
//                                         bottomRight: Radius.circular(45),
//                                         topLeft: Radius.circular(10),
//                                         bottomLeft: Radius.circular(10),
//                                       )),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),

//                       //---------- Categories wise ----------------------------------------

//                       GetBuilder<AstrologerCategoryController>(
//                           builder: (astrologyCat) {
//                         return Container(
//                           // color: Colors.red,
//                           child: ListView.builder(
//                               itemCount: astrologyCat.categoryList.length <= 3
//                                   ? astrologyCat.categoryList.length
//                                   : 3,
//                               shrinkWrap: true,
//                               padding: EdgeInsets.only(bottom: 0),
//                               physics: NeverScrollableScrollPhysics(),
//                               itemBuilder: (context, index) {
//                                 return Column(
//                                   spacing: 1.w,
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     SizedBox(
//                                       height: 2.w,
//                                     ),
//                                     Container(
//                                       margin:
//                                           EdgeInsets.symmetric(horizontal: 20),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(
//                                                 '${astrologyCat.categoryList[index].name}',
//                                                 style: Get
//                                                     .theme
//                                                     .primaryTextTheme
//                                                     .titleMedium!
//                                                     .copyWith(
//                                                         fontWeight:
//                                                             FontWeight.w500),
//                                               ).tr(),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     _catAstrologerslistwidget(context, index),
//                                   ],
//                                 );
//                               }),
//                         );
//                       }),

//                       Padding(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 10, vertical: 1.h),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Categories',
//                               style: Get.theme.primaryTextTheme.titleMedium!
//                                   .copyWith(fontWeight: FontWeight.w500),
//                             ).tr(),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 0.5.h),

//                       GetBuilder<AstrologerCategoryController>(
//                           builder: (astrologyCat) {
//                         return Container(
//                             height: 19.h,
//                             margin: EdgeInsets.symmetric(
//                                 horizontal: FontSizes(context).width3()),
//                             child: ListView.builder(
//                                 scrollDirection: Axis.horizontal,
//                                 itemCount: astrologyCat.categoryList.length,
//                                 shrinkWrap: true,
//                                 itemBuilder: (context, index) {
//                                   return InkWell(
//                                     onTap: () async {
//                                       global.showOnlyLoaderDialog(context);
//                                       bottomNavigationController.update();
//                                       chatController.isSelected = index;
//                                       chatController.update();
//                                       await bottomNavigationController.astroCat(
//                                           id: astrologyCat
//                                               .categoryList[index].id!,
//                                           isLazyLoading: false);
//                                       global.hideLoader();
//                                       chatController.isSelected = (index + 1);
//                                       chatController.update();
//                                       print(
//                                           'seelected index is ${chatController.isSelected}');

//                                       Get.to(() => ChatScreen(flag: 1));
//                                     },
//                                     child: Container(
//                                       width: 22.w,
//                                       alignment: Alignment.center,
//                                       margin:
//                                           EdgeInsets.symmetric(horizontal: 2),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: [
//                                           Container(
//                                             width: 22.w,
//                                             height: 22.w,
//                                             padding: EdgeInsets.all(8),
//                                             decoration: BoxDecoration(
//                                                 color: Color(0xffE5F3F3),
//                                                 borderRadius:
//                                                     BorderRadius.circular(8)),
//                                             margin: const EdgeInsets.only(
//                                                 top: 4, bottom: 1, right: 5),
//                                             child: CircleAvatar(
//                                               backgroundColor: Colors.white,
//                                               radius:
//                                                   FontSizes(context).width9(),
//                                               backgroundImage: NetworkImage(
//                                                   "${astrologyCat.categoryList[index].image}"),
//                                             ),
//                                           ),
//                                           SizedBox(height: 0.5.h),
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 5.0, vertical: 3),
//                                             child: Center(
//                                               child: global.buildTranslatedText(
//                                                   "${astrologyCat.categoryList[index].name}",
//                                                   Get.textTheme.bodyMedium!
//                                                       .copyWith(
//                                                           fontSize: 11,
//                                                           color: Colors.black,
//                                                           fontWeight:
//                                                               FontWeight.w500),
//                                                   textAlignment:
//                                                       TextAlign.center),
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 }));
//                       }),

//                       GetBuilder<AstromallController>(
//                           builder: (astromallController) {
//                         return astromallController.astroCategory.length == 0
//                             ? SizedBox()
//                             : SizedBox(
//                                 height: 23.h,
//                                 child: Card(
//                                   elevation: 0,
//                                   margin: EdgeInsets.only(top: 6),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.zero),
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(
//                                         top: 10, bottom: 1),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 10),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Container(
//                                                 margin: EdgeInsets.symmetric(
//                                                     horizontal: 5),
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       'Shop Now',
//                                                       style: Get
//                                                           .theme
//                                                           .primaryTextTheme
//                                                           .titleMedium!
//                                                           .copyWith(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w500),
//                                                     ).tr(),
//                                                   ],
//                                                 ),
//                                               ),
//                                               GestureDetector(
//                                                 onTap: () async {
//                                                   final AstromallController
//                                                       astromallController =
//                                                       Get.find<
//                                                           AstromallController>();
//                                                   astromallController
//                                                       .astroCategory
//                                                       .clear();
//                                                   astromallController
//                                                       .isAllDataLoaded = false;
//                                                   astromallController.update();
//                                                   global.showOnlyLoaderDialog(
//                                                       context);
//                                                   await astromallController
//                                                       .getAstromallCategory(
//                                                           false);
//                                                   global.hideLoader();
//                                                   Get.to(
//                                                       () => AstromallScreen());
//                                                 },
//                                                 child: Text(
//                                                   'View All',
//                                                   style: Get
//                                                       .theme
//                                                       .primaryTextTheme
//                                                       .bodySmall!
//                                                       .copyWith(
//                                                     fontWeight: FontWeight.w400,
//                                                     color: Colors.blue[500],
//                                                   ),
//                                                 ).tr(),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Expanded(
//                                             child: ListView.builder(
//                                           itemCount: astromallController
//                                               .astroCategory.length,
//                                           shrinkWrap: true,
//                                           scrollDirection: Axis.horizontal,
//                                           padding: EdgeInsets.only(
//                                               top: 10, left: 10, right: 10),
//                                           itemBuilder: (context, index) {
//                                             return GestureDetector(
//                                               onTap: () async {
//                                                 global.showOnlyLoaderDialog(
//                                                     context);
//                                                 astromallController.astroProduct
//                                                     .clear();
//                                                 // astromallController
//                                                 //         .isAllDataLoadedForProduct =
//                                                 //     false;
//                                                 astromallController
//                                                         .productCatId =
//                                                     astromallController
//                                                         .astroCategory[index]
//                                                         .id;
//                                                 astromallController.update();
//                                                 await astromallController
//                                                     .getAstromallProduct(
//                                                         astromallController
//                                                             .astroCategory[
//                                                                 index]
//                                                             .id,
//                                                         false);
//                                                 global.hideLoader();
//                                                 Get.to(
//                                                   () => AstroProductScreen(
//                                                     appbarTitle:
//                                                         astromallController
//                                                             .astroCategory[
//                                                                 index]
//                                                             .name,
//                                                     productCategoryId:
//                                                         astromallController
//                                                             .astroCategory[
//                                                                 index]
//                                                             .id,
//                                                     sliderImage:
//                                                         "${astromallController.astroCategory[index].categoryImage}",
//                                                   ),
//                                                 );
//                                               },
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.start,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.center,
//                                                 children: [
//                                                   Container(
//                                                     width: 22.w,
//                                                     height: 22.w,
//                                                     padding: EdgeInsets.all(5),
//                                                     decoration: BoxDecoration(
//                                                         color:
//                                                             Color(0xffE5F3F3),
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(8)),
//                                                     margin:
//                                                         const EdgeInsets.only(
//                                                             top: 4,
//                                                             bottom: 1,
//                                                             right: 5),
//                                                     child: Padding(
//                                                       padding:
//                                                           EdgeInsets.all(4),
//                                                       child: CircleAvatar(
//                                                         backgroundColor:
//                                                             Color(0xffE5F3F3),
//                                                         radius: 28.sp,
//                                                         backgroundImage:
//                                                             NetworkImage(
//                                                                 "${astromallController.astroCategory[index].categoryImage}"),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   Container(
//                                                     color: Colors.white,
//                                                     // width: Get.width,
//                                                     // height:5.h,
//                                                     alignment:
//                                                         Alignment.topCenter,
//                                                     padding:
//                                                         const EdgeInsets.only(
//                                                             top: 2),
//                                                     child: Center(
//                                                       child: Text(
//                                                         "${astromallController.astroCategory[index].name}",
//                                                         style: TextStyle(
//                                                           fontSize: 11,
//                                                           color: Colors.black,
//                                                           fontWeight:
//                                                               FontWeight.w500,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   )
//                                                 ],
//                                               ),
//                                             );
//                                           },
//                                         ))
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                       }),
//                       //---------- LATEST BLOG ----------------------------------------

//                       GetBuilder<HomeController>(
//                         builder: (homeController) {
//                           return homeController.blogList.length == 0
//                               ? SizedBox()
//                               : SizedBox(
//                                   height: 32.h,
//                                   child: Card(
//                                     elevation: 0,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.zero),
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(
//                                           top: 1, bottom: 5),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 10),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   'Latest from blog',
//                                                   style: Get
//                                                       .theme
//                                                       .primaryTextTheme
//                                                       .titleMedium!
//                                                       .copyWith(
//                                                           fontWeight:
//                                                               FontWeight.w500),
//                                                 ).tr(),
//                                                 GestureDetector(
//                                                   onTap: () async {
//                                                     BlogController
//                                                         blogController =
//                                                         Get.find<
//                                                             BlogController>();
//                                                     global.showOnlyLoaderDialog(
//                                                         context);
//                                                     blogController
//                                                         .astrologyBlogs = [];
//                                                     blogController
//                                                         .astrologyBlogs
//                                                         .clear();
//                                                     blogController
//                                                             .isAllDataLoaded =
//                                                         false;
//                                                     blogController.update();
//                                                     await blogController
//                                                         .getAstrologyBlog(
//                                                             "", false);
//                                                     global.hideLoader();
//                                                     Get.to(() =>
//                                                         AstrologyBlogScreen());
//                                                   },
//                                                   child: Text(
//                                                     'View All',
//                                                     style: Get
//                                                         .theme
//                                                         .primaryTextTheme
//                                                         .bodySmall!
//                                                         .copyWith(
//                                                       fontWeight:
//                                                           FontWeight.w400,
//                                                       color: Colors.blue[500],
//                                                     ),
//                                                   ).tr(),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           Expanded(child:
//                                               GetBuilder<HomeController>(
//                                                   builder: (homeControllerr) {
//                                             return ListView.builder(
//                                               itemCount: homeController
//                                                   .blogList.length,
//                                               shrinkWrap: true,
//                                               scrollDirection: Axis.horizontal,
//                                               padding: const EdgeInsets.only(
//                                                   top: 10,
//                                                   left: 10,
//                                                   bottom: 10),
//                                               itemBuilder: (context, index) {
//                                                 return GestureDetector(
//                                                   onTap: () async {
//                                                     global.showOnlyLoaderDialog(
//                                                         context);
//                                                     await homeController
//                                                         .incrementBlogViewer(
//                                                             homeController
//                                                                 .blogList[index]
//                                                                 .id);
//                                                     homeController
//                                                         .homeBlogVideo(
//                                                             homeController
//                                                                 .blogList[index]
//                                                                 .blogImage);
//                                                     global.hideLoader();
//                                                     Get.to(() =>
//                                                         AstrologyBlogDetailScreen(
//                                                           image:
//                                                               "${homeController.blogList[index].blogImage}",
//                                                           title: homeController
//                                                               .blogList[index]
//                                                               .title,
//                                                           description:
//                                                               homeController
//                                                                   .blogList[
//                                                                       index]
//                                                                   .description!,
//                                                           extension:
//                                                               homeController
//                                                                   .blogList[
//                                                                       index]
//                                                                   .extension!,
//                                                           controller: homeController
//                                                               .homeVideoPlayerController,
//                                                         ));
//                                                   },
//                                                   child: Card(
//                                                     elevation: 4,
//                                                     margin:
//                                                         const EdgeInsets.only(
//                                                             right: 12),
//                                                     shape:
//                                                         RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               15),
//                                                     ),
//                                                     child: Container(
//                                                       width: 200,
//                                                       decoration: BoxDecoration(
//                                                         color: Colors.white,
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(5),
//                                                       ),
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         mainAxisSize:
//                                                             MainAxisSize.min,
//                                                         children: [
//                                                           ClipRRect(
//                                                               borderRadius:
//                                                                   const BorderRadius
//                                                                       .only(
//                                                                 topLeft: Radius
//                                                                     .circular(
//                                                                         10),
//                                                                 topRight: Radius
//                                                                     .circular(
//                                                                         10),
//                                                               ),
//                                                               child: homeController
//                                                                               .blogList[
//                                                                                   index]
//                                                                               .extension ==
//                                                                           'mp4' ||
//                                                                       homeController
//                                                                               .blogList[index]
//                                                                               .extension ==
//                                                                           'gif'
//                                                                   ? Stack(
//                                                                       alignment:
//                                                                           Alignment
//                                                                               .center,
//                                                                       children: [
//                                                                         CachedNetworkImage(
//                                                                           imageUrl:
//                                                                               global.buildImageUrl('${homeController.blogList[index].previewImage}'),
//                                                                           imageBuilder: (context, imageProvider) =>
//                                                                               Container(
//                                                                             height:
//                                                                                 110,
//                                                                             width:
//                                                                                 Get.width,
//                                                                             decoration:
//                                                                                 BoxDecoration(
//                                                                               borderRadius: BorderRadius.circular(10),
//                                                                               image: DecorationImage(
//                                                                                 fit: BoxFit.fill,
//                                                                                 image: imageProvider,
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                           placeholder: (context, url) =>
//                                                                               const Center(child: CircularProgressIndicator()),
//                                                                           errorWidget: (context, url, error) =>
//                                                                               Image.asset(
//                                                                             Images.blog,
//                                                                             height:
//                                                                                 110,
//                                                                             width:
//                                                                                 Get.width,
//                                                                             fit:
//                                                                                 BoxFit.fill,
//                                                                           ),
//                                                                         ),
//                                                                         Icon(
//                                                                           Icons
//                                                                               .play_arrow,
//                                                                           size:
//                                                                               40,
//                                                                           color:
//                                                                               Colors.white,
//                                                                         ),
//                                                                       ],
//                                                                     )
//                                                                   : CachedNetworkImage(
//                                                                       imageUrl:
//                                                                           global
//                                                                               .buildImageUrl('${homeController.blogList[index].blogImage}'),
//                                                                       imageBuilder:
//                                                                           (context, imageProvider) =>
//                                                                               Container(
//                                                                         height:
//                                                                             110,
//                                                                         width: Get
//                                                                             .width,
//                                                                         decoration:
//                                                                             BoxDecoration(
//                                                                           borderRadius:
//                                                                               BorderRadius.circular(10),
//                                                                           image:
//                                                                               DecorationImage(
//                                                                             image:
//                                                                                 imageProvider,
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                       placeholder: (context,
//                                                                               url) =>
//                                                                           const Center(
//                                                                               child: CircularProgressIndicator()),
//                                                                       errorWidget: (context,
//                                                                               url,
//                                                                               error) =>
//                                                                           Image
//                                                                               .asset(
//                                                                         Images
//                                                                             .blog,
//                                                                         height:
//                                                                             110,
//                                                                         width: Get
//                                                                             .width,
//                                                                         fit: BoxFit
//                                                                             .fill,
//                                                                       ),
//                                                                     )),
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .only(
//                                                                     left: 5,
//                                                                     right: 5,
//                                                                     top: 3,
//                                                                     bottom: 3),
//                                                             child: Column(
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .start,
//                                                               mainAxisSize:
//                                                                   MainAxisSize
//                                                                       .min,
//                                                               children: [
//                                                                 SizedBox(
//                                                                   height: 5.5.h,
//                                                                   child:
//                                                                       Padding(
//                                                                     padding: const EdgeInsets
//                                                                         .only(
//                                                                         bottom:
//                                                                             8.0),
//                                                                     child: Text(
//                                                                       homeController
//                                                                           .blogList[
//                                                                               index]
//                                                                           .title,
//                                                                       textAlign:
//                                                                           TextAlign
//                                                                               .start,
//                                                                       maxLines:
//                                                                           2,
//                                                                       overflow:
//                                                                           TextOverflow
//                                                                               .ellipsis,
//                                                                       style: Get
//                                                                           .theme
//                                                                           .textTheme
//                                                                           .titleMedium!
//                                                                           .copyWith(
//                                                                         fontSize:
//                                                                             13,
//                                                                         fontWeight:
//                                                                             FontWeight.w500,
//                                                                         letterSpacing:
//                                                                             0,
//                                                                       ),
//                                                                     ).tr(),
//                                                                   ),
//                                                                 ),
//                                                                 Container(
//                                                                   margin: EdgeInsets
//                                                                       .symmetric(
//                                                                           horizontal:
//                                                                               1.w),
//                                                                   child: Row(
//                                                                     mainAxisAlignment:
//                                                                         MainAxisAlignment
//                                                                             .spaceBetween,
//                                                                     children: [
//                                                                       Column(
//                                                                         crossAxisAlignment:
//                                                                             CrossAxisAlignment.start,
//                                                                         children: [
//                                                                           Text(
//                                                                             homeController.blogList[index].author,
//                                                                             textAlign:
//                                                                                 TextAlign.center,
//                                                                             style:
//                                                                                 Get.theme.textTheme.titleMedium!.copyWith(
//                                                                               fontSize: 10,
//                                                                               fontWeight: FontWeight.w500,
//                                                                               color: Colors.grey[700],
//                                                                               letterSpacing: 0,
//                                                                             ),
//                                                                           ).tr(),
//                                                                           Text(
//                                                                             "${DateFormat("MMM d,yyyy").format(DateTime.parse(homeController.blogList[index].createdAt))}",
//                                                                             textAlign:
//                                                                                 TextAlign.center,
//                                                                             style:
//                                                                                 Get.theme.textTheme.titleMedium!.copyWith(
//                                                                               fontSize: 10,
//                                                                               fontWeight: FontWeight.w500,
//                                                                               color: Colors.grey[700],
//                                                                               letterSpacing: 0,
//                                                                             ),
//                                                                           ),
//                                                                         ],
//                                                                       ),
//                                                                       Row(
//                                                                         mainAxisAlignment:
//                                                                             MainAxisAlignment.end,
//                                                                         crossAxisAlignment:
//                                                                             CrossAxisAlignment.center,
//                                                                         children: [
//                                                                           const Icon(
//                                                                             Icons.visibility,
//                                                                             size:
//                                                                                 20,
//                                                                             color:
//                                                                                 Colors.black,
//                                                                           ),
//                                                                           Padding(
//                                                                             padding:
//                                                                                 EdgeInsets.only(left: 5.0),
//                                                                             child:
//                                                                                 Text(
//                                                                               "${homeController.blogList[index].viewer}",
//                                                                               style: TextStyle(fontSize: 12, color: Colors.black),
//                                                                             ),
//                                                                           )
//                                                                         ],
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                                 SizedBox(
//                                                                   height: 1.h,
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 );
//                                               },
//                                             );
//                                           }))
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                         },
//                       ),
//                       //---------------------BEHIND THE SCHENE-------------------------------
//                       global.getSystemFlagValueForLogin(
//                                   global.systemFlagNameList.behindScenes) ==
//                               ""
//                           ? SizedBox()
//                           : _buildbehindthescenwidget(),

//                       ///astro in news
//                       // _buildAstroinnewsWidget(),

//                       GetBuilder<HomeController>(builder: (homeController) {
//                         return homeController.astrologyVideo.length == 0
//                             ? SizedBox()
//                             : SizedBox(
//                                 height: 250,
//                                 child: Card(
//                                   elevation: 0,
//                                   margin: EdgeInsets.only(top: 6),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.zero),
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(
//                                         top: 10, bottom: 5),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 10),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Container(
//                                                 margin: EdgeInsets.symmetric(
//                                                     horizontal: 10),
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     global.buildTranslatedText(
//                                                       "Watch ${global.getSystemFlagValueForLogin(global.systemFlagNameList.professionTitle)}'s Videos",
//                                                       Get.theme.primaryTextTheme
//                                                           .titleMedium!
//                                                           .copyWith(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w500),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               GestureDetector(
//                                                 onTap: () {
//                                                   Get.to(() =>
//                                                       AstrologerVideoScreen());
//                                                 },
//                                                 child: Text(
//                                                   'View All',
//                                                   style: Get
//                                                       .theme
//                                                       .primaryTextTheme
//                                                       .bodySmall!
//                                                       .copyWith(
//                                                     fontWeight: FontWeight.w400,
//                                                     color: Colors.blue[500],
//                                                   ),
//                                                 ).tr(),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Expanded(
//                                             child: ListView.builder(
//                                           itemCount: homeController
//                                               .astrologyVideo.length,
//                                           shrinkWrap: true,
//                                           scrollDirection: Axis.horizontal,
//                                           padding: EdgeInsets.only(
//                                               top: 10, left: 10, bottom: 10),
//                                           itemBuilder: (context, index) {
//                                             return GestureDetector(
//                                               onTap: () async {
//                                                 global.showOnlyLoaderDialog(
//                                                     context);
//                                                 await homeController.youtubPlay(
//                                                     homeController
//                                                         .astrologyVideo[index]
//                                                         .youtubeLink);
//                                                 global.hideLoader();
//                                                 Get.to(() => BlogScreen(
//                                                       link: homeController
//                                                           .astrologyVideo[index]
//                                                           .youtubeLink,
//                                                       title: 'Video',
//                                                       controller: homeController
//                                                           .youtubePlayerController,
//                                                       date:
//                                                           '${DateFormat("MMM d,yyyy").format(DateTime.parse(homeController.astrologyVideo[index].createdAt))}',
//                                                       videoTitle: homeController
//                                                           .astrologyVideo[index]
//                                                           .videoTitle,
//                                                     ));
//                                               },
//                                               child: Card(
//                                                 elevation: 4,
//                                                 margin:
//                                                     EdgeInsets.only(right: 12),
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(5),
//                                                 ),
//                                                 child: Container(
//                                                   width: 230,
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.white,
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             15),
//                                                   ),
//                                                   child: Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     mainAxisSize:
//                                                         MainAxisSize.min,
//                                                     children: [
//                                                       Stack(
//                                                         alignment:
//                                                             Alignment.center,
//                                                         children: [
//                                                           ClipRRect(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .only(
//                                                               topLeft: Radius
//                                                                   .circular(5),
//                                                               topRight: Radius
//                                                                   .circular(5),
//                                                             ),
//                                                             child:
//                                                                 CachedNetworkImage(
//                                                               imageUrl: global
//                                                                   .buildImageUrl(
//                                                                       '${homeController.astrologyVideo[index].coverImage}'),
//                                                               imageBuilder:
//                                                                   (context,
//                                                                           imageProvider) =>
//                                                                       Container(
//                                                                 height: 110,
//                                                                 width:
//                                                                     Get.width,
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               10),
//                                                                   image:
//                                                                       DecorationImage(
//                                                                     fit: BoxFit
//                                                                         .fill,
//                                                                     image:
//                                                                         imageProvider,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               placeholder: (context,
//                                                                       url) =>
//                                                                   const Center(
//                                                                       child:
//                                                                           CircularProgressIndicator()),
//                                                               errorWidget: (context,
//                                                                       url,
//                                                                       error) =>
//                                                                   Image.asset(
//                                                                 Images.blog,
//                                                                 height:
//                                                                     Get.height *
//                                                                         0.15,
//                                                                 width:
//                                                                     Get.width,
//                                                                 fit:
//                                                                     BoxFit.fill,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           Positioned(
//                                                             child: Image.asset(
//                                                               Images.youtube,
//                                                               height: 35,
//                                                               width: 35,
//                                                             ),
//                                                           )
//                                                         ],
//                                                       ),
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .only(
//                                                                 left: 5,
//                                                                 right: 5,
//                                                                 top: 3,
//                                                                 bottom: 3),
//                                                         child: Column(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             Container(
//                                                               height: 43,
//                                                               child: Text(
//                                                                 homeController
//                                                                     .astrologyVideo[
//                                                                         index]
//                                                                     .videoTitle,
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .start,
//                                                                 maxLines: 2,
//                                                                 overflow:
//                                                                     TextOverflow
//                                                                         .ellipsis,
//                                                                 style: Get
//                                                                     .theme
//                                                                     .textTheme
//                                                                     .titleMedium!
//                                                                     .copyWith(
//                                                                   fontSize: 13,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w500,
//                                                                   letterSpacing:
//                                                                       0,
//                                                                 ),
//                                                               ).tr(),
//                                                             ),
//                                                             Row(
//                                                               mainAxisAlignment:
//                                                                   MainAxisAlignment
//                                                                       .end,
//                                                               children: [
//                                                                 Text(
//                                                                   "${DateFormat("MMM d, yyyy").format(DateTime.parse(homeController.astrologyVideo[index].createdAt))}",
//                                                                   textAlign:
//                                                                       TextAlign
//                                                                           .center,
//                                                                   style: Get
//                                                                       .theme
//                                                                       .textTheme
//                                                                       .titleMedium!
//                                                                       .copyWith(
//                                                                     fontSize:
//                                                                         10,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w500,
//                                                                     color: Colors
//                                                                             .grey[
//                                                                         700],
//                                                                     letterSpacing:
//                                                                         0,
//                                                                   ),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         ))
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                       }),

//                       GetBuilder<HomeController>(builder: (homeController) {
//                         return Card(
//                           elevation: 0,
//                           margin: EdgeInsets.only(top: 6),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.zero),
//                           child: Container(
//                             margin: EdgeInsets.symmetric(
//                                 horizontal: 30, vertical: 10),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             padding: EdgeInsets.all(10),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'I am the Product Manager',
//                                   style: Get.theme.primaryTextTheme.titleMedium!
//                                       .copyWith(
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ).tr(),
//                                 Text(
//                                   'share your feedback to help us improve the app',
//                                   style: TextStyle(
//                                     fontSize: 15.sp,
//                                   ),
//                                 ).tr(),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 TextFormField(
//                                   style: TextStyle(fontSize: 15.sp),
//                                   controller: homeController.feedbackController,
//                                   maxLines: 8,
//                                   keyboardType: TextInputType.text,
//                                   decoration: InputDecoration(
//                                     contentPadding: EdgeInsets.all(5),
//                                     border: InputBorder.none,
//                                     filled: true,
//                                     fillColor: Colors.white,
//                                     hintText: 'Start typing here..',
//                                     hintStyle: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.grey[500],
//                                       fontSize: 15.sp,
//                                     ),
//                                   ),
//                                 ),
//                                 Align(
//                                   alignment: Alignment.center,
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(
//                                         top: 15, bottom: 5),
//                                     child: SizedBox(
//                                       height: 35,
//                                       child: TextButton(
//                                         style: ButtonStyle(
//                                           padding: MaterialStateProperty.all(
//                                               EdgeInsets.all(0)),
//                                           fixedSize: MaterialStateProperty.all(
//                                               Size.fromWidth(Get.width / 2)),
//                                           backgroundColor:
//                                               MaterialStateProperty.all(
//                                                   Get.theme.primaryColor),
//                                           shape: MaterialStateProperty.all(
//                                             RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(7),
//                                             ),
//                                           ),
//                                         ),
//                                         onPressed: () async {
//                                           bool isLogin = await global.isLogin();
//                                           if (isLogin) {
//                                             if (homeController
//                                                     .feedbackController.text ==
//                                                 "") {
//                                               global.showToast(
//                                                 message:
//                                                     'Please enter feedback',
//                                                 textColor: global.textColor,
//                                                 bgColor:
//                                                     global.toastBackGoundColor,
//                                               );
//                                             } else {
//                                               global.showOnlyLoaderDialog(
//                                                   context);
//                                               await homeController.addFeedback(
//                                                   homeController
//                                                       .feedbackController.text);
//                                               global.hideLoader();
//                                             }
//                                           }
//                                         },
//                                         child: Text(
//                                           'Send Feedback',
//                                           style: Get
//                                               .theme.primaryTextTheme.bodySmall!
//                                               .copyWith(color: Colors.white),
//                                         ).tr(),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }),

//                       Card(
//                         elevation: 0,
//                         margin: EdgeInsets.only(top: 6),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.zero),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                                   vertical: 15, horizontal: 10)
//                               .copyWith(bottom: 65),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Column(
//                                 children: [
//                                   Container(
//                                     height: 70,
//                                     width: 70,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(7),
//                                       color: Colors.grey[200],
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(10),
//                                       child: Image.asset(
//                                         Images.confidential,
//                                         height: 42,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 15,
//                                   ),
//                                   Text(
//                                     'Private &\nConfidential',
//                                     textAlign: TextAlign.center,
//                                     style: Get.theme.textTheme.titleMedium!
//                                         .copyWith(
//                                       fontSize: 13.sp,
//                                       fontWeight: FontWeight.w400,
//                                       letterSpacing: 0.5,
//                                     ),
//                                   ).tr(),
//                                 ],
//                               ),
//                               Column(
//                                 children: [
//                                   Container(
//                                     height: 70,
//                                     width: 70,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(7),
//                                       color: Colors.grey[200],
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(10),
//                                       child: Image.asset(
//                                         Images.verifiedAccount,
//                                         height: 42,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 15,
//                                   ),
//                                   global.buildTranslatedText(
//                                       'Verified\n ${global.getSystemFlagValueForLogin(global.systemFlagNameList.professionTitle)}',
//                                       Get.theme.textTheme.titleMedium!.copyWith(
//                                         fontSize: 13.sp,
//                                         fontWeight: FontWeight.w400,
//                                         letterSpacing: 0.5,
//                                       )),
//                                 ],
//                               ),
//                               Column(
//                                 children: [
//                                   Container(
//                                     height: 70,
//                                     width: 70,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(7),
//                                       color: Colors.grey[200],
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(10),
//                                       child: Image.asset(
//                                         Images.payment,
//                                         height: 42,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 15,
//                                   ),
//                                   Text(
//                                     'Secure\nPayments',
//                                     textAlign: TextAlign.center,
//                                     style: Get.theme.textTheme.titleMedium!
//                                         .copyWith(
//                                       fontSize: 13.sp,
//                                       fontWeight: FontWeight.w400,
//                                       letterSpacing: 0.5,
//                                     ),
//                                   ).tr(),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 //-----------------------CHAT WITH partner BUTTON----------------------------------
//                 Container(
//                   margin: EdgeInsets.only(top: 6, bottom: 30),
//                   width: 100.w,
//                   height: 20.h,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       InkWell(
//                         onTap: () async {
//                           global.showOnlyLoaderDialog(context);
//                           bottomController.astrologerList = [];
//                           bottomController.astrologerList.clear();
//                           bottomController.isAllDataLoaded = false;
//                           bottomController.update();
//                           await bottomController.getAstrologerList(
//                               isLazyLoading: false);
//                           global.hideLoader();
//                           bottomController.setBottomIndex(1, 0);
//                         },
//                         child: Container(
//                             width: Adaptive.w(43),
//                             decoration: BoxDecoration(
//                               color: Get.theme.primaryColor,
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(4.w),
//                               ),
//                             ),
//                             child: Container(
//                               padding: EdgeInsets.only(left: 1.5.w),
//                               height: 6.h,
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     FontAwesomeIcons.solidCommentDots,
//                                     size: 14.sp,
//                                     color: Colors.white,
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.only(left: 2.w),
//                                     child: FittedBox(
//                                       fit: BoxFit.contain,
//                                       alignment: Alignment.center,
//                                       child: Text(
//                                               'Chat with ${global.getSystemFlagValueForLogin(global.systemFlagNameList.professionTitle)}',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.w500,
//                                                   color: Colors.white,
//                                                   fontSize: 14.sp))
//                                           .tr(),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )),
//                       ),
//                       SizedBox(
//                         width: 2.w,
//                       ),
//                       InkWell(
//                         onTap: () async {
//                           global.showOnlyLoaderDialog(context);
//                           bottomController.astrologerList = [];
//                           bottomController.astrologerList.clear();
//                           bottomController.isAllDataLoaded = false;
//                           bottomController.update();
//                           await bottomController.getAstrologerList(
//                               isLazyLoading: false);
//                           global.hideLoader();
//                           bottomController.setBottomIndex(3, 0);
//                         },
//                         child: Container(
//                             width: Adaptive.w(43),
//                             decoration: BoxDecoration(
//                               color: Get.theme.primaryColor,
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(4.w),
//                               ),
//                             ),
//                             child: Container(
//                               padding: EdgeInsets.only(left: 1.5.w),
//                               height: 6.h,
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.phone,
//                                     size: 14.sp,
//                                     color: Colors.white,
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.only(left: 2.w),
//                                     child: FittedBox(
//                                       child: Text(
//                                               'Talk to ${global.getSystemFlagValueForLogin(global.systemFlagNameList.professionTitle)}',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.w500,
//                                                   color: Colors.white,
//                                                   fontSize: 14.sp))
//                                           .tr(),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             );
//           }),
//         ),
//         floatingActionButton: SizedBox(
//           height: 45,
//           width: 45,
//           child: global.currentUserId != null
//               ? FloatingActionButton(
//                   backgroundColor: Get.theme.primaryColor,
//                   onPressed: () async {
//                     global.showOnlyLoaderDialog(context);
//                     await aicontroller.getAIChatAstrologerId();
//                     await aicontroller.getcharge();
//                     aicontroller.update();
//                     print("Floating icons is clicked");
//                     global.hideLoader();
//                     Get.dialog(
//                       AlertDialog(
//                         backgroundColor: Colors.white,
//                         contentPadding: const EdgeInsets.only(
//                             top: 8, left: 20, right: 20, bottom: 30),
//                         titlePadding: const EdgeInsets.all(10),
//                         title: Align(
//                             alignment: Alignment.center,
//                             child: Container(
//                               padding: EdgeInsets.all(2),
//                               decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                       color: Get.theme.primaryColor)),
//                               child: CircleAvatar(
//                                 radius: 30,
//                                 backgroundColor:
//                                     Get.theme.primaryColor.withOpacity(0.5),
//                                 child: Icon(
//                                   aicontroller.islowBalance
//                                       ? aicontroller.aichatcharge!.message ==
//                                               'Please update your profile.'
//                                           ? Icons.person
//                                           : Icons.wallet
//                                       : Icons.question_mark,
//                                   color: Colors.red,
//                                 ),
//                               ),
//                             )),
//                         content: Text(
//                           '${aicontroller.aichatcharge!.message}',
//                           style: Get.textTheme.bodyMedium,
//                         ).tr(),
//                         actions: [
//                           ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                               ),
//                               onPressed: () {
//                                 Get.back();
//                               },
//                               child: Text(
//                                 'No',
//                                 style: Get.textTheme.bodyMedium!.copyWith(
//                                     color: Colors.white,
//                                     fontSize: 16.sp,
//                                     fontWeight: FontWeight.w500),
//                               )),
//                           ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                               ),
//                               onPressed: () async {
//                                 if (aicontroller.aichatcharge!.message ==
//                                     "Please update your profile.") {
//                                   Get.back();
//                                   bool isLogin = await global.isLogin();
//                                   if (isLogin) {
//                                     global.showOnlyLoaderDialog(context);
//                                     await splashController.getCurrentUserData();
//                                     global.hideLoader();
//                                     Get.to(() => EditUserProfile());
//                                   }
//                                 } else if (aicontroller.islowBalance) {
//                                   Get.back();
//                                   bool isLogin = await global.isLogin();
//                                   global.showOnlyLoaderDialog(context);
//                                   await global.splashController
//                                       .getCurrentUserData();
//                                   await walletController.getAmount();
//                                   walletController.update();
//                                   splashController.update();
//                                   global.hideLoader();
//                                   if (isLogin) {
//                                     Get.to(() => AddmoneyToWallet());
//                                   }
//                                 } else {
//                                   Get.back();
//                                   Get.to(() => AiChatScreen(
//                                       name:
//                                           '${aicontroller.aiAstrologerId!.recordList!.name}',
//                                       imagepath:
//                                           '${aicontroller.aiAstrologerId!.recordList!.image}',
//                                       id: aicontroller
//                                           .aiAstrologerId!.recordList!.id));
//                                 }
//                               },
//                               child: Text(
//                                 aicontroller.islowBalance
//                                     ? aicontroller.aichatcharge!.message ==
//                                             'Please update your profile.'
//                                         ? tr('Update')
//                                         : tr('TopUp')
//                                     : 'Yes',
//                                 style: Get.textTheme.bodyMedium!.copyWith(
//                                     color: Colors.white,
//                                     fontSize: 16.sp,
//                                     fontWeight: FontWeight.w500),
//                               ))
//                         ],
//                       ),
//                     );
//                   },
//                   child: Image.asset('assets/images/Ai_chat_icons.gif'),
//                 )
//               : SizedBox(),
//         ),
//       ),
//     );
//   }

//   GetBuilder<HomeController> _buildAstroinnewsWidget() {
//     return GetBuilder<HomeController>(builder: (homeController) {
//       return homeController.astroNews.length == 0
//           ? SizedBox()
//           : SizedBox(
//               height: 31.6.h,
//               child: Card(
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom: 5),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                               margin: EdgeInsets.symmetric(horizontal: 10),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   global.buildTranslatedText(
//                                     '${global.getSystemFlagValueForLogin(global.systemFlagNameList.appName)} in News',
//                                     Get.theme.primaryTextTheme.titleMedium!
//                                         .copyWith(fontWeight: FontWeight.w500),
//                                   )
//                                 ],
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 Get.to(() => AstrologerNewsScreen());
//                               },
//                               child: Text(
//                                 'View All',
//                                 style: Get.theme.primaryTextTheme.bodySmall!
//                                     .copyWith(
//                                   fontWeight: FontWeight.w400,
//                                   color: Colors.blue[500],
//                                 ),
//                               ).tr(),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         height: 0.7.h,
//                       ),
//                       Expanded(
//                           child: ListView.builder(
//                         itemCount: homeController.astroNews.length,
//                         shrinkWrap: true,
//                         scrollDirection: Axis.horizontal,
//                         padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
//                         itemBuilder: (context, index) {
//                           return GestureDetector(
//                             onTap: () {
//                               Get.to(() => BlogScreen(
//                                     link: homeController.astroNews[index].link,
//                                   ));
//                             },
//                             child: Card(
//                               elevation: 4,
//                               margin: EdgeInsets.only(right: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(5),
//                               ),
//                               child: Container(
//                                 width: 190,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     ClipRRect(
//                                       borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(5),
//                                         topRight: Radius.circular(5),
//                                       ),
//                                       child: CachedNetworkImage(
//                                         imageUrl: global.buildImageUrl(
//                                             '${homeController.astroNews[index].bannerImage}'),
//                                         imageBuilder:
//                                             (context, imageProvider) =>
//                                                 Container(
//                                           height: 110,
//                                           width: Get.width,
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                             image: DecorationImage(
//                                               fit: BoxFit.fill,
//                                               image: imageProvider,
//                                             ),
//                                           ),
//                                         ),
//                                         placeholder: (context, url) =>
//                                             const Center(
//                                                 child:
//                                                     CircularProgressIndicator()),
//                                         errorWidget: (context, url, error) =>
//                                             Image.asset(
//                                           Images.blog,
//                                           height: Get.height * 0.15,
//                                           width: Get.width,
//                                           fit: BoxFit.fill,
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 5, right: 5, top: 3, bottom: 3),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Container(
//                                             height: 7.h,
//                                             child: Text(
//                                               homeController
//                                                   .astroNews[index].description,
//                                               textAlign: TextAlign.start,
//                                               maxLines: 2,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: Get
//                                                   .theme.textTheme.titleMedium!
//                                                   .copyWith(
//                                                 fontSize: 13,
//                                                 fontWeight: FontWeight.w500,
//                                                 letterSpacing: 0,
//                                               ),
//                                             ).tr(),
//                                           ),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(
//                                                 homeController
//                                                     .astroNews[index].channel,
//                                                 textAlign: TextAlign.center,
//                                                 style: Get.theme.textTheme
//                                                     .titleMedium!
//                                                     .copyWith(
//                                                   fontSize: 11,
//                                                   fontWeight: FontWeight.w500,
//                                                   color: Colors.grey[700],
//                                                   letterSpacing: 0,
//                                                 ),
//                                               ).tr(),
//                                               Text(
//                                                 "${DateFormat("MMM d, yyyy").format(DateTime.parse(homeController.astroNews[index].newsDate.toString()))}",
//                                                 textAlign: TextAlign.center,
//                                                 style: Get.theme.textTheme
//                                                     .titleMedium!
//                                                     .copyWith(
//                                                   fontSize: 11,
//                                                   fontWeight: FontWeight.w500,
//                                                   color: Colors.grey[700],
//                                                   letterSpacing: 0,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ))
//                     ],
//                   ),
//                 ),
//               ),
//             );
//     });
//   }

//   GetBuilder<HomeController> _buildbehindthescenwidget() {
//     return GetBuilder<HomeController>(builder: (homeController) {
//       return SizedBox(
//         height: 30.h,
//         child: Card(
//           elevation: 0,
//           margin: EdgeInsets.only(top: 6),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//           child: Padding(
//             padding: const EdgeInsets.only(
//               top: 2,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   margin: EdgeInsets.symmetric(horizontal: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Behind the scene',
//                         style: Get.theme.primaryTextTheme.titleMedium!
//                             .copyWith(fontWeight: FontWeight.w500),
//                       ).tr(),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   height: 25.h,
//                   width: Get.width,
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       homeController.videoPlayerController!.value.isInitialized
//                           ? Card(
//                               margin:
//                                   EdgeInsets.only(left: 10, right: 10, top: 10),
//                               elevation: 5,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(15)),
//                               child: SizedBox(
//                                 height: 200,
//                                 width: Get.width,
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(10),
//                                   child: AspectRatio(
//                                     aspectRatio: homeController
//                                         .videoPlayerController!
//                                         .value
//                                         .aspectRatio,
//                                     child: VideoPlayerWidget(
//                                       controller:
//                                           homeController.videoPlayerController!,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             )
//                           : SizedBox(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//   }

//   GetBuilder<BottomNavigationController> _buildAstrologerslistwidget(
//       BuildContext context) {
//     return GetBuilder<BottomNavigationController>(
//         builder: (bottomNavigationController) {
//       return bottomNavigationController.astrologerList.isEmpty
//           ? const SizedBox()
//           : Container(
//               width: 100.w,
//               margin: EdgeInsets.symmetric(horizontal: 3.w),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: List.generate(
//                     bottomNavigationController.astrologerList.length,
//                     (index) => InkWell(
//                       onTap: () async {
//                         //clikcked

//                         Get.find<ReviewController>().getReviewData(
//                             bottomNavigationController
//                                 .astrologerList[index].id!);
//                         global.showOnlyLoaderDialog(context);
//                         await bottomNavigationController.getAstrologerbyId(
//                             bottomNavigationController
//                                 .astrologerList[index].id!);
//                         global.hideLoader();
//                         await Get.to(() => AstrologerProfile(
//                               index: index,
//                             ));
//                       },
//                       child: Stack(
//                         children: [
//                           Card(
//                             surfaceTintColor: bottomNavigationController
//                                         .astrologerList[index].isBoosted ==
//                                     Images.ISBOOSTED
//                                 ? Colors.lightGreen
//                                 : Get.theme.primaryColor.withOpacity(0.2),
//                             child: Container(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 1.w, vertical: 2.w),
//                               width: 40.w,
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     height: 2.h,
//                                     width: 100.w,
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         CircleAvatar(
//                                           radius: 1.4.h,
//                                           backgroundColor:
//                                               bottomNavigationController
//                                                               .astrologerList[
//                                                                   index]
//                                                               .callStatus ==
//                                                           "Offline" &&
//                                                       bottomNavigationController
//                                                               .astrologerList[
//                                                                   index]
//                                                               .chatStatus ==
//                                                           "Offline"
//                                                   ? Colors.red
//                                                   : bottomNavigationController
//                                                               .astrologerList[
//                                                                   index]
//                                                               .callStatus ==
//                                                           "Busy"
//                                                       ? Colors.orange
//                                                       : Colors.green,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(height: 1.h),
//                                   Stack(
//                                     alignment: Alignment.center,
//                                     clipBehavior: Clip.none,
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(
//                                           FontSizes(context).width4(),
//                                         ),
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             border: Border.all(
//                                                 width: 1,
//                                                 color: Get.theme.primaryColor),
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: CircleAvatar(
//                                             foregroundColor: Colors.white,
//                                             backgroundColor: Colors.white,
//                                             radius: 5.h,
//                                             child: CachedNetworkImage(
//                                               fit: BoxFit.contain,
//                                               imageUrl: global.buildImageUrl(
//                                                   '${bottomNavigationController.astrologerList[index].profileImage}'),
//                                               imageBuilder:
//                                                   (context, imageProvider) {
//                                                 return CircleAvatar(
//                                                   radius: 5.h,
//                                                   backgroundColor: Colors.white,
//                                                   backgroundImage:
//                                                       imageProvider,
//                                                 );
//                                               },
//                                               placeholder: (context, url) =>
//                                                   const Center(
//                                                       child:
//                                                           CircularProgressIndicator()),
//                                               errorWidget:
//                                                   (context, url, error) =>
//                                                       Image.asset(
//                                                 Images.deafultUser,
//                                                 fit: BoxFit.cover,
//                                                 height: 50,
//                                                 width: 40,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       Positioned(
//                                           right: 4.w,
//                                           bottom: -2.w,
//                                           left: 4.w,
//                                           child: Container(
//                                             width: 29.w,
//                                             height: 2.h,
//                                             padding: EdgeInsets.symmetric(
//                                                 horizontal: 1),
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(2.w)),
//                                               border: Border.all(
//                                                   color: Get.theme.primaryColor,
//                                                   width: 1),
//                                             ),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.spaceEvenly,
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.center,
//                                               children: [
//                                                 Icon(
//                                                   Icons.star,
//                                                   color: Get.theme.primaryColor,
//                                                   size: 15.sp,
//                                                 ),
//                                                 Center(
//                                                   child: Text(
//                                                     textAlign: TextAlign.center,
//                                                     bottomNavigationController
//                                                                 .astrologerList[
//                                                                     index]
//                                                                 .rating ==
//                                                             0.0
//                                                         ? "4.5"
//                                                         : "${bottomNavigationController.astrologerList[index].rating!.toStringAsFixed(1)}",
//                                                     style: Get.theme.textTheme
//                                                         .bodySmall!
//                                                         .copyWith(
//                                                       color: Colors.black,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 SizedBox(width: 1),
//                                               ],
//                                             ),
//                                           ))
//                                     ],
//                                   ),
//                                   SizedBox(height: 2.h),
//                                   CustomText(
//                                     text:
//                                         "${bottomNavigationController.astrologerList[index].name!.length > 13 ? "${bottomNavigationController.astrologerList[index].name!.substring(0, 13)}.." : bottomNavigationController.astrologerList[index].name}",
//                                     textAlign: TextAlign.center,
//                                     maxLine: 2,
//                                     fontWeight: FontWeight.w500,
//                                     fontsize: 16.sp,
//                                   ),
//                                   CustomText(
//                                     text:
//                                         "Exp. ${bottomNavigationController.astrologerList[index].experienceInYears} Years",
//                                     textAlign: TextAlign.center,
//                                     maxLine: 2,
//                                     fontWeight: FontWeight.w500,
//                                     fontsize: 15.sp,
//                                   ),
//                                   SizedBox(
//                                     height: 3.h,
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           Icons.language,
//                                           color: Colors.grey,
//                                           size: 17.sp,
//                                         ),
//                                         SizedBox(width: 2),
//                                         CustomText(
//                                           text:
//                                               "${bottomNavigationController.astrologerList[index].languageKnown!.length > 14 ? "${bottomNavigationController.astrologerList[index].languageKnown!.substring(0, 14)}.." : bottomNavigationController.astrologerList[index].languageKnown}",
//                                           textAlign: TextAlign.center,
//                                           maxLine: 2,
//                                           fontWeight: FontWeight.w500,
//                                           fontsize: 15.sp,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 0.7.h,
//                                   ),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       InkWell(
//                                         onTap: () async {
//                                           bool isLogin = await global.isLogin();
//                                           _logedIn(
//                                               context,
//                                               isLogin,
//                                               index,
//                                               true,
//                                               bottomNavigationController
//                                                   .astrologerList[index]
//                                                   .charge);
//                                         },
//                                         child: CircleAvatar(
//                                           radius: 18,
//                                           backgroundColor:
//                                               bottomNavigationController
//                                                           .astrologerList[index]
//                                                           .call_sections
//                                                           .toString() ==
//                                                       "0"
//                                                   ? Colors.grey
//                                                   : (bottomNavigationController
//                                                               .astrologerList[
//                                                                   index]
//                                                               .callStatus ==
//                                                           "Online"
//                                                       ? Colors.green
//                                                       : Colors.orangeAccent),
//                                           child: Center(
//                                             child: Icon(
//                                               Icons.call,
//                                               color: Colors.white,
//                                               size: 15,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: 4.w,
//                                       ),
//                                       InkWell(
//                                         onTap: () async {
//                                           bool isLogin = await global.isLogin();
//                                           if (isLogin) {
//                                             if (bottomNavigationController
//                                                     .astrologerList[index]
//                                                     .chat_sections
//                                                     .toString() ==
//                                                 "0") {
//                                               Get.snackbar("Note",
//                                                   "${global.getSystemFlagValueForLogin(global.systemFlagNameList.professionTitle)} disabled Chat",
//                                                   backgroundColor:
//                                                       Colors.orange,
//                                                   colorText: Colors.white);
//                                             } else {
//                                               await bottomNavigationController
//                                                   .getAstrologerbyId(
//                                                       bottomNavigationController
//                                                           .astrologerList[index]
//                                                           .id);
//                                               if (double.parse(bottomNavigationController
//                                                               .astrologerList[
//                                                                   index]
//                                                               .charge
//                                                               .toString()) *
//                                                           5.0 <=
//                                                       double.parse(global
//                                                           .splashController
//                                                           .currentUser!
//                                                           .walletAmount
//                                                           .toString()) ||
//                                                   bottomNavigationController
//                                                           .astrologerList[index]
//                                                           .isFreeAvailable ==
//                                                       true) {
//                                                 await bottomNavigationController
//                                                     .checkAlreadyInReq(
//                                                         bottomNavigationController
//                                                             .astrologerList[
//                                                                 index]
//                                                             .id);
//                                                 if (bottomNavigationController
//                                                         .isUserAlreadyInChatReq ==
//                                                     false) {
//                                                   if (bottomNavigationController
//                                                           .astrologerList[index]
//                                                           .chatStatus ==
//                                                       "Online") {
//                                                     global.showOnlyLoaderDialog(
//                                                         context);

//                                                     await Get.to(() =>
//                                                         CallIntakeFormScreen(
//                                                           type: "Chat",
//                                                           astrologerId:
//                                                               bottomNavigationController
//                                                                   .astrologerList[
//                                                                       index]
//                                                                   .id,
//                                                           astrologerName:
//                                                               bottomNavigationController
//                                                                   .astrologerList[
//                                                                       index]
//                                                                   .name
//                                                                   .toString(),
//                                                           astrologerProfile:
//                                                               bottomNavigationController
//                                                                   .astrologerList[
//                                                                       index]
//                                                                   .profileImage
//                                                                   .toString(),
//                                                           isFreeAvailable:
//                                                               bottomNavigationController
//                                                                   .astrologerList[
//                                                                       index]
//                                                                   .isFreeAvailable,
//                                                           rate: bottomNavigationController
//                                                               .astrologerList[
//                                                                   index]
//                                                               .charge,
//                                                         ));
//                                                     global.hideLoader();
//                                                   } else if (bottomNavigationController
//                                                               .astrologerList[
//                                                                   index]
//                                                               .chatStatus ==
//                                                           "Offline" ||
//                                                       bottomNavigationController
//                                                               .astrologerList[
//                                                                   index]
//                                                               .chatStatus ==
//                                                           "Busy" ||
//                                                       bottomNavigationController
//                                                               .astrologerList[
//                                                                   index]
//                                                               .chatStatus ==
//                                                           "Wait Time") {
//                                                     bottomNavigationController
//                                                         .dialogForJoinInWaitList(
//                                                             context,
//                                                             bottomNavigationController
//                                                                 .astrologerList[
//                                                                     index]
//                                                                 .name
//                                                                 .toString(),
//                                                             true,
//                                                             bottomNavigationController
//                                                                 .astrologerbyId[
//                                                                     0]
//                                                                 .chatStatus
//                                                                 .toString(),
//                                                             bottomNavigationController
//                                                                 .astrologerList[
//                                                                     index]
//                                                                 .profileImage
//                                                                 .toString());
//                                                   }
//                                                 } else {
//                                                   bottomNavigationController
//                                                       .dialogForNotCreatingSession(
//                                                           context);
//                                                 }
//                                               } else {
//                                                 global.showOnlyLoaderDialog(
//                                                     context);
//                                                 await walletController
//                                                     .getAmount();
//                                                 global.hideLoader();
//                                                 openBottomSheetRechrage(
//                                                     context,
//                                                     (bottomNavigationController
//                                                                 .astrologerList[
//                                                                     index]
//                                                                 .charge *
//                                                             5)
//                                                         .toString(),
//                                                     bottomNavigationController
//                                                         .astrologerList[index]
//                                                         .name
//                                                         .toString());
//                                               }
//                                             }
//                                           }
//                                         },
//                                         child: CircleAvatar(
//                                           radius: 18,
//                                           backgroundColor:
//                                               bottomNavigationController
//                                                           .astrologerList[index]
//                                                           .chat_sections
//                                                           .toString() ==
//                                                       "0"
//                                                   ? Colors.grey
//                                                   : (bottomNavigationController
//                                                               .astrologerList[
//                                                                   index]
//                                                               .chatStatus ==
//                                                           "Online"
//                                                       ? Colors.green
//                                                       : Colors.orangeAccent),
//                                           child: Center(
//                                             child: Icon(
//                                               Icons.chat,
//                                               color: Colors.white,
//                                               size: 15,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 2.w),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           bottomNavigationController
//                                       .astrologerList[index].isBoosted ==
//                                   Images.ISBOOSTED
//                               ? Positioned(
//                                   left: 0,
//                                   top: 0,
//                                   child: CornerBanner(
//                                     bannerPosition:
//                                         CornerBannerPosition.topLeft,
//                                     bannerColor: Colors.grey.shade300,
//                                     child: Text(
//                                       "Sponsored",
//                                       style: TextStyle(
//                                         fontSize: 13.sp,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               : SizedBox(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//     });
//   }

//   GetBuilder<AstrologerCategoryController> _catAstrologerslistwidget(
//       BuildContext context, int catindex) {
//     return GetBuilder<AstrologerCategoryController>(
//         builder: (astrologerCategoryWise) {
//       return astrologerCategoryWise.categoryList[catindex].astrologers!.isEmpty
//           ? const SizedBox()
//           : Container(
//               width: 100.w,
//               margin: EdgeInsets.symmetric(horizontal: 3.w),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: List.generate(
//                     astrologerCategoryWise
//                         .categoryList[catindex].astrologers!.length,
//                     (index) => InkWell(
//                       onTap: () async {
//                         Get.find<ReviewController>().getReviewData(
//                             astrologerCategoryWise.categoryList[catindex]
//                                 .astrologers![index].id!);
//                         global.showOnlyLoaderDialog(context);
//                         await bottomNavigationController.getAstrologerbyId(
//                             astrologerCategoryWise.categoryList[catindex]
//                                 .astrologers![index].id!);
//                         global.hideLoader();
//                         await Get.to(() => AstrologerProfile(
//                               index: index,
//                             ));
//                       },
//                       child: Stack(
//                         children: [
//                           Card(
//                             color: listcolor[catindex],
//                             surfaceTintColor: astrologerCategoryWise
//                                         .categoryList[catindex]
//                                         .astrologers![index]
//                                         .isBoosted ==
//                                     Images.ISBOOSTED
//                                 ? Colors.lightGreen
//                                 : listcolor[catindex],
//                             child: Container(
//                               padding: EdgeInsets.symmetric(horizontal: 1.w),
//                               width: 42.w,
//                               height: 23.h,
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Container(
//                                     height: 1.8.h,
//                                     width: 100.w,
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         CircleAvatar(
//                                           radius: 1.4.h,
//                                           backgroundColor:
//                                               astrologerCategoryWise
//                                                               .categoryList[
//                                                                   catindex]
//                                                               .astrologers![
//                                                                   index]
//                                                               .callStatus ==
//                                                           "Offline" &&
//                                                       astrologerCategoryWise
//                                                               .categoryList[
//                                                                   catindex]
//                                                               .astrologers![
//                                                                   index]
//                                                               .chatStatus ==
//                                                           "Offline"
//                                                   ? Colors.red
//                                                   : astrologerCategoryWise
//                                                               .categoryList[
//                                                                   catindex]
//                                                               .astrologers![
//                                                                   index]
//                                                               .callStatus ==
//                                                           "Busy"
//                                                       ? Colors.orange
//                                                       : Colors.green,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(height: 0.7.h),
//                                   Stack(
//                                     alignment: Alignment.center,
//                                     clipBehavior: Clip.none,
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(
//                                             FontSizes(context).width4()),
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             border: Border.all(
//                                                 width: 1,
//                                                 color: Get.theme.primaryColor),
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: CircleAvatar(
//                                             foregroundColor: Colors.white,
//                                             backgroundColor: Colors.white,
//                                             radius: 4.6.h,
//                                             child: CachedNetworkImage(
//                                               fit: BoxFit.contain,
//                                               imageUrl: global.buildImageUrl(
//                                                   '${astrologerCategoryWise.categoryList[catindex].astrologers![index].profileImage}'),
//                                               imageBuilder:
//                                                   (context, imageProvider) {
//                                                 return CircleAvatar(
//                                                   radius: 4.6.h,
//                                                   backgroundColor: Colors.white,
//                                                   backgroundImage:
//                                                       imageProvider,
//                                                 );
//                                               },
//                                               placeholder: (context, url) =>
//                                                   const Center(
//                                                       child:
//                                                           CircularProgressIndicator()),
//                                               errorWidget:
//                                                   (context, url, error) =>
//                                                       Image.asset(
//                                                 Images.deafultUser,
//                                                 fit: BoxFit.cover,
//                                                 height: 50,
//                                                 width: 40,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       Positioned(
//                                           right: 4.w,
//                                           bottom: -2.w,
//                                           left: 4.w,
//                                           child: Container(
//                                             width: 29.w,
//                                             height: 2.h,
//                                             padding: EdgeInsets.symmetric(
//                                                 horizontal: 1),
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(2.w)),
//                                               border: Border.all(
//                                                   color: Get.theme.primaryColor,
//                                                   width: 1),
//                                             ),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.spaceEvenly,
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.center,
//                                               children: [
//                                                 Icon(
//                                                   Icons.star,
//                                                   color: Get.theme.primaryColor,
//                                                   size: 15.sp,
//                                                 ),
//                                                 astrologerCategoryWise
//                                                         .categoryList[catindex]
//                                                         .astrologers!
//                                                         .isNotEmpty
//                                                     ? Center(
//                                                         child: Text(
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           astrologerCategoryWise
//                                                                       .categoryList[
//                                                                           catindex]
//                                                                       .astrologers![
//                                                                           index]
//                                                                       .rating ==
//                                                                   0.0
//                                                               ? "3.5"
//                                                               : "${astrologerCategoryWise.categoryList[catindex].astrologers![index].rating!.toStringAsFixed(1)}",
//                                                           style: Get
//                                                               .theme
//                                                               .textTheme
//                                                               .bodySmall!
//                                                               .copyWith(
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       )
//                                                     : SizedBox(),
//                                                 SizedBox(width: 1),
//                                               ],
//                                             ),
//                                           ))
//                                     ],
//                                   ),
//                                   SizedBox(height: 2.h),
//                                   CustomText(
//                                     text:
//                                         "${astrologerCategoryWise.categoryList[catindex].astrologers![index].name!.length > 13 ? "${astrologerCategoryWise.categoryList[catindex].astrologers![index].name!.substring(0, 13)}.." : astrologerCategoryWise.categoryList[catindex].astrologers![index].name}",
//                                     textAlign: TextAlign.center,
//                                     maxLine: 2,
//                                     fontWeight: FontWeight.w500,
//                                     fontsize: 16.sp,
//                                   ),
//                                   CustomText(
//                                     text:
//                                         "Exp. ${astrologerCategoryWise.categoryList[catindex].astrologers![index].experienceInYears} Years",
//                                     textAlign: TextAlign.center,
//                                     maxLine: 2,
//                                     fontWeight: FontWeight.w500,
//                                     fontsize: 15.sp,
//                                   ),
//                                   SizedBox(
//                                     height: 3.h,
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           Icons.language,
//                                           color: Colors.grey,
//                                           size: 17.sp,
//                                         ),
//                                         SizedBox(width: 2),
//                                         CustomText(
//                                           text:
//                                               "${astrologerCategoryWise.categoryList[catindex].astrologers![index].languageKnown!.length > 14 ? "${astrologerCategoryWise.categoryList[catindex].astrologers![index].languageKnown!.substring(0, 14)}.." : astrologerCategoryWise.categoryList[catindex].astrologers![index].languageKnown}",
//                                           textAlign: TextAlign.center,
//                                           maxLine: 2,
//                                           fontWeight: FontWeight.w500,
//                                           fontsize: 15.sp,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 0.7.h,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           astrologerCategoryWise.categoryList[catindex]
//                                       .astrologers![index].isBoosted ==
//                                   Images.ISBOOSTED
//                               ? Positioned(
//                                   left: 0,
//                                   top: 0,
//                                   child: CornerBanner(
//                                     bannerPosition:
//                                         CornerBannerPosition.topLeft,
//                                     bannerColor: Colors.grey.shade300,
//                                     child: Text(
//                                       "Sponsored",
//                                       style: TextStyle(
//                                         fontSize: 13.sp,
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               : SizedBox(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//     });
//   }

//   void refreshIt() async {
//     splashController.currentLanguageCode =
//         homeController.lan[homeController.selectedIndex].lanCode;
//     splashController.update();
//     global.spLanguage = await SharedPreferences.getInstance();
//     global.spLanguage!
//         .setString('currentLanguage', splashController.currentLanguageCode);
//     homeController.refresh();

//     Get.back();
//   }

//   Widget getRecommendedView(HomeController homecontroller) {
//     return Column(
//       children: [
//         Container(
//           margin: EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Recommended Products',
//                     style: Get.theme.primaryTextTheme.titleMedium!
//                         .copyWith(fontWeight: FontWeight.w500),
//                   ).tr(),
//                   GestureDetector(
//                     onTap: () {
//                       Get.to(() => RemcommendedViewAllScreen(
//                           recommendedlist: homecontroller.recomendedList));
//                     },
//                     child: Text(
//                       'View All',
//                       style: Get.theme.primaryTextTheme.bodySmall!.copyWith(
//                         fontWeight: FontWeight.w400,
//                         color: Colors.blue[500],
//                       ),
//                     ).tr(),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         Container(
//           height: 25.h,
//           width: 100.w,
//           margin: EdgeInsets.symmetric(horizontal: FontSizes(context).width3()),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children:
//                   List.generate(homecontroller.recomendedList!.length, (index) {
//                 return Row(
//                   children: [
//                     Stack(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             //
//                             Get.to(() => ProductDetailScreen(
//                                   index: 0,
//                                   productID: homecontroller
//                                       .recomendedList![index].productId!,
//                                 ));
//                           },
//                           child: Container(
//                             padding: EdgeInsets.all(2),
//                             height: 22.h,
//                             width: 40.w,
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 image: DecorationImage(
//                                   onError: (exception, stackTrace) =>
//                                       Image.asset(
//                                     Images.deafultUser,
//                                   ),
//                                   image: NetworkImage(
//                                     '${homecontroller.recomendedList![index].productImage}',
//                                   ),
//                                   fit: BoxFit.cover,
//                                 )),
//                           ),
//                         ),
//                         Positioned(
//                           left: 0,
//                           top: 0,
//                           child: CornerBanner(
//                             bannerPosition: CornerBannerPosition.topLeft,
//                             bannerColor: Colors.red,
//                             child: Text(
//                               '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} '
//                               '${homecontroller.recomendedList![index].amount}',
//                               style: TextStyle(
//                                 fontSize: 13.sp,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                                 fontFamily: 'Poppins-Regular',
//                               ),
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                             left: 0,
//                             right: 0,
//                             bottom: 0,
//                             child: Container(
//                               height: 5.h,
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.only(
//                                       bottomLeft: Radius.circular(10),
//                                       bottomRight: Radius.circular(10)),
//                                   color: Colors.black26),
//                               child: Center(
//                                 child: Column(
//                                   children: [
//                                     Text(
//                                       '${homecontroller.recomendedList![index].productName!.length > 14 ? homecontroller.recomendedList![index].productName!.substring(0, 14) + '..' : homecontroller.recomendedList![index].productName}',
//                                       style: Get.theme.textTheme.bodySmall!
//                                           .copyWith(
//                                               fontWeight: FontWeight.w400,
//                                               color: Colors.white),
//                                     ),
//                                     Text(
//                                       'by [${homecontroller.recomendedList![index].astrologerName!.length > 14 ? homecontroller.recomendedList![index].astrologerName!.substring(0, 14) + '..' : homecontroller.recomendedList![index].astrologerName} ]',
//                                       style: Get.theme.textTheme.bodySmall!
//                                           .copyWith(
//                                               fontWeight: FontWeight.w400,
//                                               color: Colors.white),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ))
//                       ],
//                     ),
//                     SizedBox(width: 2.w)
//                   ],
//                 );
//               }),
//             ),
//           ),
//         ),
//         SizedBox(
//           width: 5,
//         ),
//       ],
//     );
//   }

//   Widget getPujaRecommendedView(HomeController homecontroller) {
//     return Column(
//       children: [
//         Container(
//           margin: EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Recommended Puja',
//                     style: Get.theme.primaryTextTheme.titleMedium!
//                         .copyWith(fontWeight: FontWeight.w500),
//                   ).tr(),
//                   GestureDetector(
//                     child: Text(
//                       'View All',
//                       style: Get.theme.primaryTextTheme.bodySmall!.copyWith(
//                         fontWeight: FontWeight.w400,
//                         color: Colors.blue[500],
//                       ),
//                     ).tr(),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         Container(
//           height: 25.h,
//           width: 100.w,
//           margin: EdgeInsets.symmetric(horizontal: FontSizes(context).width3()),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children:
//                   List.generate(homecontroller.recomendedList!.length, (index) {
//                 return Row(
//                   children: [
//                     Stack(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             // Get.to(() => ProductDetailScreen(
//                             //       index: 0,
//                             //       productID: homecontroller
//                             //           .recomendedList![index].productId!,
//                             //     ));
//                             Get.to(() => RecommendedPoojadetailscreen(
//                                   poojaItem:
//                                       homecontroller.pujarecomendedList![index],
//                                 ));
//                           },
//                           child: Container(
//                             padding: EdgeInsets.all(2),
//                             height: 22.h,
//                             width: 40.w,
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 image: DecorationImage(
//                                   onError: (exception, stackTrace) =>
//                                       Image.asset(
//                                     Images.deafultUser,
//                                   ),
//                                   image: NetworkImage(
//                                     '$webBaseUrl/${homecontroller.recomendedList![index].productImage}',
//                                   ),
//                                   fit: BoxFit.cover,
//                                 )),
//                           ),
//                         ),
//                         Positioned(
//                           left: 0,
//                           top: 0,
//                           child: CornerBanner(
//                             bannerPosition: CornerBannerPosition.topLeft,
//                             bannerColor: Colors.red,
//                             child: Text(
//                               '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} '
//                               '${homecontroller.recomendedList![index].amount}',
//                               style: TextStyle(
//                                 fontSize: 13.sp,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                                 fontFamily: 'Poppins-Regular',
//                               ),
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                             left: 0,
//                             right: 0,
//                             bottom: 0,
//                             child: Container(
//                               height: 5.h,
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.only(
//                                       bottomLeft: Radius.circular(10),
//                                       bottomRight: Radius.circular(10)),
//                                   color: Colors.black26),
//                               child: Center(
//                                 child: Column(
//                                   children: [
//                                     Text(
//                                       '${homecontroller.recomendedList![index].productName!.length > 14 ? homecontroller.recomendedList![index].productName!.substring(0, 14) + '..' : homecontroller.recomendedList![index].productName}',
//                                       style: Get.theme.textTheme.bodySmall!
//                                           .copyWith(
//                                               fontWeight: FontWeight.w400,
//                                               color: Colors.white),
//                                     ),
//                                     Text(
//                                       'by [${homecontroller.recomendedList![index].astrologerName!.length > 14 ? homecontroller.recomendedList![index].astrologerName!.substring(0, 14) + '..' : homecontroller.recomendedList![index].astrologerName} ]',
//                                       style: Get.theme.textTheme.bodySmall!
//                                           .copyWith(
//                                               fontWeight: FontWeight.w400,
//                                               color: Colors.white),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ))
//                       ],
//                     ),
//                     SizedBox(width: 2.w)
//                   ],
//                 );
//               }),
//             ),
//           ),
//         ),
//         SizedBox(
//           width: 5,
//         ),
//       ],
//     );
//   }
// }

// class _buildCategoriesWidget extends StatelessWidget {
//   const _buildCategoriesWidget({
//     required this.bottomNavigationController,
//     required this.chatController,
//   });

//   final BottomNavigationController bottomNavigationController;
//   final ChatController chatController;

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<AstrologerCategoryController>(builder: (astrologyCat) {
//       return Container(
//           height: 12.h,
//           margin: EdgeInsets.symmetric(horizontal: FontSizes(context).width3()),
//           child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: astrologyCat.categoryList.length,
//               shrinkWrap: true,
//               itemBuilder: (context, index) {
//                 return InkWell(
//                   onTap: () async {
//                     global.showOnlyLoaderDialog(context);
//                     bottomNavigationController.astrologerList = [];
//                     bottomNavigationController.astrologerList.clear();
//                     bottomNavigationController.isAllDataLoaded = false;
//                     bottomNavigationController.update();
//                     chatController.isSelected = index;
//                     chatController.update();
//                     await bottomNavigationController.astroCat(
//                         id: astrologyCat.categoryList[index].id!,
//                         isLazyLoading: false);
//                     global.hideLoader();
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => CallScreen(
//                                   flag: 1,
//                                 )));
//                   },
//                   child: Container(
//                     alignment: Alignment.center,
//                     margin: EdgeInsets.symmetric(horizontal: 10),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         CircleAvatar(
//                           backgroundColor: Colors.white,
//                           radius: FontSizes(context).width7(),
//                           backgroundImage: NetworkImage(
//                               "${astrologyCat.categoryList[index].image}"),
//                         ),
//                         SizedBox(
//                           height: FontSizes(context).height1(),
//                         ),
//                         CustomText(
//                           text: "${astrologyCat.categoryList[index].name}",
//                           textAlign: TextAlign.center,
//                           maxLine: 2,
//                           fontWeight: FontWeight.w600,
//                           fontsize: FontSizes(context).font3(),
//                         )
//                       ],
//                     ),
//                   ),
//                 );
//               }));
//     });
//   }
// }

// class CustomClipPath extends CustomClipper<Path> {
//   var radius = 10.0;
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, 100);
//     path.lineTo(250, 100);
//     path.lineTo(0, 100);
//     path.lineTo(200, 300);
//     path.lineTo(90, 0);
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => true;
// }

// /////

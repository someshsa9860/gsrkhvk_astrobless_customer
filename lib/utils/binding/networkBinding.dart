import 'package:callvcal/controllers/astrologerCategoryController.dart';
import 'package:callvcal/controllers/astrologer_assistant_controller.dart';
import 'package:callvcal/controllers/astrologyBlogController.dart';
import 'package:callvcal/controllers/astromallController.dart';
import 'package:callvcal/controllers/callController.dart';
import 'package:callvcal/controllers/IntakeController.dart';
import 'package:callvcal/controllers/chatController.dart';
import 'package:callvcal/controllers/customer_support_controller.dart';
import 'package:callvcal/controllers/dailyHoroscopeController.dart';
import 'package:callvcal/controllers/dropDownController.dart';
import 'package:callvcal/controllers/filtterTabController.dart';
import 'package:callvcal/controllers/follow_astrologer_controller.dart';
import 'package:callvcal/controllers/freeServiceController.dart';
import 'package:callvcal/controllers/gift_controller.dart';
import 'package:callvcal/controllers/history_controller.dart';
import 'package:callvcal/controllers/homeController.dart';
import 'package:callvcal/controllers/imageController.dart';
import 'package:callvcal/controllers/kundliController.dart';
import 'package:callvcal/controllers/kundliMatchingController.dart';
import 'package:callvcal/controllers/languageController.dart';
import 'package:callvcal/controllers/life_cycle_controller.dart';
import 'package:callvcal/controllers/liveAstrologerController.dart';
import 'package:callvcal/controllers/loginController.dart';
import 'package:callvcal/controllers/networkController.dart';
import 'package:callvcal/controllers/onboardController.dart';
import 'package:callvcal/controllers/reportController.dart';
import 'package:callvcal/controllers/reportTabFiltter.dart';
import 'package:callvcal/controllers/reviewController.dart';
import 'package:callvcal/controllers/search_controller.dart';
import 'package:callvcal/controllers/search_place_controller.dart';
import 'package:callvcal/controllers/settings_controller.dart';
import 'package:callvcal/controllers/skillController.dart';
import 'package:callvcal/controllers/splashController.dart';
import 'package:callvcal/controllers/themeController.dart';
import 'package:callvcal/controllers/timer_controller.dart';
import 'package:callvcal/controllers/upcoming_controller.dart';
import 'package:callvcal/controllers/userProfileController.dart';
import 'package:callvcal/controllers/walletController.dart';
import 'package:callvcal/views/poojaBooking/controller/poojaController.dart';
import 'package:get/get.dart';
import 'package:callvcal/controllers/bottomNavigationController.dart';
import '../../controllers/ChatTimerUpdate.dart';
import '../../controllers/advancedPanchangController.dart';
import '../../controllers/counsellorController.dart';
import '../../controllers/liveController.dart';
import '../../controllers/trackingchatController.dart';

class NetworkBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BottomNavigationController());
    Get.put(PoojaController());

    Get.put(LiveController());
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);
    Get.lazyPut<CallController>(() => CallController(), fenix: true);
    Get.lazyPut<UserProfileController>(() => UserProfileController(),
        fenix: true);
    Get.lazyPut<ReportController>(() => ReportController(), fenix: true);
    Get.lazyPut<DropDownController>(() => DropDownController(), fenix: true);
    Get.lazyPut<AstromallController>(() => AstromallController(), fenix: true);
    Get.lazyPut<WalletController>(() => WalletController(), fenix: true);
    Get.lazyPut<DailyHoroscopeController>(() => DailyHoroscopeController(),
        fenix: true);
    Get.lazyPut<KundliController>(() => KundliController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<AstrologerCategoryController>(
        () => AstrologerCategoryController(),
        fenix: true);
    Get.lazyPut<FreeServiceController>(() => FreeServiceController(),
        fenix: true);
    Get.lazyPut<KundliMatchingController>(() => KundliMatchingController(),
        fenix: true);
    Get.lazyPut<CounsellorController>(() => CounsellorController(),
        fenix: true);
    Get.lazyPut<NetworkController>(() => NetworkController(), fenix: true);
    Get.lazyPut<GiftController>(() => GiftController(), fenix: true);
    Get.lazyPut<SearchPlaceController>(() => SearchPlaceController(),
        fenix: true);
    Get.lazyPut<ImageControlller>(() => ImageControlller(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
    Get.lazyPut<FollowAstrologerController>(() => FollowAstrologerController(),
        fenix: true);
    Get.lazyPut<ReviewController>(() => ReviewController(), fenix: true);
    Get.lazyPut<SkillController>(() => SkillController(), fenix: true);
    Get.lazyPut<LanguageController>(() => LanguageController(), fenix: true);
    Get.lazyPut<HomeCheckController>(() => HomeCheckController(), fenix: true);
    Get.lazyPut<FiltterTabController>(() => FiltterTabController(),
        fenix: true);
    Get.lazyPut<TimerController>(() => TimerController(), fenix: true);
    Get.lazyPut<LiveAstrologerController>(() => LiveAstrologerController(),
        fenix: true);
    Get.lazyPut<PanchangController>(() => PanchangController(), fenix: true);
    Get.lazyPut<IntakeController>(() => IntakeController(), fenix: true);
    Get.lazyPut<ReportFilterTabController>(() => ReportFilterTabController(),
        fenix: true);
    Get.lazyPut<SearchControllerCustom>(() => SearchControllerCustom(),
        fenix: true);
    Get.lazyPut<HistoryController>(() => HistoryController(), fenix: true);
    Get.lazyPut<BlogController>(() => BlogController(), fenix: true);
    Get.lazyPut<CustomerSupportController>(() => CustomerSupportController(),
        fenix: true);
    Get.lazyPut<AstrologerAssistantController>(
        () => AstrologerAssistantController(),
        fenix: true);
    Get.lazyPut<UpcomingController>(() => UpcomingController(), fenix: true);
    Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);
    Get.lazyPut<ChatTimerController>(() => ChatTimerController(), fenix: true);
    Get.lazyPut<TrackingChatController>(() => TrackingChatController(),
        fenix: true);
    Get.lazyPut<OnBoardController>(() => OnBoardController(), fenix: true);
  }
}

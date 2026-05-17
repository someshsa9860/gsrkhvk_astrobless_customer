// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:easy_localization/easy_localization.dart';

// // Replace your existing profile card code with this
// Container(
//   padding: EdgeInsets.symmetric(horizontal: 4.w),
//   child: Column(
//     children: [
//       // Profile Image Section
//       Stack(
//         alignment: Alignment.center,
//         clipBehavior: Clip.none,
//         children: [
//           // Background Card
//           Container(
//             margin: EdgeInsets.only(top: 8.h),
//             padding: EdgeInsets.fromLTRB(4.w, 10.h, 4.w, 3.h),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.08),
//                   blurRadius: 20,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // Name Section
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Flexible(
//                       child: Text(
//                         bottomNavigationController.astrologerbyId[0].name ?? '',
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                       ).tr(),
//                     ),
//                     SizedBox(width: 8),
//                     Container(
//                       padding: EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.verified,
//                         color: Colors.blue,
//                         size: 18,
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 SizedBox(height: 1.h),
                
//                 // Skills & Trust Info
//                 Text(
//                   '${bottomNavigationController.astrologerbyId[0].primarySkill}',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade700,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
                
//                 SizedBox(height: 0.5.h),
                
//                 Text(
//                   'Trusted by ${bottomNavigationController.astrologerbyId[0].totalOrder}k Souls',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
                
//                 SizedBox(height: 2.h),
                
//                 // Info Tags Row
//                 Wrap(
//                   alignment: WrapAlignment.center,
//                   spacing: 12,
//                   runSpacing: 12,
//                   children: [
//                     _buildInfoTag(
//                       Icons.language_rounded,
//                       'Speaks ${bottomNavigationController.astrologerbyId[0].languageKnown}',
//                     ),
//                     _buildInfoTag(
//                       Icons.work_outline_rounded,
//                       '${bottomNavigationController.astrologerbyId[0].experienceInYears}+ Years of Experience',
//                     ),
//                   ],
//                 ),
                
//                 SizedBox(height: 3.h),
                
//                 // Action Buttons
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildActionButton(
//                         icon: CupertinoIcons.phone_fill,
//                         label: 'Audio',
//                         price: bottomNavigationController.astrologerbyId[0].isFreeAvailable == true
//                             ? 'Free'
//                             : '₹ ${bottomNavigationController.astrologerbyId[0].charge}/Min',
//                         color: Colors.green,
//                         isFree: bottomNavigationController.astrologerbyId[0].isFreeAvailable == true,
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: _buildActionButton(
//                         icon: CupertinoIcons.videocam_fill,
//                         label: 'Video',
//                         price: bottomNavigationController.astrologerbyId[0].isFreeAvailable == true
//                             ? 'Free'
//                             : '₹ ${bottomNavigationController.astrologerbyId[0].videoCallRate}/Min',
//                         color: Colors.orange,
//                         isFree: bottomNavigationController.astrologerbyId[0].isFreeAvailable == true,
//                         showBadge: true,
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: _buildActionButton(
//                         icon: CupertinoIcons.chat_bubble_fill,
//                         label: 'Text',
//                         price: bottomNavigationController.astrologerbyId[0].isFreeAvailable == true
//                             ? 'Free'
//                             : '₹ ${bottomNavigationController.astrologerbyId[0].charge}/Min',
//                         color: Colors.blue,
//                         isFree: bottomNavigationController.astrologerbyId[0].isFreeAvailable == true,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
          
//           // Profile Image - Positioned on Top
//           Positioned(
//             top: 0,
//             child: GetBuilder<HomeController>(
//               builder: (homeController) {
//                 return GestureDetector(
//                   onTap: () {
//                     if (homeController.viewSingleStory.length > 0) {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => ViewStoriesScreen(
//                             profile: "${bottomNavigationController.astrologerbyId[0].profileImage}",
//                             name: bottomNavigationController.astrologerbyId[0].name.toString(),
//                             isprofile: true,
//                             astroId: int.parse(bottomNavigationController.astrologerbyId[0].id.toString()),
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 20,
//                           offset: Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Container(
//                       height: 16.h,
//                       width: 16.h,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           width: 3,
//                           color: homeController.viewSingleStory.length == 0
//                               ? Colors.grey.shade300
//                               : Get.theme.primaryColor,
//                         ),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(100),
//                         child: CachedNetworkImage(
//                           imageUrl: "${bottomNavigationController.astrologerbyId[0].profileImage}",
//                           fit: BoxFit.cover,
//                           placeholder: (context, url) => Center(
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Get.theme.primaryColor,
//                             ),
//                           ),
//                           errorWidget: (context, url, error) {
//                             return CircleAvatar(
//                               radius: 40,
//                               backgroundColor: Colors.grey.shade200,
//                               child: Icon(
//                                 Icons.person,
//                                 size: 40,
//                                 color: Colors.grey.shade400,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
          
//           // Badges Icon (Top Left)
//           if (bottomNavigationController.astrologerbyId[0].courseBadges!.isNotEmpty)
//             Positioned(
//               top: 8.h,
//               left: 4.w,
//               child: GestureDetector(
//                 onTap: () {
//                   _showBadgesDialog(context);
//                 },
//                 child: Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: Get.theme.primaryColor,
//                       width: 2,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Get.theme.primaryColor.withOpacity(0.3),
//                         blurRadius: 10,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       Icon(
//                         Icons.workspace_premium_rounded,
//                         color: Get.theme.primaryColor,
//                         size: 24,
//                       ),
//                       Positioned(
//                         right: -8,
//                         top: -8,
//                         child: Container(
//                           padding: EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             shape: BoxShape.circle,
//                           ),
//                           constraints: BoxConstraints(
//                             minWidth: 20,
//                             minHeight: 20,
//                           ),
//                           child: Center(
//                             child: Text(
//                               '${bottomNavigationController.astrologerbyId[0].courseBadges!.length}',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
          
//           // Menu Icon (Top Right)
//           Positioned(
//             top: 8.h,
//             right: 4.w,
//             child: PopupMenuButton(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               icon: Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   Icons.more_vert_rounded,
//                   color: Colors.grey.shade700,
//                   size: 20,
//                 ),
//               ),
//               onSelected: (value) async {
//                 if (value == "block") {
//                   // Your block logic here
//                 }
//                 if (value == "unblock") {
//                   // Your unblock logic here
//                 }
//               },
//               itemBuilder: (context) => [
//                 PopupMenuItem(
//                   child: Row(
//                     children: [
//                       Icon(
//                         bottomNavigationController.astrologerbyId[0].isBlock!
//                             ? Icons.check_circle_outline
//                             : Icons.block_outlined,
//                         size: 20,
//                         color: Colors.grey.shade700,
//                       ),
//                       SizedBox(width: 12),
//                       Text(
//                         bottomNavigationController.astrologerbyId[0].isBlock!
//                             ? 'Unblock'
//                             : 'Report & Block',
//                       ).tr(),
//                     ],
//                   ),
//                   value: bottomNavigationController.astrologerbyId[0].isBlock!
//                       ? "unblock"
//                       : "block",
//                 ),
//               ],
//             ),
//           ),
          
//           // Follow Button
//           Positioned(
//             top: 14.h,
//             right: 4.w,
//             child: bottomNavigationController.astrologerbyId[0].isFollow!
//                 ? Container(
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Get.theme.primaryColor,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Get.theme.primaryColor.withOpacity(0.3),
//                           blurRadius: 10,
//                           offset: Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.check,
//                           color: Colors.white,
//                           size: 16,
//                         ),
//                         SizedBox(width: 4),
//                         Text(
//                           'Following',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ).tr(),
//                       ],
//                     ),
//                   )
//                 : GetBuilder<FollowAstrologerController>(
//                     builder: (followAstrologerController) {
//                       return GestureDetector(
//                         onTap: () async {
//                           bool isLogin = await global.isLogin();
//                           if (isLogin) {
//                             global.showOnlyLoaderDialog(context);
//                             await followAstrologerController.addFollowers(
//                               bottomNavigationController.astrologerbyId[0].id!,
//                             );
//                             global.hideLoader();
//                           }
//                         },
//                         child: Container(
//                           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 Get.theme.primaryColor,
//                                 Get.theme.primaryColor.withOpacity(0.8),
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Get.theme.primaryColor.withOpacity(0.3),
//                                 blurRadius: 10,
//                                 offset: Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.add,
//                                 color: Colors.white,
//                                 size: 16,
//                               ),
//                               SizedBox(width: 4),
//                               Text(
//                                 'Follow',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ).tr(),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     ],
//   ),
// )

// // Helper Widget for Info Tags
// Widget _buildInfoTag(IconData icon, String text) {
//   return Container(
//     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//     decoration: BoxDecoration(
//       color: Colors.grey.shade100,
//       borderRadius: BorderRadius.circular(20),
//     ),
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(
//           icon,
//           size: 16,
//           color: Colors.grey.shade700,
//         ),
//         SizedBox(width: 6),
//         Text(
//           text,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey.shade700,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// // Helper Widget for Action Buttons
// Widget _buildActionButton({
//   required IconData icon,
//   required String label,
//   required String price,
//   required Color color,
//   required bool isFree,
//   bool showBadge = false,
// }) {
//   return Container(
//     padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(
//         color: Colors.grey.shade200,
//         width: 1.5,
//       ),
//     ),
//     child: Stack(
//       clipBehavior: Clip.none,
//       children: [
//         Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color: color,
//                 size: 24,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               price,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: isFree ? Colors.green : Colors.black87,
//               ),
//             ),
//           ],
//         ),
//         if (showBadge)
//           Positioned(
//             top: -8,
//             right: -8,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.amber, Colors.orange],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.orange.withOpacity(0.4),
//                     blurRadius: 8,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 'RECOMMENDED',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 8,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     ),
//   );
// }

// // Badges Dialog Function
// void _showBadgesDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (BuildContext context) {
//       return Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: EdgeInsets.all(16),
//         child: Container(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.7,
//           ),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Get.theme.primaryColor,
//                 Get.theme.primaryColor.withOpacity(0.8),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(24),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header
//               Container(
//                 padding: EdgeInsets.all(20),
//                 child: Row(
//                   children: [
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Achievements',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             '${bottomNavigationController.astrologerbyId[0].courseBadges?.length ?? 0} badges earned',
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.9),
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: Container(
//                         padding: EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.close_rounded,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               // Badges List
//               Flexible(
//                 child: Container(
//                   margin: EdgeInsets.all(16),
//                   padding: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: buildBadgesList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
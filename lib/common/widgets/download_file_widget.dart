// import 'dart:io';

// import 'package:micro_teaching_studio/app/app_functions.dart';
// import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
// import 'package:micro_teaching_studio/common/resources/color_manager.dart';
// import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
// import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
// import 'package:dio/dio.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';

// class DownloadFileWidget extends StatefulWidget {
//   final String fileName;
//   final String url;
//   const DownloadFileWidget({super.key, this.fileName = '', required this.url});

//   @override
//   State<DownloadFileWidget> createState() => _DownloadFileWidgetState();
// }

// class _DownloadFileWidgetState extends State<DownloadFileWidget> {
//   bool _isDownloading = false;
//   String _percent = "0";

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 5.h),
//       color: ColorManager.white,
//       child: Row(
//         children: [
//           SvgPicture.asset(
//             IconAssets.file,
//             height: 18.h,
//             width: 18.w,
//           ),
//           SizedBox(
//             width: 10.w,
//           ),
//           Expanded(
//               child: Text(
//             widget.fileName,
//             style: getSemiBoldStyle(
//                 fontSize: 13.sp, color: ColorManager.textColor, height: 2.h),
//             overflow: TextOverflow.ellipsis,
//             maxLines: 1,
//           )),
//           SizedBox(
//             width: 10.w,
//           ),
//           !_isDownloading
//               ? TextButton(
//                   style: TextButton.styleFrom(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.h),
//                       minimumSize: const Size(0, 0),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(5.r))),
//                   onPressed: () async {
//                     setState(() {
//                       _isDownloading = true;
//                     });
//                     await _downloadFile(widget.url, widget.fileName);
//                   },
//                   child: Text(
//                     AppStrings.download.tr(),
//                     style: getBoldStyle(
//                         fontSize: 13.sp,
//                         color: ColorManager.primary,
//                         height: 1.5.h),
//                   ))
//               : Center(
//                   child: Container(
//                     height: 40.w,
//                     width: 40.w,
//                     margin: EdgeInsets.only(right: 10.w, top: 5.h, bottom: 5.h),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: ColorManager.black)),
//                     child: Text(
//                       '$_percent %',
//                       style: const TextStyle(
//                           color: ColorManager.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 10),
//                     ),
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }

//   Future<void> _downloadFile(String url, String fileName) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = '${directory.path}/$fileName}';

//     Dio dio = Dio();

//     try {
//       await dio.download(url, filePath, onReceiveProgress: (received, total) {
//         double percentage = received / total * 100;
//         setState(() {
//           _percent = "${percentage.floor()}";
//         });
//       });
//       File downloadedFile = File(filePath);
//       setState(() {
//         _isDownloading = false;
//         _percent = '0';
//       });
//       _openDownloadedFile(downloadedFile);
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isDownloading = false;
//           _percent = '0';
//         });
//         AppFunctions.showsToast(
//             AppStrings.downloadFailed.tr(), ColorManager.red, context);
//       }
//     }
//   }

//   void _openDownloadedFile(File file) {
//     OpenFilex.open(file.path);
//   }
// }

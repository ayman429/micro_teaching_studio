// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:micro_teaching_studio/common/extensions/context_extension.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../common/resources/app_router.dart';
import '../../common/widgets/default_button_widget.dart';
import '../../images_urls/assets.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> onBoardingData = [
    {
      "title": AppStrings.onBoardingTitle1,
      "description": AppStrings.onBoardingBody1,
      "image": Assets.assetsImagesOnBoard1,
    },
    {
      "title": AppStrings.onBoardingTitle2,
      "description": AppStrings.onBoardingBody2,
      "image": Assets.assetsImagesOnBoard2,
    },
    {
      "title": AppStrings.onBoardingTitle3,
      "description": AppStrings.onBoardingBody3,
      "image": Assets.assetsImagesOnBoard3,
    },
    {
      "title": AppStrings.onBoardingTitle4,
      "description": AppStrings.onBoardingBody4,
      "image": Assets.assetsImagesOnBoard4,
    },
  ];

  Future<void> _completeOnboarding(BuildContext context) async {
    // CacheManager.setBool(true);

    context.go(AppRouters.loginView);
// context.go(AppRouters.bottomNavBarView);
    log("done.........!");
  }

  void _nextPage() async {
    if (_currentPage < onBoardingData.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      // Navigate to Home or Login Page
      // GoRouter.of(context).pushReplacement(AppRouter.onBoardingGuestMode);
      _completeOnboarding(context);
      // log("${await CacheManager.getBool()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: context.screenHeight * 0.7,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: onBoardingData.length,
                  itemBuilder: (context, index) => Column(
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.topEnd,
                        children: [
                          SizedBox(
                            height: context.screenHeight * 0.5,
                            width: double.infinity,
                            child: Image.asset(
                              onBoardingData[index]["image"]!,
                              fit: BoxFit.fill,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _completeOnboarding(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 30.h),
                              child: Text(
                                "skip".tr(),
                                style: getBoldStyle(
                                  fontSize: 16.sp,
                                  color: ColorManager.greyColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.screenHeight * 0.03),
                      Text(
                        onBoardingData[index]["title"]!.tr(),
                        style: getBoldStyle(
                          fontSize: 26.sp,
                          color: ColorManager.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Text(
                          onBoardingData[index]["description"]!.tr(),
                          textAlign: TextAlign.center,
                          style: getRegularStyle(
                            fontSize: 16.sp,
                            color: ColorManager.greyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: context.screenHeight * 0.08,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 30, end: 30, top: 20.0),
                  child: DefaultButtonWidget(
                    text: "next".tr(),
                    radius: 10.r,
                    verticalPadding: 0.h,
                    color: ColorManager.primary,
                    textColor: ColorManager.white,
                    onPressed: _nextPage,
                  ),
                ),
              ),
              Gap(30.h),
              SmoothPageIndicator(
                controller: _pageController,
                count: onBoardingData.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: ColorManager.primary,
                  dotColor: ColorManager.grey6,
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
              Gap(30.h),
            ],
          ),
        ),
      ),
    );
  }
}

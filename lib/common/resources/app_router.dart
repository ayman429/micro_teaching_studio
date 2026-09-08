import 'package:micro_teaching_studio/features/auth/login_page.dart';
import 'package:micro_teaching_studio/features/auth/sign_in_page.dart';
import 'package:micro_teaching_studio/features/fluency/fluency_page.dart';
import 'package:micro_teaching_studio/features/home/home_page.dart';
import 'package:micro_teaching_studio/features/phonics/phonics_page.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_assessment_page.dart';
import 'package:micro_teaching_studio/features/splash/help_page.dart';
import 'package:micro_teaching_studio/features/splash/splash_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';

abstract class AppRouters {
  static const String root = '/';
  static const String bottomNavBarView = '/bottomNavBarView';

  static const String resetPassword = '/resetPassword';

  //********************** Reports ************************************
  // static const String reportsView = '/reportsView';
  // ********************* Classrooms *********************************
  static const String classroomsElectronicLibraryView =
      '/classroomsElectronicLibraryView';
  // ********************* Grades Electronic Library *********************************
  static const String gradesElectronicLibraryView =
      '/gradesElectronicLibraryView';
  // ********************* Study Materials Electronic Library *********************************
  static const String studyMaterialsElectronicLibraryView =
      '/studyMaterialsElectronicLibraryView';
  // ********************* MaterialElectronicLibraryView *********************************
  static const String materialElectronicLibraryView =
      '/materialElectronicLibraryView';
  // ********************* Curriculum *********************************
  static const String curriculumView = '/curriculumView';
  // ********************* Study Units ShowAll ************************
  static const String studyUnitsShowAll = '/studyUnitsShowAll';
  // ********************* Lessons ShowAll ************************
  static const String lessonsShowAll = '/lessonsShowAll';
  // ********************* Homework ShowAll ************************
  static const String homeworkShowAll = '/homeworkShowAll';
  // ********************* Offers ************************
  static const String offersView = '/offersView';
  // ********************* Daily Schedule **********************
  static const String dailyScheduleView = '/dailyScheduleView';
  // ********************* Academic Calendar ************************
  static const String academicCalendarView = '/academicCalendarView';
  // ********************* TestQuestionsView ****************************
  static const String testQuestionsView = '/testQuestionsView';
  // ********************* HomeworkQuestionsView ****************************
  static const String homeworkQuestionsView = '/homeworkQuestionsView';
  // ********************* EditProfile ****************************
  static const String editProfile = '/editProfile';
  // ********************* OnBoardingScreen ****************************
  static const String onBoardingScreen = '/onBoardingScreen';
  // ********************* LoginView ****************************
  static const String loginView = '/loginView';
  static const String signInView = '/signInView';
  static const String homeView = '/homeView';
  static const String helpView = '/helpView';
  static const String fluencyView = '/fluencyView';
  static const String phonicsView = '/phonicsView';

  // ********************* SignUpView ****************************
  static const String signUpView = '/signUpView';
  // ********************* ChooseUserTypeView ********************
  static const String chooseUserTypeView = '/chooseUserTypeView';
  // ********************* verifyOtpView ********************
  static const String verifyOtpView = '/verifyOtp';

  // ********************* ResetPasswordView ********************
  static const String resetPasswordView = '/resetPasswordView';
  // ********************* forgetPasswordView ********************
  static const String forgetPasswordView = '/forgetPasswordView';

  // ********************* ContactUs ********************
  static const String contactUs = '/contactUs';
  //********************* WorkSheetsView ****************************
  static const String workSheetsView = '/workSheetsView';
  //********************* userHomeReportsView ***********************
  static const String userHomeReportsView = '/userHomeReportsView';
  //********************* monthlyReportView ***********************
  static const String monthlyReportView = '/monthlyReportView';
  //********************* questionBankView ***********************
  static const String questionBankView = '/questionBankView';
  //********************* TestsView ***********************
  static const String testsView = '/testsView';
  //********************* showPdf *************************
  static const String showPdf = '/showPdf';
  //******************* AddReportView *******************
  static const String addReportView = '/addReportView';
  //******************* reportTypesView *******************
  static const String reportTypesView = '/reportTypesView';

  //******************* calculatorView ********************
  static const String calculatorView = '/calculatorView';
  //******************* reportTypesPdfView ****************
  static const String reportTypesPdfView = '/reportTypesPdfView';
  //****************** TalentedElectronicLibraryView *****************
  static const String talentedElectronicLibraryView =
      '/talentedElectronicLibraryView';
  //***********CompetitionsView********************* */
  static const String competitionsView = '/competitionsView';
  //************ talentedCurriculumView ***************/
  static const String talentedCurriculumView = '/talentedCurriculumView';
  //************* notificationView **********************/
  static const String notificationView = '/notificationView';
  // ************* childrenView **********************/
  static const String childrenView = '/childrenView';
  // ************* faqsView **********************/
  static const String faqsView = '/faqsView';
  //************** PrivacyPolicyView ***************/
  static const String privacyPolicyView = '/privacyPolicyView';
  //************** Pronunciation Assessment ***************/
  static const String pronunciationAssessmentView =
      '/pronunciationAssessmentView';

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRouters.root,
    routes: [
     
      GoRoute(
        path: root,
        pageBuilder: (context, state) {
          return const CupertinoPage(child: SplashView());
        },
      ),
     
    
      //Calculator
      
      //ReportTypesPdfView
      
      GoRoute(
        path: loginView,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: LoginView(),
          );
        },
      ),
      GoRoute(
        path: signInView,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: SignInView(),
          );
        },
      ),
      GoRoute(
        path: helpView,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: HelpView(),
          );
        },
      ),
      GoRoute(
        path: homeView,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: HomeView(),
          );
        },
      ),
      GoRoute(
        path: fluencyView,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: FluencyView(),
          );
        },
      ),
      GoRoute(
        path: phonicsView,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: PhonicsView(),
          );
        },
      ),
      GoRoute(
        path: pronunciationAssessmentView,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: PronunciationAssessmentView(),
          );
        },
      ),
    ],
  );
}

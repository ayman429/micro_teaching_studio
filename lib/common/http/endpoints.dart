abstract interface class Endpoints {
  // static const String baseUrl = "****************************";
  static const String login = '/auth/login';
  static const String signup = '/register';
  static const String verifyOTP = '/auth/otp/verify';
  // static const String countriesCities = '/country';
  static const String forgetPassword = '/auth/otp/send';
  static const String changePassword = '/change_password';
  static const String sendOTP = '/send_otp';
  static const String confirmOTP = '/confirmation-otp';
  static const String resetPassword = '/auth/password/rest';
  static const String verifyAccount = '/verify_account';
  static const String logout = '/auth/logout';
  static const String resendOTP = '/auth/otp/send';
  static const String verifyOTPForgetPassword = '/confirmation-otp';
  static const String resendOTPForgetPassword = '/forgot/resend-otp';
  // static const String privacyPolicy = '/privacy';
  // static const String about = '/about-us';
  // static const String terms = '/terms';
  static const String tradesmanCategory = '/get_categories';
  static const String getProfile = '/profile';
  static const String getContactUs = '/settings';
  // -----------------
  static const String getGovernments = "/client_governments";
  static const String getCities = "/client_government_cities/";

  static const String getDistricts = "/client_city_districts/";

  static const String complateSignup = '/users/update_regist_data';

  // *------------------ my_orders --------------------*
  static const String myOrders = "/orders/my_orders";
  static const String tradesmanOrders = "/orders/client_orders";
  // *------------------ start_order --------------------*
  static const String startOrder = "/orders/start_order";
  static const String startOrderTradsman = "/orders/tradesman/start_order";

  // *------------------ order_details --------------------*
  static const String orderDetails = "/orders/order_details/";
  static const String getShop = '/shops/get_shops';
  static const String getShopDetails = '/shops/shop_details/';
  // *----------------- tradesman_shop_category --------------------*
  static const String tradesmanShopCategory = '/get_pag_categories';
  //*----------------- crews --------------------*
  static const String crews = "/client_crews";
  //*----------------- makeOrder --------------------*
  static const String makeOrder = "/orders/make_order";
  //*----------------- addRateComment --------------------*
  static const String addRateComment = "/shops/make_rate";
  //*----------------- mapsKey --------------------*
  // static String mapsKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  //*----------------- tradesmanOffers --------------------*
  static const String tradesmanOffers = '/orders/offer_order/';
  //*----------------- freeEngineeringSupervision --------------------*
  static const String freeEngineeringSupervision = '/orders/free_order';
  //*----------------- tradesmanMakeOffersOrders ---------------------*
  static const String tradesmanMakeOffersOrders = '/orders/offer_order';
  //*----------------- AddShopTradesmanImageGallery ---------------------*
  static const String addShopTradesmanImageGallery = '/users/add_image';
  //*----------------- AddShopTradesmanImageGallery ---------------------*
  static const String updateProfile = '/profile/update';
  //*----------------- deleteAccount --------------------*
  static const String deleteAccount = '/delete/account';
  //----------notification----------------
  static const String getNotifications = '/notifications';
  static const String getStatistics = '/user_actions/stats/';
  static const String clickCounterFacebook = '/user_actions/facebook/';
  static const String clickCounterProfile = '/user_actions/profile/';
  static const String clickCounterWhatsApp = '/user_actions/whatsapp/';
  static const String clickCounterWebsite = '/user_actions/website/';
  //-----createPayment
  static const String createPayment = '/payment/store';
  //---getWallet
  static const String getWallet = '/payment';

  static const String getBanners = "/banners";
  //----endOrder
  static const String endOrder = '/orders/finish_order';
  static const String endOrderTradsman = '/orders/tradesman/finish_order/';
  //----getAds
  static const String getAds = '/advertisement/';
  //----getMyMessages
  static const String getGetMyMessagess = '/chat/messages';
  // createConversation
  static const String createConversation = '/chat/conversation';
  //sendMessage
  static const String sendMessage = '/chat/send';
  // getGetAllConversations
  static const String getGetAllConversations = '/chat/conversations';
  //******************************* */
  static const String stage = '/stages';
  static const String classroom = '/stage_classes/';
  static const String classmate = '/class_classmates/';
  //************************************** */
  static const String classrooms = '/stages';
  static const String studyMaterials = '/library/level/';
  static const String grades = '/semesters';
  static const String material = '/';
  //************************************** */
  static const String studyUnits = '/library/curriculum/';
  static const String lessons = '/library/curriculum/';
  static const String homework = '/library/curriculum/homeworks';
  static const String offers = '/library/presentations';
  //************************************** */
  static const String userHomeReports = '/';
  static const String monthlyReport = '/';
  static const String allTests = '/exam';
  static const String workSheets = '/library/work-sheets';
  static const String questionBank = '/library/curriculum/question-bank';

  //************************************** */
  static const String userHomeReportsTabsList = '/';
  static const String monthlyReportTabsList = '/';
  static const String testsTabsList = '/';
  static const String workSheetsTabsList = '/';
  static const String questionBankTabsList = '/';
  //*************************************** */
  static const String teatcherChat = '/users';
  //*************************************** */
  static const String notification = '/notifications';
  //*************************************** */
  static const String getClassSchedule = "/schedule";
  //*************************************** */
  static const String getTestQuestions = "/exam/questions/";
  static const String submitQuestionsTest = "/exam/submit";
  static const String testsReportTabsList = "/exam/types";
  //**************************************** */
  // static const String stage = "";
  static const String reportType = "/reportTypes";
  static const String reportTypeDataPdf = "/reports";

  // static const String level = "";
  static const String classNumber = "/classes";
  static const String users = "/users";
  //submitReport
  static const String submitReport = "/reports";

  //academicCalendar
  static const String academicCalendar = "/calendar/month";
  //getCompetitions
  static const String getCompetitions = "/talented/competitions";

  //talentedMaterials
  static const String talentedMaterials = "/library/talent/curriculums";
  //children
  static const String children = "/users/children";
  //Calculator
  static const String calculator = "/parent/installments";
  //months
  static const String months = "/month";
  //getSettings
  static const String getSettings = "/settings";
  //faqs
  static const String faqs = "/faq";
  //privacyPolicy
  static const String privacyPolicy = "/terms";

  ///about-us
  static const String about = "/about-us";
}

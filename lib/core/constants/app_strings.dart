class AppStrings {
  // --- Common ---
  static const String appName = 'كيمو كلين';
  static const String requiredValidation = 'مطلوب';
  static const String unexpectedError = 'حدث خطأ غير متوقع';
  static const String unknown = 'غير معروف';
  static const String undefined = 'غير محدد';
  static const String pieces = 'قطع';
  static const String pageNotFound = 'الصفحة غير موجودة';

  // Repositories & Services Exceptions
  static const String errorCarNotRegistered = 'رقم السيارة غير مسجل في النظام';
  static const String errorInvalidPassword = 'كلمة المرور غير صحيحة';
  static const String errorCarInactive = 'تم إيقاف هذه السيارة من قبل الإدارة';
  static const String errorNetworkFailed =
      'فشل الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى';
  static const String errorPermissionDenied =
      'ليس لديك صلاحية الوصول. تحقق من إعدادات قاعدة البيانات';
  static const String errorFetchingCustomerData = 'فشل في جلب بيانات العميل';
  static const String errorSavingOrder = 'فشل حفظ الأوردر';
  static const String errorCheckingCustomer = 'فشل في التحقق من بيانات العميل';
  static const String errorCheckingCar = 'فشل في التحقق من حالة السيارة';
  static const String errorPermissionDeniedOrder =
      'ليس لديك صلاحية لإنشاء الطلب. تواصل مع المسؤول';
  static const String errorServerUnavailable =
      'الخادم غير متاح حالياً. تحقق من اتصالك بالإنترنت وحاول مرة أخرى';
  static const String errorDatabaseConfig =
      'خطأ في إعداد قاعدة البيانات (مستند العداد غير موجود). تواصل مع المسؤول';
  static const String errorConflictSaving =
      'تعارض أثناء حفظ الطلب. حاول مرة أخرى';
  static const String errorFailedToSaveOrderPrefix = 'فشل حفظ الطلب:';
  static const String errorUnexpectedSaving =
      'حدث خطأ غير متوقع أثناء حفظ الطلب';

  // WhatsApp Strings
  static const String whatsappMessageHeader = '🧺 *أوردر جديد من كيمو كلين*';
  static const String whatsappMessageSeparator = '---------------------------';
  static const String whatsappOrderNumberPrefix = '🔢 *رقم الأوردر:* #';
  static const String whatsappCustomerPrefix = '👤 *العميل:* ';
  static const String whatsappPhonePrefix = '📞 *التليفون:* ';
  static const String whatsappAddressPrefix = '📍 *العنوان:* ';
  static const String whatsappItemsHeader = '📝 *الأصناف:*';
  static const String whatsappTotalPiecesPrefix = '🔢 *إجمالي القطع:* ';
  static const String whatsappNotesPrefix = '📒 *ملاحظات:* ';
  static const String whatsappErrorLaunch =
      'تعذر فتح واتساب — تأكد إن واتساب مثبت على الجهاز';

  // --- Auth & Login ---
  static const String accountDeactivated = 'تم إيقاف الحساب من قبل الإدارة';
  static const String loginWelcomeSubtitle = 'أهلاً بك، سجل دخولك للمتابعة';
  static const String agentNameLabel = 'اسم المندوب';
  static const String agentNameValidation = 'من فضلك أدخل اسم المندوب';
  static const String carNumberLabel = 'رقم السيارة';
  static const String carNumberValidation = 'من فضلك أدخل رقم السيارة';
  static const String passwordLabel = 'كلمة المرور';
  static const String passwordValidation = 'من فضلك أدخل كلمة المرور';
  static const String loginButton = 'تسجيل الدخول';

  // --- Home ---
  static const String homeTitle = 'الرئيسية';
  static const String drawerNewOrder = 'أوردر جديد';
  static const String drawerDailyOrders = 'الطلب اليومي';
  static const String drawerLogout = 'تسجيل الخروج';
  static const String carPrefix = 'سيارة:';

  // --- Orders ---
  static const String newOrderTitle = 'تسجيل أوردر جديد';
  static const String itemsDetailsTitle = 'تفاصيل الأصناف';
  static const String totalPiecesPrefix = 'إجمالي القطع:';
  static const String customerDataFetchedSuccess = 'تم جلب بيانات العميل بنجاح';
  static const String saveAndSendSuccessPrefix = 'تم الحفظ والإرسال بنجاح (رقم';
  static const String notesOptionalLabel = 'ملاحظات (اختياري)';
  static const String phoneLabel = 'رقم الهاتف';
  static const String phoneLengthValidation = 'رقم الهاتف يجب أن يكون 11 رقم';
  static const String customerNameLabel = 'اسم العميل';
  static const String addressLabel = 'العنوان';
  static const String savingInProgress = 'جاري الحفظ...';
  static const String saveAndSendToWhatsapp = 'حفظ وإرسال للواتساب';
  static const String atLeastOneCategoryValidation =
      'برجاء اختيار صنف واحد على الأقل';
  static const String orderDetailsTitle = 'تفاصيل الطلب';
  static const String orderNumberPrefix = 'رقم الطلب:';

  // --- Order Categories ---
  static const String categoryCarpet = 'سجاد';
  static const String categoryCarpetCover = 'حافظة سجاد';
  static const String categoryDuvet = 'لحاف';
  static const String categoryBlanket = 'بطانية';
  static const String categoryCurtains = 'ستائر';
  static const String categoryOther = 'اصناف اخري';

  // --- History / Daily Archive ---
  static const String dailyArchiveTitle = 'أرشيف اليوم';
  static const String statusReceived = 'تم الاستلام';
  static const String noOrdersYet = 'لا توجد أوردرات حتى الآن';
  static const String totalOrdersTodayPrefix = 'إجمالي الأوردرات اليوم:';
  static const String totalPiecesReceivedPrefix = 'إجمالي القطع المستلمة:';
  static const String todayPrefix = 'اليوم -';
  static const String ordersLabel = 'اوردرات';
  static const String failedToLoadOrdersDb =
      'فشل في تحميل الطلبات من قاعدة البيانات';
  static const String unexpectedErrorLoadingOrders =
      'حدث خطأ غير متوقع أثناء تحميل الطلبات';
  static const String carNumberNotDefined = 'لم يتم تحديد رقم السيارة';
  static const String dateNotDefined = 'التاريخ غير محدد';
  static const String cannotLoadOrdersNowTryAgain =
      'تعذر تحميل الطلبات حالياً، حاول مرة أخرى';
}

# دليل تنفيذ شاشات Figma إلى Flutter

دليل إلزامي لأي شاشة تُنقل من Figma إلى هذا المشروع. لا يُكتب كود شاشة قبل تطبيق الخطوات أدناه.

الهدف: تنفيذ مطابق للتصميم مع كلين كود، بدون هارد كود، بدون تكرار، بدون تداخل طبقات، مع وضع الألوان والخطوط والأيقونات والصور والنصوص في أماكنها الصحيحة.

---

## 1. مبدأ التشغيل

الترتيب ثابت ولا يُعكس:

1. قراءة عقدة Figma الحقيقية (شاشة التطبيق فقط).
2. مطابقة الموجود في المشروع (ألوان، خطوط، ويدجتس، أصول، مفاتيح ترجمة).
3. إضافة الناقص في طبقته الصحيحة أولاً.
4. بناء الشاشة بالتركيب من المكوّنات والأسماء المركزية.

ممنوع البدء برسم الشاشة ثم «ترتيب» الألوان والأصول لاحقاً.

---

## 2. خريطة المجلدات

| النوع | المكان الوحيد |
| --- | --- |
| شاشة / feature | `lib/features/<feature_name>/` |
| ويدجت خاص بشاشة واحدة | `lib/features/<feature_name>/widgets/` |
| ويدجت يُستخدم في أكثر من شاشة | `lib/common/widgets/` |
| ألوان | `lib/common/resources/color_manager.dart` |
| اسم الخط وأوزانه | `lib/common/resources/font_manager.dart` + تسجيل في `pubspec.yaml` |
| أنماط النص | `lib/common/resources/styles_manager.dart` |
| مسافات / زوايا / أحجام ثابتة | `lib/common/resources/values_manager.dart` |
| ثيم عام | `lib/common/resources/theme_manager.dart` |
| مفاتيح النصوص | `lib/common/resources/strings_manager.dart` |
| ترجمات | `assets/translations/ar.json` و `assets/translations/en.json` |
| صور | `assets/images/` ثم التوليد إلى `lib/images_urls/assets.dart` |
| أيقونات | `assets/icons/` ثم نفس التوليد |
| مسارات التنقل | `lib/common/resources/app_router.dart` |
| حقن الاعتماديات | `lib/app/di.dart` عبر `GetIt` |
| ثوابت التطبيق غير البصرية | `lib/app/app_constants.dart` |
| حالة الشاشة (Cubit/Bloc) | `lib/features/<feature_name>/cubit/` |

قواعد الحدود:

- ملف الشاشة لا يحتوي Hex ولا نصاً خامًا ولا مسار أصل.
- الويدجت البصري لا يستدعي Dio ولا يعرف التوكن ولا يفتح الراوت مباشرة إلا عبر callback أو `context` في أزرار التنقل المعرفة مسبقاً.
- الـ Cubit لا يبني ويدجتس.
- الأصل العام لا يُخزَّن داخل مجلد الـ feature.

---

## 3. قواعد الكلين كود

- الشاشة = تركيب (composition) فقط: صفّ الويدجتس وامرّر البيانات والـ callbacks.
- الويدجت المشترك: `StatelessWidget` ما لم توجد حاجة حقيقية لحالة داخلية بصرية.
- إن تكرر بلوك مرتين (صف معلومات، شارة Voice، مؤشر خطوات، زر Skip) يُستخرج ويدجت فوراً. لا يُنسخ.
- لا ملف واحد يخلط UI + شبكة + تسجيل صوت + تحويل بيانات. افصل الملف حسب المسؤولية.
- التسمية على نمط المشروع: `opening_page.dart` مع `OpeningView` إن وُجد نمط `*View` في الراوتر.
- لا `BuildContext` خارج طبقة الـ UI.
- لا تعليقات تشرح الكود الواضح. التعليق فقط لقرار تصميم غير ظاهر من الكود.
- لا توسّع `DefaultButtonWidget` أو أي ويدجت عام بمعاملات تخص شاشة واحدة. أنشئ ويدجتاً للشاشة أو غلافاً رفيعاً.
- قبل إنشاء ويدجت جديد: ابحث في `lib/common/widgets/` (`DefaultButtonWidget`, `DefaultAppBar`, `CustomAppBar`, `DefaultImageWidget`, `arrow_icon`, …). وسّع الموجود إن كان الدور نفسه؛ لا تضف بديلاً رابعاً لنفس الوظيفة.

---

## 4. ممنوع الهارد كود

غير مسموح داخل ملفات الـ feature أو الويدجتس الجديدة:

```dart
Color(0xff1E3A8A)
Colors.blue
Colors.white          // استخدم ColorManager.white
'SKIP'
'الافتتاحية'
'assets/icons/close.svg'
fontSize: 28          // بدون .sp وبدون style مركزي
BorderRadius.circular(16)  // مكرر بدون ثابت
width: 44             // بدون .w / .r
```

المسموح فقط:

```dart
ColorManager.navy
AppStrings.openingTitle.tr()
Assets.assetsIconsClose
getBoldStyle(fontSize: FontSize.s28, color: ColorManager.white)
BorderRadius.circular(AppRadius.r16)
EdgeInsets.symmetric(horizontal: AppPadding.p24)
```

قائمة تحقق سريعة قبل الحفظ:

- لا `Color(0x` في ملفات الشاشة.
- لا نص عربي أو إنجليزي ظاهر للمستخدم بدون `.tr()`.
- لا مسار `assets/...` مكتوب يدوياً داخل الويدجت؛ استخدم `Assets` أو `ImageAssets` / `IconAssets` حسب المسار المعتمد أدناه.
- لا رقم سحري لمعنى منتج (عدد خطوات الكورس، كود صوت) خارج ثابت مسمّى.

---

## 5. مسار الأصول المعتمد

المشروع فيه مصدران للأصول (`IconAssets` في `assets_manager.dart` و`Assets` المولَّد). للشاشات الجديدة المسار الوحيد هو:

1. ضع الملف في `assets/images/` أو `assets/icons/`.
2. تأكد أن المجلد مسجّل تحت `flutter: assets:` في `pubspec.yaml` (المجلدات الحالية مسجّلة).
3. أعد توليد `lib/images_urls/assets.dart` عبر إعداد `flutter_assets` الموجود في `pubspec.yaml`.
4. استخدم الثابت من `Assets` فقط.

لا تضف ثوابت جديدة إلى `IconAssets` إلا لصيانة كود قديم. لا تكرر نفس الأصل في الملفين.

تسمية الملفات: `snake_case`، إنجليزية، وصفية (`close.svg`, `graduation_cap.svg`, `skip_forward.svg`). لا تترك أسماء Figma العشوائية.

---

## 6. الألوان

الملف الوحيد: `lib/common/resources/color_manager.dart`.

عند استخراج لون من Figma:

1. ابحث إن وُجد مطابق أو قريب بصرياً في `ColorManager` (`primary`, `splashPrimary`, `yellow`, `textColor`, …).
2. إن كان الفرق غير ملحوظ على الجهاز: أعد استخدام الموجود. لا تنشئ `navy2` لنفس القيمة.
3. إن كان لوناً جديداً حقيقياً: أضفه باسم دلالي (`navy`, `indigo`, `infoBlue`, `surfaceMuted`) وليس `color1` أو `figmaBlue`.
4. التدرجات: قائمة ثابتة في `ColorManager` على نمط `gradientPrimary` الموجود، لا تُكتب داخل `BoxDecoration` كـ Hex.

أمثلة أسماء مقبولة لألوان كورس Micro-Teaching إن لزم إضافتها:

- `navy` / `indigo` للخلفية
- `actionBlue` لزر Help
- `accentAmber` لكلمة التمييز في العنوان
- `onNavyMuted` للنص الوصفي الفاتح
- `successMint` لشارة الجودة

لا تخلط ألوان الثيم العام (`primary` الذهبي) مع ألوان شاشة الكورس دون سبب. إن كانت الشاشة نظاماً بصرياً فرعياً، سمّ ألوانه بوضوح واستخدمها عبر `ColorManager` فقط.

---

## 7. الخطوط

الوضع الحالي في المشروع غير متسق ويجب تصحيحه عند أول شاشة تحتاج خطاً:

- `pubspec.yaml` يعرّف عائلة **Tajawal**.
- `FontConstants.fontFamily` مضبوط على **Rubik** وهو غير مسجّل.
- ملفات Tajawal المشار إليها في `pubspec` يجب أن تكون موجودة فعلياً تحت `assets/fonts/`.

القرار المعتمد لهذا المشروع:

- خط التطبيق: **Tajawal** (يدعم العربية والإنجليزية).
- `FontConstants.fontFamily` يجب أن يساوي الاسم المسجّل في `pubspec.yaml` حرفياً (`Tajawal`).
- الأوزان تُؤخذ من `FontWeightManager` (`light`, `regular`, `medium`, `semiBold`, `bold`).
- أنماط النص تُنشأ عبر `getLightStyle` / `getRegularStyle` / `getMediumStyle` / `getSemiBoldStyle` / `getBoldStyle` مع `fontSize` بوحدة `.sp`.

عند نقص وزن يحتاجه التصميم (مثلاً ExtraBold / Black مقابل Inter في Figma):

1. حمّل ملف `.ttf` الرسمي إلى `assets/fonts/`.
2. سجّله تحت عائلة `Tajawal` في `pubspec.yaml` مع `weight` الصحيح.
3. إن لزم وزن غير موجود في `FontWeightManager` أضفه هناك أولاً.
4. لا تضف عائلة Inter إلا بقرار صريح مكتوب في هذا الدليل لاحقاً.

`ThemeManager.getTheme()` يستخدم `FontConstants.fontFamily`. أي إصلاح للخط يمر من هنا حتى لا تُحدَّد العائلة داخل الشاشات.

---

## 8. القيم (مسافات، زوايا، أحجام)

المشروع لا يحتوي `values_manager.dart` حتى الآن. قبل تنفيذ أول شاشة Figma أنشئ:

`lib/common/resources/values_manager.dart`

ويضم ثوابت دلالية فقط، مثل:

- `AppPadding` (`p8`, `p12`, `p16`, `p24`, …)
- `AppRadius` (`r8`, `r16`, `r28`, `rCapsule`)
- `AppSize` (ارتفاعات أزرار، أشرطة علوية/سفلية، أحجام أيقونات)
- `FontSize` (`s9`, `s10`, `s11`, `s12`, `s13`, `s28`, …) إن لم تُمرَّر مباشرة عبر `.sp` من الدوال الموجودة

لا تضع في هذا الملف قيماً تخص شاشة واحدة باسم عام. قيمة تخص شاشة واحدة تُعرَّف كثابت خاص في مجلد الـ feature (`opening_metrics.dart`) فقط إذا لن تُعاد استخدامها.

القياس دائماً عبر `flutter_screenutil`: `.w` `.h` `.r` `.sp`.  
مرجع التصميم للجوال: المحتوى الداخلي للشاشة (حوالي 370×780 في نموذج Opening)، وليس إطار الجهاز ولا Dynamic Island.

`ScreenUtilInit` موجود في `lib/app/app.dart`. لا تُكتب أحجام مطلقة (`44.0`) في الشاشات الجديدة.

---

## 9. النصوص والترجمة

كل نص يظهر للمستخدم:

1. مفتاح في `AppStrings`.
2. القيمة الإنجليزية في `assets/translations/en.json`.
3. القيمة العربية في `assets/translations/ar.json`.
4. الاستخدام: `AppStrings.someKey.tr()`.

ممنوع إضافة المفتاح في ملف واحد فقط. الثلاثية إلزامية في نفس التغيير.

للصفوف ثنائية اللغة في التصميم (`Name / الاسم`) إمّا:

- مفتاح واحد يحتوي الصيغتين إن كان التصميم يثبت النص هكذا، أو
- مفتاحان (`nameLabel`, `nameLabelAr`) إن كان الاتجاه RTL سيغيّر الترتيب.

اختبر الشاشة بـ `ar` و`en`. إن انعكس صف label/value استخدم اتجاه السياق (`context.locale`) لا تخمينات `textDirection` داخل كل نص.

---

## 10. الأيقونات والصور من Figma

### أيقونات

- صدّر الأصل من Figma كـ SVG (مفضّل) أو PNG إن لم يتوفر فيكتور.
- لا ترسم `CustomPainter` / `Path` بديلاً عن أصل Figma.
- لا تستخدم `Icons.material` إذا التصميم يفرض رسماً محدداً.
- أعد الاستخدام فقط إذا الرسم مطابق فعلاً (الاسم وحده لا يكفي: `close` الموجود قد لا يطابق X الدائري في التصميم).
- الحجم: حاوية مربعة صريحة + الأصل يملأها. لا تترك العرض `auto` فيضيع الحجم.

### صور

- الأصول الثابتة: `assets/images/` + `Assets`.
- الصور الشبكية: `DefaultImageWidget` فقط (هو مسار الـ cache في المشروع).
- لا تضع صوراً داخل `lib/`.

روابط تصدير Figma MCP قصيرة العمر (حوالي 7 أيام). للتنفيذ النهائي: حمّل البايتات إلى `assets/` والتزم بالمسار المحلي. لا تعتمد على رابط Figma في الإنتاج.

بعد أي إضافة أصول أعد توليد `Assets` ثم استخدم الثابت الجديد.

---

## 11. خطوات تنفيذ أي شاشة Figma

نفّذ بالترتيب:

### أ. قراءة التصميم

- استخرج `fileKey` و`nodeId` من الرابط (`node-id=162-301` → `162:301`).
- تجاهل كروم التحويل: Meta AI، html.to.design، شريط المتصفح، إطار الآيفون، Dynamic Island، عارض التبويبات الخارجي للبروتوتايب.
- نفّذ فقط واجهة التطبيق الداخلية.
- سجّل: الألوان، الخطوط، الأيقونات، الصور، النصوص EN/AR، المسافات، الزوايا، الحالات (active / disabled / loading).

### ب. جدول المطابقة

قبل الكود املأ ذهنياً أو في المراجعة:

| عنصر Figma | موجود في المشروع؟ | الإجراء |
| --- | --- | --- |
| لون | `ColorManager` | استخدام أو إضافة اسم دلالي |
| أيقونة | `assets/icons` + `Assets` | استخدام أو تصدير ثم توليد |
| صورة | `assets/images` + `Assets` | استخدام أو إضافة |
| نص | `AppStrings` + json | استخدام أو إضافة الثلاثية |
| بلوك UI | `common/widgets` أو feature widgets | إعادة استخدام أو استخراج |
| خط / وزن | `font_manager` + `pubspec` | إصلاح/تحميل الناقص أولاً |

### ج. الهيكل

أنشئ الـ feature إن لم يوجد:

```text
lib/features/<feature_name>/
  <feature_name>_page.dart
  widgets/
  cubit/          # فقط عند وجود حالة حقيقية
```

إن تكرر شريط مشترك بين إطارات كورس (شارة Voice، عنوان ثنائي اللغة، Skip، مؤشر خطوات) ارفعه إلى `lib/common/widgets/` أو `lib/features/course_shell/` من أول تكرار ثانٍ. لا تنسخه 12 مرة.

### د. الراوت

- ثابت المسار في `AppRouters`.
- `GoRoute` بنفس نمط الصفحات الحالية (`CupertinoPage` + `*View` إن كان هذا نمط الشاشة).
- لا تُستدع الشاشة بـ `Navigator.push` المباشر في الكود الجديد.

### هـ. التنفيذ البصري

- استخدم `DefaultButtonWidget` للأزرار ما دام الشكل قابلاً للضبط ببارامتراته (`color`, `textColor`, `radius`, `isIcon`, `svgPath`).
- استخدم `CustomAppBar` / `DefaultAppBar` إن طابقا الشريط. إن كان شريط الدرس مختلفاً جذرياً: ويدجت جديد في الـ feature أو shell، لا تعدّل الـ AppBar العام حتى ينكسر باقي التطبيق.
- الظلال والتقويس من `values_manager` و`ColorManager`.
- Glassmorphism (`BackdropFilter`) فقط إذا تكرر في أكثر من بلوك وكان جزءاً أساسياً من التصميم، لا لزخرفة واحدة.

### و. إغلاق الشاشة

لا تُعتبر الشاشة منتهية وفيها Hex أو نص خام أو مسار أصل أو حجم مطلق.

---

## 12. ما لا يُنفَّذ من ملف Figma

- شريط Meta AI (إغلاق، Share، More، تحذير Unverified).
- هيدر عارض البروتوتايب (`Micro-Teaching Studio` + `Phone 4` + شريط 12 إطاراً الخارجي).
- إطار الجهاز الأسود وDynamic Island.
- شاشات دخيلة في نفس الملف (مثل FinishHub / Finish Haven).
- كود React + Tailwind المُولَّد من Figma: مرجع بصري فقط، يُترجم إلى Flutter ومكوّنات هذا المشروع.

---

## 13. الحالة والمنطق

- لا منطق شبكة داخل `build`.
- الـ API عبر `GenericDataSource` / `ApiConsumer` الموجودين، مع تسجيل في `di.dart` عند الحاجة.
- الحالة المشتركة: `flutter_bloc` + `BaseState` إن ناسب التدفق.
- التفضيلات: `AppPreferences` عبر `GetIt` (`instance<AppPreferences>()`).
- الأذونات والإضافات الخاصة تبقى في طبقة غير بصرية (خدمة أو Cubit) ثم تُعرض النتيجة في الشاشة.

---

## 14. قائمة فحص قبل الدمج

- [ ] لا `Color(0x` ولا `Colors.` غير مبرر في ملفات الـ feature الجديدة.
- [ ] كل نص مستخدم عبر `AppStrings.*.tr()` وموجود في `ar.json` و`en.json`.
- [ ] الألوان الجديدة في `ColorManager` بأسماء دلالية.
- [ ] الخط Tajawal مسجّل، الملفات موجودة، و`FontConstants` يطابقه.
- [ ] الأيقونات/الصور في `assets/` والثوابت في `Assets`.
- [ ] المسافات والزوايا من `values_manager` (أو ثوابت feature مسمّاة إن كانت خاصة).
- [ ] الأحجام عبر ScreenUtil.
- [ ] الراوت في `AppRouters`.
- [ ] لا تكرار لبلوك UI؛ المستخرج في `widgets/`.
- [ ] الشاشة تعمل بالعربية والإنجليزية دون كسر اتجاه.
- [ ] لا كروم Figma / إطار جهاز في الواجهة الحقيقية.
- [ ] لا أسرار أو مفاتيح API داخل الشاشة (عكس ما يحدث في صفحات قديمة؛ لا تُنسَخ هذه العادة).

---

## 15. ملخص سريع للتنفيذ

```text
Figma node حقيقي
  → تجاهل الكروم
  → طابق ColorManager / Assets / AppStrings / widgets
  → أضف الناقص في مكانه
  → ابنِ feature بالتركيب
  → سجّل الراوت
  → افحص قائمة القسم 14
```

أي انحراف عن هذا الدليل يُرفض في المراجعة حتى لو كانت الشاشة «شكلها صحيح».

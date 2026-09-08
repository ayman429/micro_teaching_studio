part of 'imports.dart';

final instance = GetIt.instance;

Future<void> initAppModule() async {
  instance.allowReassignment = true;

  // shared prefs
  final sharedPrefs = await SharedPreferences.getInstance();
  instance.registerFactory<SharedPreferences>(() => sharedPrefs);

  // app preferences
  instance.registerFactory<AppPreferences>(
      () => AppPreferences(instance<SharedPreferences>()));

  // network info
  instance.registerFactory<NetworkInfo>(() => NetworkInfoImpl());

  // dio
  instance.registerFactory<Dio>(() => Dio()
    ..options = BaseOptions(
      baseUrl: AppConstants.dioBaseUrl,
      receiveDataWhenStatusError: true,
      // connectTimeout: const Duration(seconds: 60),
      // receiveTimeout: const Duration(seconds: 60),
      // sendTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': instance<AppPreferences>().getAppLanguage(),
        'Authorization': "Bearer ${instance<AppPreferences>().getToken()}",
      },
    )
    ..interceptors.addAll([
      if (!kReleaseMode)
        PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseHeader: true,
            responseBody: true,
            error: true,
            compact: true,
            maxWidth: 90,
            enabled: true)
    ]));

  // api consumer
  instance.registerFactory<ApiConsumer>(() => BaseApiConsumer(dio: instance()));

  // data source
  instance
      .registerFactory<GenericDataSource>(() => GenericDataSource(instance()));

  instance.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  instance.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  instance.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      auth: instance<FirebaseAuth>(),
      firestore: instance<FirebaseFirestore>(),
    ),
  );
  instance.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      instance<AuthRemoteDataSource>(),
      instance<AppPreferences>(),
    ),
  );
  instance.registerLazySingleton<AuthCubit>(
    () => AuthCubit(instance<AuthRepository>()),
  );
  instance.registerLazySingleton<SpeechConfigRepository>(
    () => SpeechConfigRepository(instance<FirebaseFirestore>()),
  );
  instance.registerFactory<PronunciationEngine>(() => PronunciationEngine());
  instance.registerFactory<PronunciationCubit>(
    () => PronunciationCubit(
      instance<SpeechConfigRepository>(),
      instance<PronunciationEngine>(),
    ),
  );
}

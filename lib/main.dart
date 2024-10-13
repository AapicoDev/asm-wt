import 'package:asm_wt/app/tasks/task_manual/task_manual_controller.dart';
import 'package:asm_wt/app/tasks/today_task/today_task_controller.dart';
import 'package:asm_wt/service/RESTAPI/geofencing_service.dart';
import 'package:asm_wt/service/RESTAPI/task_management_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:asm_wt/app/app_controller.dart';
import 'package:asm_wt/app/app_service.dart';
import 'package:asm_wt/app/authentication/login/login_controller.dart';
import 'package:asm_wt/app/tasks/tasks_root_controller.dart';
import 'package:asm_wt/assets/app_them.dart';
import 'package:asm_wt/core/firebase/auth_service.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firebase_auth_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/core/life_cycle_event_handler.dart';
import 'package:asm_wt/core/local_notification.dart';
import 'package:asm_wt/core/translate_preference_controller.dart';
import 'package:asm_wt/router/router_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:asm_wt/service/base_service.dart';
// import 'package:asm_wt/service/base_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';

import 'dart:io' show Platform, exit;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final AuthService _authService = FirebaseAuthService();
late LocationSettings? locationSettings = null;
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
TodayTaskController _todayTaskController = TodayTaskController();

final FirestoreService _firestoreService = FirestoreServiceImpl();

@pragma('vm:entry-point')
Future<void> _firebasMessagingBackgroundHandler(RemoteMessage message) async {
  print("----message backgroud handling${message.messageId}");
}

Future<void> main() async {
  // late LocationSettings? locationSettings;
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  await FirebaseMessaging.instance.getInitialMessage();
  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider:
        kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    appleProvider:
        kReleaseMode ? AppleProvider.deviceCheck : AppleProvider.appAttest,
  );

  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  final getIt = GetIt.instance;
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // await [
  //   Permission.camera,
  // ].request();

  // if (await Permission.location.isPermanentlyDenied) {
  //   openAppSettings();
  // }

  // //backgroud service for location management;
  if (Platform.isAndroid) {
    locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        forceLocationManager: true,
        intervalDuration: const Duration(minutes: 15),
        //(Optional) Set foreground notification config to keep the app alive
        //when going to the background
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "WingSpan-WWT is accessing your location.",
          notificationTitle: "Background Access",
          enableWakeLock: true,
        ));
  } else if (Platform.isIOS || Platform.isMacOS) {
    FirebaseMessaging.instance.requestPermission();
    locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true);
  } else {
    locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
  }

  print("-----------main : ${sharedPreferences.getString("userId")}");
  if (sharedPreferences.getBool("tracking") ?? false) {
    print("----------------backgroud location tracking");
    var driverId = sharedPreferences.getString("userId");
    _todayTaskController.getLocationEnable();

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) async {
        print("-------====== $position");
        if (position == null) {
          print("-------====== not get position");
        } else {
          final Map<String, dynamic> location = <String, dynamic>{};
          GeoPoint geoPoint;

          // Workmanager().initialize(
          //     callbackDispatcher, // The top level function, aka callbackDispatcher
          //     isInDebugMode:
          //         false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
          //     );
          // Workmanager().registerOneOffTask("task-identifier", "simpleTask");
          print(
              "============== latitude : ${position.latitude}, longitude : ${position.longitude} ");
          geoPoint = GeoPoint(position.latitude, position.longitude);
          location['current_location'] = geoPoint;
          print('-------------$driverId');
          await _firestoreService.updateData(
              "${TableName.dbEmployeeTable}/$driverId", location);
        }
      },
      onError: (dynamic error) {
        // Handle error
      },
    );
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(240, 240, 240, 1)));

  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      preferences: TranslatePreferences(),
      supportedLocales: ['en', 'th'],
      basePath: 'lib/assets/i18n/');

  ///Set preferred orientation to portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    LocalizedApp(delegate, MyApp(sharedPreferences: sharedPreferences)),
    // LocalizedApp(delegate, const MyApp()),
  );
}

class MyApp extends AppStatefulWidgetMVC {
  final SharedPreferences sharedPreferences;

  const MyApp({
    Key? key,
    required this.sharedPreferences,
  }) : super(key: key);

  @override
  AppStateMVC createState() => _MyAppState();
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class _MyAppState extends AppStateMVC<MyApp> with TickerProviderStateMixin {
  static _MyAppState? _this;
  factory _MyAppState() => _this ??= _MyAppState._();
  late AppService appService;
  final AuthService _authService = FirebaseAuthService();
  late final FirebaseMessaging _messaging;
  User? user;

  final LocalAuthentication auth = LocalAuthentication();
  _SupportState supportState = _SupportState.unknown;
  bool canCheckBiometrics = false;
  List<BiometricType>? availableBiometrics;
  String authorized = 'Not Authorized';
  bool isAuthenticating = false;
  String? driverId;
  AnimationController? animationController;
  Animation<double>? animation;

  _MyAppState._()
      : super(
          controller: AppController(),
          controllers: [
            LoginController(),
            TasksRootController(),
          ],

          /// Demonstrate passing an 'object' down the Widget tree much like
          /// in the Scoped Model
          object: 'Hello!',
        );

  @override
  void initState() {
    super.initState();
    appService = AppService(widget.sharedPreferences);
    animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation =
        CurveTween(curve: Curves.fastOutSlowIn).animate(animationController!);

    registerNotification(); //initial permission and set notification state;
    // locationPermissionCheck(); //request permission for backgroup service location;

    auth.isDeviceSupported().then(
          (bool isSupported) => supportState =
              isSupported ? _SupportState.supported : _SupportState.unsupported,
        );

    // checkBiometrics();

    //check local user and set state for login status for redirecting auto signin;
    _authService.currentUser().then((userData) async => {
          if (userData?.uid != null)
            {
              driverId = widget.sharedPreferences.getString("userId"),
              print("--------------$driverId"),
              if (driverId != null)
                {
                  appService.loginState = true,
                  if (widget.sharedPreferences.getBool('bioScan') ?? false)
                    {
                      authenticateWithBiometrics(),
                    }
                  else
                    {appService.bioAuth = true}
                }
              // if (supportState == _SupportState.supported) {}
            }
          else
            {
              appService.loginState = false,
            }
        });

    // checkIfVehicleDidnotCheck();

    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      resumeCallBack: () {},
    ));
  }

  Future<void> checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      availableBiometrics = availableBiometrics;
    });
  }

  Future<void> authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      isAuthenticating = true;
      authorized = 'Authenticating';
      authenticated = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      isAuthenticating = false;
      authorized = 'Authenticating';
    } on PlatformException catch (e) {
      print(e);
      isAuthenticating = false;
      authorized = 'Error - ${e.message}';
      exit(0);
    }
    if (!mounted) {
      exit(0);
    }

    if (authenticated) {
      appService.bioAuth = true;
    } else {
      exit(0);
    }

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      authorized = message;
    });
  }

  Future<void> cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => isAuthenticating = false);
  }

  void registerNotification() async {
    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        LocalNotification.showNotification(message);
      });
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget buildChild(BuildContext context) {
    final Future<FirebaseApp> initializedApp = Firebase.initializeApp();

    var localizationDelegate = LocalizedApp.of(context).delegate;

    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppService>(create: (_) => appService),
          ChangeNotifierProvider(create: (_) => GeoFencingService()),
          ChangeNotifierProvider(create: (_) => TaskManagementService()),
          ChangeNotifierProvider(create: (_) => TaskManualProvider()),
          Provider<AppRouter>(create: (_) => AppRouter(appService)),
        ],
        child: Builder(builder: (context) {
          final GoRouter goRouter =
              Provider.of<AppRouter>(context, listen: true).router;
          return FutureBuilder(
            future: initializedApp,
            builder: (context, snapshot) {
              return OverlaySupport.global(
                  child: MaterialApp.router(
                routeInformationParser: goRouter.routeInformationParser,
                routerDelegate: goRouter.routerDelegate,
                routeInformationProvider: goRouter.routeInformationProvider,
                debugShowCheckedModeBanner: false,
                title: 'ASM',
                theme: asthaTutorialTheme,
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  // OverrideFormBuilderLocalizationsTh.delegate,
                  FormBuilderLocalizations.delegate,
                  localizationDelegate
                ],
                supportedLocales: localizationDelegate.supportedLocales,
                locale: localizationDelegate.currentLocale,
              ));
            },
          );
        }));
  }
}

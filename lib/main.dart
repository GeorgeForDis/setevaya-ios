import 'package:flutter/material.dart'; // Импортируем библиотеку Flutter для построения пользовательского интерфейса.
import 'package:firebase_core/firebase_core.dart'; // Импортируем библиотеку для инициализации Firebase.
import 'package:firebase_messaging/firebase_messaging.dart'; // Импортируем библиотеку для работы с Firebase Cloud Messaging (FCM).
import 'package:provider/provider.dart'; // Импортируем библиотеку Provider для управления состоянием.
import 'package:shared_preferences/shared_preferences.dart'; // Импортируем библиотеку SharedPreferences для хранения настроек.
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Импортируем библиотеку для локальных уведомлений.
import 'screens/login_screen.dart'; // Импортируем экран входа в приложение.
import 'screens/main_screen.dart'; // Импортируем основной экран приложения.
import 'theme/app_theme.dart'; // Импортируем файл с темами для приложения.
import '../services/auth_service.dart'; // Импортируем сервис аутентификации.
import 'package:flutter_localizations/flutter_localizations.dart'; // Импортируем поддержку локализации.
import 'package:cloud_firestore/cloud_firestore.dart'; // Импортируем библиотеку для работы с Cloud Firestore.


// Общая роль кода:
// Этот код инициализирует и запускает Flutter приложение, интегрированное с Firebase и локальными уведомлениями.
// Основные компоненты включают:
// - Инициализацию Firebase и настройку Firebase Cloud Messaging (FCM) для получения и обработки уведомлений.
// - Запрос разрешений на отправку уведомлений для iOS и получение FCM токена для устройства.
// - Настройку обработчика фоновых сообщений и отображение локальных уведомлений при получении сообщений.
// - Настройку слушателя на новые домашние задания в Firestore и отображение уведомлений при добавлении новых заданий.
// - Конфигурацию локальных уведомлений, включая создание канала уведомлений для важной информации.
// - Запуск приложения с использованием MultiProvider для управления состоянием темы и аутентификации.
// - Определение начального экрана в зависимости от состояния входа пользователя и настройка маршрутизации для экранов входа и основного экрана.



final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); // Создаем экземпляр плагина для локальных уведомлений.

// Функция для обработки фоновых сообщений Firebase.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Инициализируем Firebase, чтобы обеспечить работу в фоне.
  print("Handling a background message: ${message.messageId}"); // Выводим ID сообщения для отладки.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Обеспечиваем инициализацию виджетов перед началом работы с Firebase.
  await Firebase.initializeApp(); // Инициализируем Firebase.

  FirebaseMessaging messaging = FirebaseMessaging.instance; // Получаем экземпляр Firebase Messaging.

  // Запрашиваем разрешения на уведомления для iOS.
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}'); // Выводим статус разрешений для отладки.

  // Получаем FCM токен для текущего устройства.
  String? token = await messaging.getToken();
  print('FCM Token: $token'); // Выводим токен для отладки.

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); // Устанавливаем обработчик фоновых сообщений.

  // Инициализируем локальные уведомления.
  await _initializeLocalNotifications();

  // Подписываемся на сообщения, полученные в режиме foreground.
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Foreground message received: ${message.notification?.title}"); // Выводим заголовок сообщения.
    _showNotification(message); // Отображаем уведомление.
  });

  // Обрабатываем нажатия на уведомления, полученные в фоне или когда приложение было завершено.
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Message clicked: ${message.notification?.title}"); // Выводим заголовок сообщения при нажатии.
  });

  final prefs = await SharedPreferences.getInstance(); // Получаем экземпляр SharedPreferences.
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false; // Проверяем, залогинен ли пользователь.
  final isDarkMode = prefs.getBool('isDarkMode') ?? false; // Проверяем, включен ли темный режим.

  setupHomeworkListener(); // Настраиваем слушатель для новых домашних заданий.

  runApp(StudentApp(isLoggedIn: isLoggedIn, isDarkMode: isDarkMode)); // Запускаем приложение.
}

// Функция для инициализации локальных уведомлений.
Future<void> _initializeLocalNotifications() async {
  const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
  // const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('launcher_icon'); // Устанавливаем иконку для уведомлений на Android.
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      print('Notification clicked with payload: ${response.payload}'); // Выводим данные уведомления при нажатии.
    },
  );

  // Создаем канал для уведомлений с высокой важностью.
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

// Функция для отображения уведомления при получении сообщения в foreground.
void _showNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_not',
        ),
      ),
    );
  }
}

// Функция для настройки слушателя на новые домашние задания.
void setupHomeworkListener() {
  FirebaseFirestore.instance.collection('homework').snapshots().listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        showHomeworkNotification(change.doc); // Показываем уведомление при добавлении нового документа.
      }
    }
  });
}

// Функция для отображения уведомления о новом домашнем задании.
void showHomeworkNotification(DocumentSnapshot doc) {
  final homework = doc.data() as Map<String, dynamic>;
  flutterLocalNotificationsPlugin.show(
    doc.id.hashCode,
    'Новое домашнее задание',
    'Новое домашнее задание по предмету ${homework['subject']}',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'homework_channel',
        'Homework Notifications',
        channelDescription: 'Notifications for new homework assignments',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_not',
      ),
    ),
  );
}

// Основной виджет приложения.
class StudentApp extends StatelessWidget {
  final bool isLoggedIn; // Переменная для хранения состояния входа пользователя.
  final bool isDarkMode; // Переменная для хранения состояния темной темы.

  const StudentApp({super.key, required this.isLoggedIn, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode)), // Провайдер для управления темой.
        ChangeNotifierProvider(create: (_) => AuthService()), // Провайдер для управления аутентификацией.
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Студенческое приложение', // Название приложения.
            theme: themeProvider.getTheme(), // Устанавливаем текущую тему приложения.
            initialRoute: isLoggedIn ? '/main' : '/login', // Определяем начальный экран в зависимости от статуса входа.
            routes: {
              '/login': (context) => const LoginScreen(), // Маршрут к экрану входа.
              '/main': (context) => const MainScreen(), // Маршрут к основному экрану.
            },
            supportedLocales: const [
              Locale('ru', ''), // Поддерживаемый язык - русский.
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}

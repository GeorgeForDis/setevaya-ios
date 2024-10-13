import 'package:flutter/material.dart'; // Импортируем пакет Flutter, который предоставляет виджеты и инструменты для создания UI.
import 'package:cloud_firestore/cloud_firestore.dart'; // Импортируем пакет для работы с Firestore, базой данных от Firebase.
import 'package:shared_preferences/shared_preferences.dart'; // Импортируем пакет для работы с SharedPreferences, который используется для хранения данных на устройстве.
import '../models/homework.dart'; // Импортируем модель Homework, которая описывает структуру домашних заданий.
import 'homework_detail_screen.dart'; // Импортируем экран, который показывает детали домашнего задания.
import '../models/schedule.dart'; // Импортируем модель Schedule, которая описывает структуру расписания.
import 'package:provider/provider.dart'; // Импортируем пакет Provider, который используется для управления состоянием приложения.
import 'package:intl/intl.dart'; // Импортируем пакет intl для форматирования дат.
import '../theme/app_theme.dart'; // Импортируем тему приложения, которая используется для настройки стилей и цветов.
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Импортируем пакет для управления локальными уведомлениями.

//         Общая роль кода:
// Этот код создает экран для отображения списка домашних заданий, позволяя пользователю
// перемещаться между днями недели и видеть расписание уроков и связанных с ними домашних заданий.
// Также код интегрирует уведомления, которые показываются пользователю в виде всплывающих оповещений
// для напоминания о домашних заданиях, и хранит предпочтения уведомлений с помощью SharedPreferences.

// StatefulWidget `HomeworkScreen` отвечает за отображение интерфейса для управления и просмотра списка домашних заданий.
// Он взаимодействует с Firebase Firestore для получения данных о заданиях и расписаниях.
// Локальные уведомления реализованы для напоминаний, и они управляются через плагин `flutter_local_notifications`.

class HomeworkScreen extends StatefulWidget { // Определяем StatefulWidget для экрана домашних заданий.
  const HomeworkScreen({super.key}); // Конструктор класса с поддержкой ключей.

  @override
  _HomeworkScreenState createState() => _HomeworkScreenState(); // Создаем состояние для виджета HomeworkScreen.
}

class _HomeworkScreenState extends State<HomeworkScreen> { // Состояние для экрана домашних заданий.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Экземпляр Firestore для взаимодействия с базой данных.
  late PageController _pageController; // Контроллер для управления страницами в PageView.
  late String _currentDay; // Переменная для хранения текущего дня недели.
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); // Плагин для локальных уведомлений.

  final Map<String, String> _daysOfWeekRussian = { // Карта для перевода дней недели на русский язык.
    'Monday': 'Понедельник',
    'Tuesday': 'Вторник',
    'Wednesday': 'Среда',
    'Thursday': 'Четверг',
    'Friday': 'Пятница',
    'Saturday': 'Суббота',
    'Sunday': 'Воскресенье',
  };

  late List<String> _daysOfWeek; // Список дней недели.

  @override
  void initState() { // Метод инициализации состояния.
    super.initState(); 
    _daysOfWeek = _daysOfWeekRussian.keys.toList();  // Получаем список всех дней недели из карты
    _currentDay = _daysOfWeek[DateTime.now().weekday - 1];  // Определяем текущий день недели на основе текущей даты
    _pageController = PageController( // Создаем контроллер для PageView.
      initialPage: _daysOfWeek.indexOf(_currentDay),  // Устанавливаем начальную страницу в соответствии с текущим днём
    );
  }

  Future<void> _initializeNotifications() async { // Метод для инициализации локальных уведомлений.
    const AndroidInitializationSettings initializationSettingsAndroid = // Настройки иконки для уведомлений на Android.
    AndroidInitializationSettings('@mipmap/ic_not');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, // Применяем настройки для Android.
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings); // Инициализируем плагин для уведомлений.

    WidgetsBinding.instance.addPostFrameCallback((_) async { // Добавляем колбэк, который выполнится после отрисовки виджета.
      SharedPreferences prefs = await SharedPreferences.getInstance(); // Получаем экземпляр SharedPreferences.
      bool dialogShown = prefs.getBool('notification_dialog_shown') ?? false; // Проверяем, показывался ли диалог ранее.
      if (!dialogShown) { // Если диалог не показывался, показываем его.
        _showNotificationPermissionDialog(); // Показываем диалог для разрешения уведомлений.
      }
    });
  }

  Future<void> _showNotificationPermissionDialog() async { // Метод для показа диалога разрешения на получение уведомлений.
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Получаем экземпляр SharedPreferences.
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Разрешить уведомления'), // Заголовок диалога.
          content: const Text('Хотите ли вы получать уведомления о домашних заданиях?'), // Содержание диалога.
          actions: <Widget>[
            TextButton(
              child: const Text('Нет'), // Кнопка "Нет".
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог.
                prefs.setBool('notification_dialog_shown', true); // Устанавливаем флаг, что диалог был показан.
              },
            ),
            TextButton(
              child: const Text('Да'), // Кнопка "Да".
              onPressed: () async {
                Navigator.of(context).pop(); // Закрываем диалог.
                prefs.setBool('notification_dialog_shown', true); // Устанавливаем флаг, что диалог был показан.
                _showHomeworkNotificationPopupPermissionDialog(); // Показываем следующий диалог для разрешения всплывающих уведомлений.
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showHomeworkNotificationPopupPermissionDialog() async { // Метод для показа диалога разрешения на всплывающие уведомления.
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Разрешить всплывающие уведомления'), // Заголовок диалога.
          content: const Text('Хотите ли вы разрешить всплывающие уведомления для домашних заданий?'), // Содержание диалога.
          actions: <Widget>[
            TextButton(
              child: const Text('Нет'), // Кнопка "Нет".
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог.
              },
            ),
            TextButton(
              child: const Text('Да'), // Кнопка "Да".
              onPressed: () async {
                Navigator.of(context).pop(); // Закрываем диалог.
                await _enablePopupNotifications(); // Включаем всплывающие уведомления.
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _enablePopupNotifications() async { // Метод для включения всплывающих уведомлений.
    const AndroidNotificationDetails androidPlatformChannelSpecifics = // Настройки уведомлений для Android.
    AndroidNotificationDetails(
      'default_channel_id', // ID канала уведомлений.
      'Основной канал', // Имя канала уведомлений.
      channelDescription: 'Основной канал для уведомлений', // Описание канала.
      importance: Importance.high, // Уровень важности уведомлений.
      priority: Priority.high, // Приоритет уведомлений.
      enableLights: true, // Включить подсветку.
      enableVibration: true, // Включить вибрацию.
      playSound: true, // Включить звук.
      styleInformation: DefaultStyleInformation(true, true), // Стиль уведомлений.
    );

    const NotificationDetails platformChannelSpecifics = // Настройки уведомлений для платформы.
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show( // Отправляем тестовое уведомление.
      0, // ID уведомления.
      'Тестовое уведомление', // Заголовок уведомления.
      'Всплывающие уведомления включены!', // Содержание уведомления.
      platformChannelSpecifics, // Настройки уведомления.
      payload: 'Тестовое уведомление', // Полезная нагрузка уведомления.
    );
  }

  void _previousDay() { // Метод для перехода к предыдущему дню.
    if (_pageController.page! > 0) { // Проверяем, не на первой ли странице.
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); // Переходим к предыдущей странице с анимацией.
    }
  }

  void _nextDay() { // Метод для перехода к следующему дню.
    if (_pageController.page! < _daysOfWeek.length - 1) { // Проверяем, не на последней ли странице.
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); // Переходим к следующей странице с анимацией.
    }
  }

  void _navigateToDetail(Homework homework) { // Метод для навигации к экрану с деталями домашнего задания.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeworkDetailScreen(homework: homework), // Переход к экрану с деталями домашнего задания.
      ),
    );
  }

  @override
  Widget build(BuildContext context) { // Метод для построения UI.
    final themeProvider = Provider.of<ThemeProvider>(context); // Получаем текущую тему из Provider.

    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900] : Colors.white; // Цвет фона в зависимости от темы.
    final textColor = themeProvider.isDarkMode ? Colors.grey[200]! : Colors.black; // Цвет текста в зависимости от темы.
    final appBarColor = themeProvider.isDarkMode ? Colors.grey[850]! : Colors.blue; // Цвет AppBar в зависимости от темы.
    final cardColor = themeProvider.isDarkMode ? Colors.grey[800]! : Colors.white; // Цвет карточек в зависимости от темы.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Домашние задания', style: TextStyle(fontFamily: 'Inter',fontSize: 25, color: Colors.white)), // Заголовок AppBar.
        backgroundColor: appBarColor, // Цвет фона AppBar.
      ),
      backgroundColor: backgroundColor, // Цвет фона Scaffold.
      body: Column(
        children: [
          WeekNavigation(
            currentDay: _currentDay, // Текущий день недели.
            onPreviousDay: _previousDay, // Функция для перехода к предыдущему дню.
            onNextDay: _nextDay, // Функция для перехода к следующему дню.
            textColor: textColor, // Цвет текста.
            themeProvider: themeProvider, // Провайдер темы.
            daysOfWeekRussian: _daysOfWeekRussian, // Карта дней недели на русский.
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController, // Контроллер для PageView.
              itemCount: _daysOfWeek.length, // Количество страниц в PageView.
              onPageChanged: (index) { // Обработчик изменения страницы.
                setState(() {
                  _currentDay = _daysOfWeek[index]; // Устанавливаем текущий день при изменении страницы.
                });
              },
              itemBuilder: (context, index) {
                final day = _daysOfWeek[index]; // Получаем текущий день недели.

                return StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('schedules').where('day', isEqualTo: day).snapshots(), // Поток данных расписания из Firestore.
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); // Показываем индикатор загрузки, если данных нет.

                    if (snapshot.hasError) {
                      return const Center(child: Text('Ошибка загрузки расписания', style: TextStyle(color: Colors.red))); // Показываем ошибку, если произошла ошибка загрузки.
                    }

                    final scheduleList = snapshot.data!.docs
                        .map((doc) => Schedule.fromDocument(doc))
                        .toList(); // Преобразуем документы в объекты Schedule.

                    scheduleList.sort((a, b) => a.startTime.compareTo(b.startTime)); // Сортируем расписание по времени начала.

                    return ListView.builder(
                      itemCount: scheduleList.length, // Количество элементов в списке.
                      itemBuilder: (context, index) {
                        final schedule = scheduleList[index]; // Получаем текущее расписание.

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Отступы для карточек.
                          elevation: 4, // Тень карточек.
                          color: cardColor, // Цвет карточек.
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Скругление углов карточек.
                          ),
                          child: ExpansionTile(
                            title: Text(schedule.subject, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter', color: textColor)), // Заголовок ExpansionTile.
                            subtitle: Text('${schedule.startTime} - ${schedule.endTime}', style: TextStyle(fontFamily: 'Inter', color: textColor)), // Подзаголовок ExpansionTile.
                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream: _firestore.collection('homework')
                                    .where('lesson_id', isEqualTo: schedule.lessonId)
                                    .snapshots(), // Поток данных домашних заданий из Firestore.
                                builder: (context, homeworkSnapshot) {
                                  if (!homeworkSnapshot.hasData) {
                                    return ListTile(
                                      title: Text('Загрузка...', style: TextStyle(fontFamily: 'Inter', color: textColor)), // Показываем текст "Загрузка...", если данных нет.
                                    );
                                  }

                                  if (homeworkSnapshot.hasError) {
                                    return const ListTile(
                                      title: Text('Ошибка загрузки домашних заданий', style: TextStyle(fontFamily: 'Inter', color: Colors.red)), // Показываем ошибку, если произошла ошибка загрузки.
                                    );
                                  }

                                  final homeworkList = homeworkSnapshot.data!.docs
                                      .map((doc) => Homework.fromDocument(doc))
                                      .toList(); // Преобразуем документы в объекты Homework.

                                  if (homeworkList.isEmpty) {
                                    return ListTile(
                                      title: Text('Нет домашних заданий', style: TextStyle(fontFamily: 'Inter', color: textColor)), // Показываем текст "Нет домашних заданий", если список пуст.
                                    );
                                  }

                                  return Column(
                                    children: homeworkList.map((homework) => ListTile(
                                      leading: Icon(Icons.assignment, color: textColor), // Иконка для задания.
                                      title: Text(homework.title, style: TextStyle(fontFamily: 'Inter', color: textColor)), // Заголовок задания.
                                      subtitle: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              DateFormat('d MMMM', 'ru_RU').format(homework.dueDate.toLocal()), // Дата сдачи задания в формате "день месяц".
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                color: Colors.red, // Цвет даты.
                                                fontWeight: FontWeight.bold, // Жирный текст.
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () => _navigateToDetail(homework), // Переход к деталям задания при нажатии.
                                    )).toList(), // Преобразуем список домашних заданий в список виджетов ListTile.
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() { // Метод для освобождения ресурсов.
    _pageController.dispose(); // Освобождаем ресурсы контроллера страниц.
    super.dispose(); // Вызываем метод dispose родительского класса.
  }
}

class WeekNavigation extends StatelessWidget { // Виджет для навигации по неделям.
  final String currentDay; // Текущий день недели.
  final VoidCallback onPreviousDay; // Функция для перехода к предыдущему дню.
  final VoidCallback onNextDay; // Функция для перехода к следующему дню.
  final Color textColor; // Цвет текста.
  final ThemeProvider themeProvider; // Провайдер темы.
  final Map<String, String> daysOfWeekRussian; // Карта дней недели на русский язык.

  const WeekNavigation({super.key,
    required this.currentDay,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.textColor,
    required this.themeProvider,
    required this.daysOfWeekRussian,
  });

  @override
  Widget build(BuildContext context) { // Метод для построения UI виджета.
    final navigationBackgroundColor = themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white; // Цвет фона навигации в зависимости от темы.

    return Container(
      padding: const EdgeInsets.all(8.0), // Отступы внутри контейнера.
      color: navigationBackgroundColor, // Цвет фона контейнера.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Распределяем элементы по краям.
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: textColor), // Иконка для перехода к предыдущему дню.
            onPressed: onPreviousDay, // Функция для перехода к предыдущему дню.
          ),
          Expanded(
            child: Center(
              child: Text(
                daysOfWeekRussian[currentDay] ?? '', // Текущий день недели на русском.
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 ? 24 : 20, // Размер шрифта в зависимости от ширины экрана.
                    fontWeight: FontWeight.bold, // Жирный текст.
                    fontFamily: 'Inter',
                    color: textColor
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: textColor), // Иконка для перехода к следующему дню.
            onPressed: onNextDay, // Функция для перехода к следующему дню.
          ),
        ],
      ),
    );
  }
}

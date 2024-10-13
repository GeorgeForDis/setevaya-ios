// Подключаем нужные пакеты, чтобы наше приложение работало
import 'package:flutter/material.dart';  // Этот пакет нужен для создания интерфейса
import 'package:cloud_firestore/cloud_firestore.dart';  // Этот пакет позволяет работать с базой данных Firebase
import 'package:provider/provider.dart';  // Этот пакет помогает управлять состоянием приложения
import '../models/schedule.dart';  // Здесь у нас модель для хранения данных о расписании
import '../theme/app_theme.dart';  // А здесь хранятся настройки темы нашего приложения

// Общая роль кода:
// Этот код создает экран для отображения расписания занятий на основе данных из Firestore.
// Он позволяет пользователю просматривать расписание по дням недели и переключаться между днями.
// Основные компоненты включают:
// - Получение данных о расписании из базы данных Firebase Firestore
// - Отображение этих данных в виде карточек на экране
// - Переключение между днями недели с помощью прокрутки страниц и кнопок навигации
// - Адаптация интерфейса под светлую и темную темы с помощью провайдера темы

// Создаем главный виджет для экрана расписания
class ScheduleScreen extends StatefulWidget {
  // Конструктор класса, ничего особенного
  const ScheduleScreen({super.key});

  // Этот метод создает состояние для нашего виджета
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

// Здесь определяется, как будет выглядеть и работать наш экран расписания
class _ScheduleScreenState extends State<ScheduleScreen> {
  // Создаем ссылку на базу данных Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Этот контроллер будет управлять прокруткой страниц
  late PageController _pageController;

  // Переменная для хранения текущего дня недели
  late String _currentDay;

  // Словарь для перевода дней недели на русский язык
  final Map<String, String> _daysOfWeekRussian = {
    'Monday': 'Понедельник',
    'Tuesday': 'Вторник',
    'Wednesday': 'Среда',
    'Thursday': 'Четверг',
    'Friday': 'Пятница',
    'Saturday': 'Суббота',
    'Sunday': 'Воскресенье',
  };

  // Список дней недели
  late List<String> _daysOfWeek;

  // Этот метод вызывается, когда виджет впервые создается
  @override
  void initState() {
    super.initState();
    // Заполняем список дней недели
    _daysOfWeek = _daysOfWeekRussian.keys.toList();
    // Устанавливаем текущий день как первый в списке
    _currentDay = _daysOfWeek[0];
    // Создаем контроллер для прокрутки страниц
    _pageController = PageController();
  }

  // Этот метод переключает на предыдущий день
  void _previousDay() {
    if (_pageController.page! > 0) {  // Проверяем, что мы не на первой странице
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);  // Переходим к предыдущей странице с анимацией
    }
  }

  // А этот метод переключает на следующий день
  void _nextDay() {
    if (_pageController.page! < _daysOfWeek.length - 1) {  // Проверяем, что мы не на последней странице
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);  // Переходим к следующей странице с анимацией
    }
  }

  // Этот метод строит интерфейс нашего экрана
  @override
  Widget build(BuildContext context) {
    // Получаем текущую тему из провайдера
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Определяем цвета в зависимости от текущей темы (светлой или темной)
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900] : Colors.white;  // Цвет фона экрана
    final textColor = themeProvider.isDarkMode ? Colors.grey[200]! : Colors.black;  // Цвет текста
    final textColo1 = themeProvider.isDarkMode ? Colors.grey[200]! : Colors.white;  // Цвет текста для заголовка
    final appBarColor = themeProvider.isDarkMode ? Colors.grey[850]! : Colors.blue;  // Цвет верхней панели приложения
    final cardColor = themeProvider.isDarkMode ? Colors.grey[800]! : Colors.white;  // Цвет карточек

    // Начинаем строить наш экран
    return Scaffold(
      // Верхняя панель приложения
      appBar: AppBar(
        title: Text('Расписание', style: TextStyle(fontFamily: 'Inter', color: textColo1)),  // Заголовок AppBar
        backgroundColor: appBarColor,  // Цвет фона AppBar
      ),
      // Цвет фона всего экрана
      backgroundColor: backgroundColor,
      // Основное содержимое экрана
      body: Column(
        children: [
          // Виджет для навигации по дням недели
          WeekNavigation(
            currentDay: _currentDay,
            onPreviousDay: _previousDay,
            onNextDay: _nextDay,
            textColor: textColor,
            themeProvider: themeProvider,
            daysOfWeekRussian: _daysOfWeekRussian,
          ),
          // Основная часть экрана с расписанием
          Expanded(
            child: PageView.builder(
              controller: _pageController,  // Контроллер для управления прокруткой страниц
              itemCount: _daysOfWeek.length,  // Количество страниц
              onPageChanged: (index) {  // Когда страница изменяется
                setState(() {
                  _currentDay = _daysOfWeek[index];  // Обновляем текущий день
                });
              },
              itemBuilder: (context, index) {
                final day = _daysOfWeek[index];  // Получаем текущий день недели

                // Здесь мы получаем данные из Firebase в реальном времени
                return StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('schedules').where('day', isEqualTo: day).snapshots(),  // Подписываемся на изменения данных в коллекции 'schedules'
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());  // Показать индикатор загрузки, пока данные загружаются

                    // Преобразуем полученные данные в список объектов Schedule
                    final scheduleList = snapshot.data!.docs
                        .map((doc) => Schedule.fromDocument(doc))
                        .toList();

                    // Сортируем расписание по времени начала
                    scheduleList.sort((a, b) => a.startTime.compareTo(b.startTime));

                    // Строим список занятий для текущего дня
                    return ListView.builder(
                      itemCount: scheduleList.length,  // Количество элементов в списке
                      itemBuilder: (context, index) {
                        final schedule = scheduleList[index];  // Получаем текущее занятие

                        // Каждое занятие отображается в виде карточки
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),  // Отступы вокруг карточки
                          elevation: 4,  // Эффект тени карточки
                          color: cardColor,  // Цвет фона карточки
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),  // Форма карточки с закругленными углами
                          ),
                          child: ListTile(
                            title: Text(schedule.subject, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter', color: textColor)),  // Название предмета
                            subtitle: Text('${schedule.startTime} - ${schedule.endTime}', style: TextStyle(fontFamily: 'Inter', color: textColor)),  // Время начала и конца занятия
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

  // Этот метод вызывается, когда виджет больше не нужен
  @override
  void dispose() {
    _pageController.dispose();  // Освобождаем ресурсы контроллера страниц
    super.dispose();
  }
}

// Отдельный виджет для навигации по дням недели
class WeekNavigation extends StatelessWidget {
  final String currentDay;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final Color textColor;
  final ThemeProvider themeProvider;
  final Map<String, String> daysOfWeekRussian;

  // Конструктор класса, принимает все нужные параметры
  const WeekNavigation({super.key,
    required this.currentDay,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.textColor,
    required this.themeProvider,
    required this.daysOfWeekRussian,
  });

  // Метод для построения виджета навигации
  @override
  Widget build(BuildContext context) {
    final navigationBackgroundColor = themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;  // Цвет фона навигации

    return Container(
      padding: const EdgeInsets.all(8.0),  // Отступы внутри контейнера
      color: navigationBackgroundColor,  // Цвет фона контейнера
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Расположение элементов по бокам
        children: [
          // Кнопка для перехода к предыдущему дню
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: textColor),  // Иконка стрелки назад
            onPressed: onPreviousDay,  // Действие при нажатии
          ),
          // Текст с текущим днем недели
          Expanded(
            child: Center(
              child: Text(
                daysOfWeekRussian[currentDay] ?? '',  // Название текущего дня недели на русском
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter', color: textColor),  // Стиль текста
              ),
            ),
          ),
          // Кнопка для перехода к следующему дню
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: textColor),  // Иконка стрелки вперед
            onPressed: onNextDay,  // Действие при нажатии
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart'; // Импортируем пакет Flutter для создания UI
import 'homework_screen.dart'; // Импортируем экран задач
import 'schedule_screen.dart'; // Импортируем экран расписания
import 'profile_screen.dart'; // Импортируем экран профиля

//Этот код создает главный экран приложения с нижней навигационной панелью.
// Он позволяет переключаться между тремя экранами: задачами, расписанием и
// профилем пользователя, используя `PageView` и `BottomNavigationBar`.


// StatefulWidget для главного экрана
class MainScreen extends StatefulWidget {
  const MainScreen({super.key}); // Конструктор класса с поддержкой ключей

  @override
  _MainScreenState createState() => _MainScreenState(); // Создаем состояние для этого виджета
}

// Состояние главного экрана
class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Индекс выбранного элемента в нижней навигационной панели

  final PageController _pageController = PageController(); // Контроллер для PageView

  final List<Widget> _pages = [ // Список страниц для отображения
    const HomeworkScreen(), // Экран задач
    const ScheduleScreen(), // Экран расписания
    const ProfileScreen(), // Экран профиля
  ];

  // Метод для обработки нажатия на элемент навигационной панели
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Обновляем индекс выбранного элемента
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300), // Продолжительность анимации
      curve: Curves.easeInOut, // Кривая анимации
    );
  }

  @override
  void dispose() {
    _pageController.dispose(); // Освобождаем ресурсы контроллера страницы
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController, // Устанавливаем контроллер для PageView
        children: _pages, // Список страниц для отображения
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index; // Обновляем индекс выбранного элемента при смене страницы
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment), // Иконка для экрана задач
            label: 'Задания', // Подпись для экрана задач
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule), // Иконка для экрана расписания
            label: 'Расписание', // Подпись для экрана расписания
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Иконка для экрана профиля
            label: 'Профиль', // Подпись для экрана профиля
          ),
        ],
        currentIndex: _selectedIndex, // Устанавливаем текущий индекс выбранного элемента
        onTap: _onItemTapped, // Устанавливаем обработчик нажатий на элементы
      ),
    );
  }
}

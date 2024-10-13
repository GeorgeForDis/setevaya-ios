import 'package:flutter/material.dart'; // Импортируем библиотеку Flutter для работы с пользовательским интерфейсом.
import 'package:shared_preferences/shared_preferences.dart'; // Импортируем библиотеку SharedPreferences для сохранения данных.


// Общая роль кода:
// Этот код определяет класс ThemeProvider, который управляет темной и светлой темой в приложении.
// Он хранит состояние текущей темы (темная или светлая) и предоставляет методы для переключения темы и получения текущей темы.
// Основные компоненты включают:
// - Геттер isDarkMode: Позволяет получить текущее состояние темы (темная или светлая).
// - Метод getTheme: Возвращает объект ThemeData, соответствующий текущей теме (темной или светлой).
// - Метод toggleTheme: Переключает состояние темы и сохраняет его в SharedPreferences, чтобы пользовательские предпочтения сохранялись между запусками приложения.
// - Статическая переменная _lightTheme: Определяет параметры для светлой темы, включая основные цвета, яркость, шрифты и стили для AppBar и текста.
// - Статическая переменная _darkTheme: Определяет параметры для темной темы с аналогичными настройками, но для темной темы.
// Этот класс позволяет легко изменять и сохранять тему приложения, обеспечивая персонализированный пользовательский интерфейс.


class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode; // Приватная переменная для хранения текущего состояния темы (темная или светлая).

  // Конструктор класса, принимающий начальное состояние темы.
  ThemeProvider(this._isDarkMode);

  // Геттер для получения текущего состояния темы (темная или светлая).
  bool get isDarkMode => _isDarkMode;

  // Метод для получения текущей темы (темной или светлой).
  ThemeData getTheme() {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  // Метод для переключения между темной и светлой темой.
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode; // Переключаем состояние темы.
    notifyListeners(); // Уведомляем слушателей об изменении состояния.

    final prefs = await SharedPreferences.getInstance(); // Получаем экземпляр SharedPreferences.
    await prefs.setBool('isDarkMode', _isDarkMode); // Сохраняем текущее состояние темы в SharedPreferences.
  }

  // Статическая переменная для светлой темы.
  static final ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.blue, // Основной цвет для элементов темы.
    brightness: Brightness.light, // Яркость темы (светлая).
    fontFamily: 'Inter', // Шрифт, используемый в приложении.
    appBarTheme: const AppBarTheme(
      elevation: 4, // Высота тени для AppBar.
      backgroundColor: Colors.blue, // Цвет фона AppBar.
      foregroundColor: Colors.white, // Цвет текста в AppBar.
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold), // Стиль для крупных заголовков.
      titleLarge: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold), // Стиль для заголовков.
      bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Inter'), // Стиль для обычного текста.
    ),
  );

  // Статическая переменная для темной темы.
  static final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.blue, // Основной цвет для элементов темы.
    brightness: Brightness.dark, // Яркость темы (темная).
    fontFamily: 'Inter', // Шрифт, используемый в приложении.
    appBarTheme: AppBarTheme(
      elevation: 4, // Высота тени для AppBar.
      backgroundColor: Colors.blue[700], // Цвет фона AppBar.
      foregroundColor: Colors.white, // Цвет текста в AppBar.
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold), // Стиль для крупных заголовков.
      titleLarge: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold), // Стиль для заголовков.
      bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Inter'), // Стиль для обычного текста.
    ),
  );
}

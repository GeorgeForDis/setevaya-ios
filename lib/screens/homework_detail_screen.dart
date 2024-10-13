import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Импортируем пакет intl для работы с датами
import '../models/homework.dart'; // Импортируем модель домашнего задания, которая содержит информацию о нем

//      Общая роль кода:
// Код создает экран для приложения Flutter, который отображает детали домашнего задания. Этот экран состоит из:
//
// Заголовка (AppBar) с названием "Детали Домашнего Задания".
// Основного содержимого (карточки), которая отображает информацию о предмете, заголовке, описании и дате сдачи домашнего задания.
// Карточка использует тему приложения (светлую или тёмную) для автоматического изменения стилей элементов.
// В коде есть проверка на активность тёмной темы, и в зависимости от этого меняются цвета текста, фона и разделителей.


// Экран, который показывает детали конкретного домашнего задания
class HomeworkDetailScreen extends StatelessWidget {
  // Поле для хранения объекта домашнего задания, который мы будем показывать
  final Homework homework;

  // Конструктор для передачи объекта домашнего задания в этот экран
  const HomeworkDetailScreen({super.key, required this.homework});

  @override
  Widget build(BuildContext context) {
    // Создаем объект для форматирования даты (например, "7 Сентября")
    final DateFormat dateFormat = DateFormat('d MMMM', 'ru_RU');
    // Проверяем, включена ли тёмная тема в приложении
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Основная структура экрана с заголовком и телом
      appBar: AppBar(
        title: const Text(
          'Детали Домашнего Задания', // Заголовок в верхней части экрана
          style: TextStyle(
            fontSize: 18, // Размер текста заголовка
            fontWeight: FontWeight.w600, // Толщина текста
            letterSpacing: 0.5, // Пробел между буквами
          ),
        ),
        // Фон AppBar меняется в зависимости от темы (тёмная или светлая)
        backgroundColor: isDarkMode ? Colors.teal[700] : Colors.teal[800],
        elevation: 4, // Тень под AppBar для визуального эффекта
        actions: const [
          // Кнопки действий в правой части AppBar, если такие понадобятся
        ],
      ),
      // Основное содержимое страницы
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Добавляем отступы по краям
        child: Card(
          elevation: 4, // Карта с тенями для визуального эффекта
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Округляем углы карты
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Внутренние отступы внутри карты
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Выравниваем содержимое по левому краю
              children: [
                // Строка с информацией о предмете домашнего задания
                _buildInfoRow(Icons.subject, 'Предмет:', homework.subject, context),
                // Разделитель между строками
                _buildDivider(context),
                // Строка с заголовком домашнего задания
                _buildInfoRow(Icons.title, 'Заголовок:', homework.title, context),
                _buildDivider(context),
                // Строка с описанием домашнего задания
                _buildInfoRow(Icons.description, 'Описание:', homework.description, context),
                _buildDivider(context),
                // Строка с датой сдачи домашнего задания, отформатированной в нужный вид
                _buildInfoRow(Icons.calendar_today, 'Дата сдачи:', dateFormat.format(homework.dueDate), context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Этот метод создает строку с информацией, такой как иконка, метка и значение
  Widget _buildInfoRow(IconData icon, String label, String value, BuildContext context) {
    // Получаем тему текста для правильного отображения стилей
    final textTheme = Theme.of(context).textTheme;
    // Проверяем, включена ли тёмная тема
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Выравниваем по верху строки
      children: [
        // Отображаем иконку перед текстом
        Icon(icon, color: Theme.of(context).iconTheme.color, size: 20),
        const SizedBox(width: 8), // Добавляем небольшой отступ между иконкой и текстом
        Expanded(
          // Расширяем текст для заполнения доступного пространства
          child: RichText(
            text: TextSpan(
              children: [
                // Текст метки, например "Предмет:"
                TextSpan(
                  text: '$label ', // Добавляем пробел после метки
                  style: TextStyle(
                    fontSize: 16, // Размер шрифта
                    fontWeight: FontWeight.bold, // Толщина шрифта
                    color: isDarkMode ? Colors.white : Colors.black, // Цвет текста в зависимости от темы
                  ),
                ),
                // Текст значения, например, "Математика"
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 16, // Размер шрифта значения
                    color: isDarkMode ? Colors.grey[300] : Colors.black87, // Цвет текста в зависимости от темы
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Этот метод создает разделитель (линию) между строками
  Widget _buildDivider(BuildContext context) {
    // Проверяем, активна ли тёмная тема
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Добавляем вертикальные отступы
      child: Divider(
        color: isDarkMode ? Colors.grey[700] : Colors.grey[300], // Цвет линии в зависимости от темы
        thickness: 1, // Толщина линии
      ),
    );
  }
}

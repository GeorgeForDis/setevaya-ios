import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

// Общая роль кода:
// Этот код создает экран для верификации email-адреса, на который был отправлен код подтверждения.
// Он предоставляет пользователю поле для ввода кода, отображает сообщение с email и кнопку для проверки кода.
// Основные компоненты включают:
// - Поле для ввода кода верификации с контроллером для управления текстом
// - Индикатор загрузки, показывающий, что идет процесс проверки кода
// - Сообщение об ошибке, если код пустой или произошла другая ошибка
// - Обработчик нажатия кнопки "Verify", который проверяет введенный код и переходит на экран домашнего задания, если все прошло успешно




// Это наш главный виджет для экрана верификации email.
// Он принимает email в качестве параметра, который мы будем отображать пользователю.
class VerifyEmailScreen extends StatefulWidget {
  final String email;  // Email, на который был отправлен код верификации
  const VerifyEmailScreen({super.key, required this.email});

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

// Здесь мы определяем состояние нашего экрана.
// Оно будет хранить всю логику и данные, которые могут изменяться.
class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  // Контроллер для управления текстовым полем, куда пользователь будет вводить код
  final _codeController = TextEditingController();

  // Флаг, показывающий, идет ли сейчас процесс загрузки
  bool _loading = false;

  // Переменная для хранения сообщения об ошибке, если что-то пойдет не так
  String? _errorMessage;

  // Эта функция будет вызываться, когда пользователь нажмет кнопку "Verify"
  void _verifyCode() async {
    // Сначала мы показываем индикатор загрузки и очищаем предыдущие ошибки
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // Получаем код, который ввел пользователь
      final code = _codeController.text;

      // Проверяем, не пустой ли код
      if (code.isEmpty) {
        throw Exception('Verification code cannot be empty.');
      }

      // Здесь мы имитируем процесс верификации, ожидая 2 секунды
      // В реальном приложении здесь был бы запрос к серверу для проверки кода
      await Future.delayed(const Duration(seconds: 2));

      // Если все прошло успешно, переходим на экран с домашним заданием
      Navigator.pushReplacementNamed(context, '/homework');
    } catch (e) {
      // Если возникла ошибка, мы сохраняем ее текст, чтобы показать пользователю
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      // В любом случае, успешно или нет, мы скрываем индикатор загрузки
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Получаем текущую тему из провайдера
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Определяем цвета в зависимости от текущей темы (светлой или темной)
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900] : Colors.white;  // Цвет фона экрана
    final textColor = themeProvider.isDarkMode ? Colors.grey[200]! : Colors.black;  // Цвет текста
    final buttonColor = themeProvider.isDarkMode ? Colors.blueAccent : Colors.blue;  // Цвет кнопки
    const errorColor = Colors.red;  // Цвет текста ошибки

    // Теперь строим наш UI
    return Scaffold(
      // Настраиваем верхнюю панель приложения
      appBar: AppBar(
        title: Text('Verify Email', style: TextStyle(color: textColor)),  // Заголовок AppBar
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[850] : Colors.blue,  // Цвет фона AppBar
      ),
      // Задаем цвет фона всего экрана
      backgroundColor: backgroundColor,
      // Основное содержимое экрана
      body: Padding(
        padding: const EdgeInsets.all(16.0),  // Отступы вокруг основного содержимого
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // Центрируем содержимое по вертикали
          children: [
            // Показываем пользователю, на какой email был отправлен код
            Text(
              'A verification code has been sent to ${widget.email}',  // Сообщение с email
              style: TextStyle(color: textColor),  // Цвет текста
            ),
            const SizedBox(height: 16),  // Отступ между элементами
            // Поле для ввода кода верификации
            TextField(
              controller: _codeController,  // Контроллер для управления текстовым полем
              decoration: InputDecoration(
                labelText: 'Verification Code',  // Подсказка для пользователя
                labelStyle: TextStyle(color: textColor),  // Цвет текста подсказки
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: textColor),  // Цвет границы при обычном состоянии
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: textColor),  // Цвет границы при фокусе
                ),
                errorText: _errorMessage,  // Сообщение об ошибке
                errorStyle: const TextStyle(color: errorColor),  // Цвет текста ошибки
              ),
              style: TextStyle(color: textColor),  // Цвет текста ввода
            ),
            const SizedBox(height: 16),  // Отступ между элементами
            // Здесь мы показываем либо индикатор загрузки, либо кнопку "Verify"
            _loading
                ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(buttonColor),  // Цвет индикатора загрузки
            )
                : ElevatedButton(
              onPressed: _verifyCode,  // Действие при нажатии
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,  // Цвет кнопки
              ),
              child: const Text('Verify'),  // Текст кнопки
            ),
          ],
        ),
      ),
    );
  }
}

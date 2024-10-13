import 'package:flutter/material.dart'; // Импортируем пакет Flutter для создания UI
import 'package:provider/provider.dart'; // Импортируем пакет Provider для управления состоянием
import 'package:shared_preferences/shared_preferences.dart'; // Импортируем пакет SharedPreferences для хранения данных
import 'package:email_validator/email_validator.dart'; // Импортируем пакет для валидации email
import '../services/auth_service.dart'; // Импортируем сервис авторизации
import 'package:permission_handler/permission_handler.dart'; // Импортируем пакет для обработки разрешений

//         Общая роль кода:
// Этот код создает экран для входа и регистрации в приложение, управляя процессами авторизации,
// обработки разрешений на уведомления и валидации данных пользователя. С помощью `AuthService` код
// взаимодействует с сервером для выполнения операций входа и регистрации. Также используются:
// 1. `Provider` — для получения сервиса авторизации (AuthService) и управления состоянием.
// 2. `SharedPreferences` — для хранения данных о входе пользователя и его предпочтений.
// 3. `email_validator` — для проверки корректности email.
// 4. `permission_handler` — для запроса разрешений на отправку уведомлений.

// StatefulWidget для экрана входа/регистрации
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // Конструктор класса с поддержкой ключей

  @override
  _LoginScreenState createState() => _LoginScreenState(); // Создаем состояние для этого виджета
}

// Состояние экрана входа/регистрации
class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(); // Контроллер для поля email
  final _passwordController = TextEditingController(); // Контроллер для поля пароля
  final _confirmPasswordController = TextEditingController(); // Контроллер для поля подтверждения пароля
  final _firstNameController = TextEditingController(); // Контроллер для поля имени
  final _lastNameController = TextEditingController(); // Контроллер для поля фамилии

  bool _isLogin = true; // Флаг для переключения между входом и регистрацией
  bool _loading = false; // Флаг для отображения состояния загрузки
  String? _errorMessage; // Переменная для хранения сообщения об ошибке
  bool _isResendButtonDisabled = false; // Флаг для включения/выключения кнопки повторной отправки
  bool _showResendButton = false; // Флаг для показа кнопки повторной отправки
  int _resendCooldown = 0; // Таймер для кнопки повторной отправки
  late final AuthService _auth; // Сервис авторизации

  @override
  void initState() {
    super.initState(); // Вызываем метод initState родительского класса
    _auth = Provider.of<AuthService>(context, listen: false); // Инициализируем AuthService
  }

  // Метод для переключения между входом и регистрацией
  void _toggleFormMode() {
    setState(() {
      _isLogin = !_isLogin; // Переключаем флаг
      _errorMessage = null; // Очищаем сообщение об ошибке
      _showResendButton = false; // Скрываем кнопку повторной отправки
    });
  }

  // Метод для отображения диалога об успешной регистрации
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Регистрация успешна'), // Заголовок диалога
          content: const Text(
              'Письмо с подтверждением отправлено на вашу почту. Проверьте свою почту для подтверждения.'), // Содержание диалога
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
                setState(() {
                  _showResendButton = true; // Показываем кнопку повторной отправки
                  _toggleFormMode(); // Переключаем форму
                });
              },
              child: const Text('OK'), // Кнопка OK
            ),
          ],
        );
      },
    );
  }

  // Метод для повторной отправки письма с подтверждением
  Future<void> _resendVerificationEmail() async {
    try {
      await _auth.resendVerificationEmail(_emailController.text.trim()); // Вызываем метод для повторной отправки email
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Письмо отправлено повторно.')), // Показываем сообщение о успешной отправке
      );
      setState(() {
        _isResendButtonDisabled = true; // Выключаем кнопку повторной отправки
        _resendCooldown = 60; // Устанавливаем таймер в 60 секунд
      });
      _startResendCooldown(); // Запускаем таймер
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при повторной отправке письма: ${e.toString()}')), // Показываем сообщение об ошибке
      );
    }
  }

  // Метод для запуска таймера для кнопки повторной отправки
  void _startResendCooldown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--; // Уменьшаем таймер
        });
        _startResendCooldown(); // Продолжаем отсчет
      } else {
        setState(() {
          _isResendButtonDisabled = false; // Включаем кнопку после завершения таймера
        });
      }
    });
  }

  // Метод для запроса разрешения на уведомления
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request(); // Запрашиваем разрешение
    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Разрешение на уведомления получено')), // Уведомляем пользователя о получении разрешения
      );
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Разрешение на уведомления отклонено')), // Уведомляем пользователя об отказе
      );
    }
  }

  // Метод для отображения диалога запроса разрешения на уведомления
  void _showNotificationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Разрешение на уведомления'), // Заголовок диалога
          content: const Text(
              'Для получения важных обновлений и информации, пожалуйста, разрешите отправку уведомлений.'), // Содержание диалога
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'), // Кнопка отмены
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
              },
            ),
            TextButton(
              child: const Text('Разрешить'), // Кнопка разрешения
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
                _requestNotificationPermission(); // Запрашиваем разрешение на уведомления
              },
            ),
          ],
        );
      },
    );
  }

  // Метод для отправки данных формы и выполнения входа/регистрации
  Future<void> _submit() async {
    if (_loading) return; // Если уже идет загрузка, ничего не делаем

    setState(() {
      _loading = true; // Устанавливаем состояние загрузки
      _errorMessage = null; // Очищаем сообщение об ошибке
    });

    final prefs = await SharedPreferences.getInstance(); // Получаем экземпляр SharedPreferences

    // Проверка заполненности полей
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        (!_isLogin && _confirmPasswordController.text.trim().isEmpty) ||
        (!_isLogin && _firstNameController.text.trim().isEmpty) ||
        (!_isLogin && _lastNameController.text.trim().isEmpty)) {
      setState(() {
        _errorMessage = 'Пожалуйста, заполните все поля'; // Сообщение об ошибке
        _loading = false; // Устанавливаем состояние завершенной загрузки
      });
      return;
    }

    // Валидация email
    if (!EmailValidator.validate(_emailController.text.trim())) {
      setState(() {
        _errorMessage = 'Некорректный адрес электронной почты'; // Сообщение об ошибке
        _loading = false; // Устанавливаем состояние завершенной загрузки
      });
      return;
    }

    // Валидация пароля
    if (_passwordController.text.trim().length < 6) {
      setState(() {
        _errorMessage = 'Пароль должен содержать не менее 6 символов'; // Сообщение об ошибке
        _loading = false; // Устанавливаем состояние завершенной загрузки
      });
      return;
    }

    // Проверка совпадения паролей
    if (!_isLogin && _passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = 'Пароли не совпадают'; // Сообщение об ошибке
        _loading = false; // Устанавливаем состояние завершенной загрузки
      });
      return;
    }

    try {
      if (_isLogin) { // Если форма для входа
        await _auth.signIn(_emailController.text.trim(), _passwordController.text.trim()); // Выполняем вход
        if (_auth.isEmailVerified()) { // Проверяем подтверждение email
          await prefs.setBool('isLoggedIn', true); // Устанавливаем флаг входа
          _showNotificationPermissionDialog(); // Показываем диалог разрешения на уведомления
          Navigator.pushReplacementNamed(context, '/main'); // Переходим на главный экран
        } else {
          setState(() {
            _errorMessage = 'Электронная почта не подтверждена. Проверьте свою почту.'; // Сообщение об ошибке
            _showResendButton = true; // Показываем кнопку повторной отправки
          });
        }
      } else { // Если форма для регистрации
        await _auth.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
        ); // Выполняем регистрацию
        _showSuccessDialog(); // Показываем диалог об успешной регистрации
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString(); // Сообщение об ошибке
      });
    } finally {
      setState(() {
        _loading = false; // Устанавливаем состояние завершенной загрузки
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLogin ? 'Вход' : 'Регистрация', // Заголовок в зависимости от режима
          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent, // Цвет фона AppBar
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 600 ? 200 : 16), // Отступы в зависимости от ширины экрана
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isLogin) ...[
                      _buildTextField(_firstNameController, 'Имя'), // Поле имени
                      const SizedBox(height: 16),
                      _buildTextField(_lastNameController, 'Фамилия'), // Поле фамилии
                      const SizedBox(height: 16),
                    ],
                    _buildTextField(_emailController, 'Электронная почта'), // Поле email
                    const SizedBox(height: 16),
                    _buildTextField(_passwordController, 'Пароль',
                        obscureText: true), // Поле пароля
                    const SizedBox(height: 16),
                    if (!_isLogin)
                      _buildTextField(_confirmPasswordController, 'Подтвердите пароль',
                          obscureText: true), // Поле подтверждения пароля
                    const SizedBox(height: 16),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontFamily: 'Inter'), // Сообщение об ошибке
                      ),
                    const SizedBox(height: 16),
                    _loading
                        ? const CircularProgressIndicator() // Индикатор загрузки
                        : ElevatedButton(
                      onPressed: _submit, // Кнопка для отправки данных формы
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.blueAccent, // Цвет кнопки
                        textStyle: const TextStyle(
                            fontFamily: 'Inter', fontWeight: FontWeight.bold),
                      ),
                      child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'), // Текст кнопки
                    ),
                    const SizedBox(height: 16),
                    if (_showResendButton)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Письмо не пришло? '),
                          TextButton(
                            onPressed:
                            _isResendButtonDisabled ? null : _resendVerificationEmail, // Кнопка повторной отправки
                            child: Text(
                              'Отправить повторно',
                              style: TextStyle(
                                color: _isResendButtonDisabled
                                    ? Colors.grey
                                    : Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_isResendButtonDisabled)
                            Text(' ($_resendCooldown секунд)',
                                style: const TextStyle(color: Colors.redAccent)), // Таймер на кнопке
                        ],
                      ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _toggleFormMode, // Кнопка для переключения между входом и регистрацией
                      child: Text(
                        _isLogin ? 'Создать аккаунт' : 'Уже есть аккаунт? Войти',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Метод для создания текстового поля
  TextField _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label, // Подпись текстового поля
        border: const OutlineInputBorder(), // Граница текстового поля
      ),
    );
  }
}

import 'package:flutter/material.dart'; // Импортируем библиотеку Flutter, которая содержит виджеты и материалы для построения пользовательских интерфейсов.
import 'package:firebase_auth/firebase_auth.dart'; // Импортируем библиотеку Firebase Auth для управления аутентификацией пользователей.
import 'package:cloud_firestore/cloud_firestore.dart'; // Импортируем библиотеку Cloud Firestore для работы с базой данных.
import 'package:provider/provider.dart'; // Импортируем библиотеку Provider для управления состоянием приложения.
import '../theme/app_theme.dart'; // Импортируем файл темы приложения для определения визуальных стилей.

//Роль кода:
// Этот код создает экран профиля пользователя в приложении, предоставляя возможность управления учетной записью, включая отображение информации о пользователе, переключение между темной и светлой темами, сброс пароля и выход из системы.
//
// Основные задачи:
// Firebase Auth: Получение текущего аутентифицированного пользователя и предоставление возможности сброса пароля, а также выхода из учетной записи.
// Firestore: Загрузка и отображение данных пользователя из базы данных Cloud Firestore.
// Provider: Управление состоянием темы (темная/светлая) через ThemeProvider.
// UI компоненты: Создание интерфейса с использованием таких виджетов, как Scaffold, AppBar, Card, AnimatedSwitcher, и ElevatedButton для отображения информации о пользователе и взаимодействия с ним.
// Диалоговые окна: Использование диалогов подтверждения для действий, таких как сброс пароля и выход из системы.


class ProfileScreen extends StatelessWidget { // Определяем виджет экрана профиля, который не имеет состояния.
  const ProfileScreen({super.key}); // Конструктор класса ProfileScreen, принимает ключ для уникальной идентификации виджета.

  // Метод для сброса пароля
  Future<void> _resetPassword(BuildContext context) async { // Асинхронная функция, которая отправляет запрос на сброс пароля.
    final user = FirebaseAuth.instance.currentUser; // Получаем текущего аутентифицированного пользователя из Firebase Auth.
    if (user != null && user.email != null) { // Проверяем, что пользователь существует и у него есть email.
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!); // Отправляем email для сброса пароля.
      ScaffoldMessenger.of(context).showSnackBar( // Отображаем сообщение на экране.
        const SnackBar(content: Text('Ссылка для сброса пароля отправлена на ваш email.')), // Сообщение о том, что ссылка для сброса пароля отправлена.
      );
    }
  }

  // Метод для отображения диалогового окна с подтверждением
  Future<void> _showConfirmationDialog(
      BuildContext context, { // Асинхронная функция для отображения диалога подтверждения.
        required String title, // Заголовок диалога.
        required String content, // Содержимое диалога.
        required VoidCallback onConfirm, // Функция, которая будет вызвана при подтверждении действия.
      }) async {
    return showDialog<void>( // Показываем диалоговое окно.
      context: context, // Контекст текущего виджета.
      barrierDismissible: false, // Отключаем возможность закрытия диалога при клике вне его.
      builder: (BuildContext context) { // Создаем виджет диалогового окна.
        return AlertDialog(
          title: Text(title), // Заголовок диалога.
          content: SingleChildScrollView( // Позволяет содержимому прокручиваться, если оно превышает размеры окна.
            child: ListBody(
              children: <Widget>[
                Text(content), // Содержимое диалога.
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'), // Кнопка для отмены действия.
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог при нажатии на кнопку.
              },
            ),
            TextButton(
              child: const Text('Подтвердить'), // Кнопка для подтверждения действия.
              onPressed: () {
                onConfirm(); // Выполняем действие, переданное в параметре onConfirm.
                Navigator.of(context).pop(); // Закрываем диалог после выполнения действия.
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) { // Метод, который строит пользовательский интерфейс.
    final user = FirebaseAuth.instance.currentUser; // Получаем текущего аутентифицированного пользователя.
    final themeProvider = Provider.of<ThemeProvider>(context); // Получаем текущую тему приложения.

    // Определяем цвета в зависимости от текущей темы.
    final isDarkMode = themeProvider.isDarkMode; // Проверяем, включен ли темный режим.
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white; // Цвет фона экрана.
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white; // Цвет карт для отображения информации.
    final textColor = isDarkMode ? Colors.grey[200]! : Colors.black; // Цвет текста.
    final textColo1 = isDarkMode ? Colors.grey[200]! : Colors.white; // Цвет текста для заголовка.

    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль', style: TextStyle(color: textColo1)), // Заголовок AppBar.
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.blue, // Цвет фона AppBar в зависимости от темы.
      ),
      backgroundColor: backgroundColor, // Цвет фона экрана в зависимости от темы.
      body: user == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Пользователь не вошел в систему', style: TextStyle(fontSize: 18, color: textColor)), // Сообщение о том, что пользователь не вошел в систему.
            const SizedBox(height: 16), // Пробел между текстом и кнопкой.
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login'); // Переход к экрану входа при нажатии на кнопку.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.blueGrey : Colors.blue, // Цвет кнопки в зависимости от темы.
                foregroundColor: Colors.white, // Цвет текста на кнопке.
                padding: const EdgeInsets.symmetric(vertical: 16), // Отступы внутри кнопки.
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Форма кнопки с закругленными углами.
                minimumSize: const Size(double.infinity, 50), // Минимальные размеры кнопки.
              ),
              child: const Text('Войти'), // Текст на кнопке.
            ),
          ],
        ),
      )
          : FutureBuilder<DocumentSnapshot>( // Используем FutureBuilder для обработки данных асинхронно.
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(), // Запрос данных пользователя из Firestore.
        builder: (context, snapshot) { // Создаем виджет в зависимости от состояния данных.
          if (snapshot.connectionState == ConnectionState.waiting) { // Если данные еще загружаются.
            return const Center(child: CircularProgressIndicator()); // Показываем индикатор загрузки.
          }

          if (!snapshot.hasData || !snapshot.data!.exists) { // Если данных нет или они не существуют.
            return Center(child: Text('Данные пользователя не найдены', style: TextStyle(fontSize: 18, color: textColor))); // Сообщение об отсутствии данных.
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>; // Преобразуем данные в Map.

          return SingleChildScrollView( // Позволяет прокручивать содержимое, если оно превышает размеры экрана.
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Отступы вокруг содержимого.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание элементов по левому краю.
                children: [
                  Center(
                    child: AnimatedSwitcher( // Виджет для анимации изменения дочерних элементов.
                      duration: const Duration(milliseconds: 300), // Длительность анимации.
                      child: Text(
                        '${userData['first_name']} ${userData['last_name']}', // Имя и фамилия пользователя.
                        key: ValueKey(isDarkMode), // Ключ для уникальности виджета и управления анимацией.
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor), // Стиль текста.
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // Пробел между элементами.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300), // Длительность анимации.
                    child: Card( // Виджет карты для отображения информации о пользователе.
                      key: ValueKey(isDarkMode), // Ключ для уникальности виджета.
                      color: cardColor, // Цвет карты в зависимости от темы.
                      elevation: 4, // Эффект тени карты.
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Форма карты с закругленными углами.
                      child: Padding(
                        padding: const EdgeInsets.all(16.0), // Отступы внутри карты.
                        child: Column(
                          children: [
                            _buildUserInfoRow(Icons.email, 'Email', user.email, textColor), // Строка с email пользователя.
                            Divider(height: 24, color: textColor.withOpacity(0.5)), // Разделительная линия.
                            _buildUserInfoRow(Icons.person, 'Имя', userData['first_name'], textColor), // Строка с именем пользователя.
                            Divider(height: 24, color: textColor.withOpacity(0.5)), // Разделительная линия.
                            _buildUserInfoRow(Icons.person_outline, 'Фамилия', userData['last_name'], textColor), // Строка с фамилией пользователя.
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // Пробел между элементами.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300), // Длительность анимации.
                    child: Card( // Виджет карты для переключателя темы.
                      key: ValueKey(isDarkMode), // Ключ для уникальности виджета.
                      color: cardColor, // Цвет карты в зависимости от темы.
                      elevation: 4, // Эффект тени карты.
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Форма карты с закругленными углами.
                      child: Padding(
                        padding: const EdgeInsets.all(16.0), // Отступы внутри карты.
                        child: Row( // Выравнивание элементов в строку.
                          children: [
                            Icon(Icons.dark_mode, color: textColor), // Иконка для переключателя темы.
                            const SizedBox(width: 16), // Пробел между иконкой и текстом.
                            Expanded(
                              child: Text('Темный режим', style: TextStyle(fontSize: 18, color: textColor)), // Текст переключателя темы.
                            ),
                            Switch(
                              value: isDarkMode, // Состояние переключателя (включен или выключен темный режим).
                              onChanged: (_) => themeProvider.toggleTheme(), // Изменение состояния темы при переключении.
                              activeColor: isDarkMode ? Colors.blue : Colors.blueGrey, // Цвет переключателя в зависимости от темы.
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // Пробел между элементами.
                  ElevatedButton(
                    onPressed: () => _showConfirmationDialog(
                      context,
                      title: 'Сброс пароля',
                      content: 'Вы уверены, что хотите сбросить пароль? На ваш email будет отправлена ссылка для сброса пароля.', // Сообщение для диалога подтверждения сброса пароля.
                      onConfirm: () => _resetPassword(context), // Действие при подтверждении.
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.blueGrey : Colors.blue, // Цвет кнопки в зависимости от темы.
                      foregroundColor: Colors.white, // Цвет текста на кнопке.
                      padding: const EdgeInsets.symmetric(vertical: 16), // Отступы внутри кнопки.
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Форма кнопки с закругленными углами.
                      minimumSize: const Size(double.infinity, 50), // Минимальные размеры кнопки.
                    ),
                    child: const Text('Сбросить пароль'), // Текст на кнопке.
                  ),
                  const SizedBox(height: 16), // Пробел между кнопками.
                  ElevatedButton(
                    onPressed: () => _showConfirmationDialog(
                      context,
                      title: 'Выход',
                      content: 'Вы уверены, что хотите выйти из системы?', // Сообщение для диалога подтверждения выхода.
                      onConfirm: () async {
                        await FirebaseAuth.instance.signOut(); // Выполняем выход из системы.
                        Navigator.pushReplacementNamed(context, '/login'); // Переход к экрану входа.
                      },
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Цвет кнопки для выхода.
                      foregroundColor: Colors.white, // Цвет текста на кнопке.
                      padding: const EdgeInsets.symmetric(vertical: 16), // Отступы внутри кнопки.
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Форма кнопки с закругленными углами.
                      minimumSize: const Size(double.infinity, 50), // Минимальные размеры кнопки.
                    ),
                    child: const Text('Выйти'), // Текст на кнопке.
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Метод для создания строки с информацией о пользователе
  Widget _buildUserInfoRow(IconData icon, String label, String? value, Color textColor) {
    return Row( // Создаем строку с иконкой и текстом.
      children: [
        Icon(icon, color: textColor), // Иконка, связанная с информацией (например, email или имя).
        const SizedBox(width: 16), // Пробел между иконкой и текстом.
        Expanded(
          child: Column( // Создаем колонку для текста с меткой и значением.
            crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание элементов по левому краю.
            children: [
              Text(
                label, // Название информации (например, Email).
                style: const TextStyle(fontSize: 14, color: Colors.grey), // Стиль текста для метки.
              ),
              const SizedBox(height: 4), // Пробел между меткой и значением.
              Text(
                value ?? 'Не указано', // Значение информации (или сообщение, если значение не указано).
                style: TextStyle(fontSize: 18, color: textColor), // Стиль текста для значения.
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart'; // Импортируем библиотеку для работы с Firebase Authentication.
import 'package:cloud_firestore/cloud_firestore.dart'; // Импортируем библиотеку для работы с Firestore (база данных).
import 'package:flutter/material.dart'; // Импортируем библиотеку Flutter для работы с пользовательским интерфейсом.

// Общая роль кода:
// Этот код определяет класс AuthService, который управляет аутентификацией пользователя с помощью Firebase Authentication.
// Он предоставляет методы для входа, регистрации, проверки подтверждения email, повторной отправки письма подтверждения и выхода из системы.
// Основные компоненты включают:
// - Метод signIn: Пытается войти в систему с указанными email и паролем и обрабатывает возможные ошибки аутентификации.
// - Метод signUp: Регистрирует нового пользователя, отправляет письмо для подтверждения email и сохраняет имя и фамилию пользователя в Firestore.
// - Метод isEmailVerified: Проверяет, подтвержден ли email текущего пользователя.
// - Метод resendVerificationEmail: Отправляет письмо для подтверждения email повторно, если оно еще не подтверждено.
// - Метод signOut: Выходит из системы, разрывая сессию текущего пользователя.
// Этот сервис можно использовать в приложении для управления пользовательскими данными и аутентификацией.



class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Создаем экземпляр FirebaseAuth для работы с аутентификацией.

  // Метод для входа пользователя по email и паролю.
  Future<void> signIn(String email, String password) async {
    try {
      // Пытаемся войти в систему с помощью email и пароля.
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Если произошла ошибка аутентификации, перехватываем ее и обрабатываем.
      if (e.code == 'wrong-password') {
        throw Exception('Неверный пароль'); // Если ошибка в пароле, выбрасываем исключение с соответствующим сообщением.
      } else if (e.code == 'user-not-found') {
        throw Exception('Пользователь с таким email не найден'); // Если пользователь не найден, выбрасываем исключение с соответствующим сообщением.
      } else {
        throw Exception('Ошибка входа: ${e.message}'); // Для всех других ошибок выводим сообщение об ошибке.
      }
    }
  }

  // Метод для регистрации нового пользователя с email, паролем, именем и фамилией.
  Future<void> signUp(String email, String password, String firstName, String lastName) async {
    try {
      // Пытаемся создать нового пользователя с помощью email и пароля.
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Отправляем пользователю письмо для подтверждения email.
      await userCredential.user!.sendEmailVerification();

      // Сохраняем имя и фамилию пользователя в базе данных Firestore.
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'first_name': firstName,
        'last_name': lastName,
      });
    } on FirebaseAuthException catch (e) {
      // Если произошла ошибка аутентификации, перехватываем ее и обрабатываем.
      if (e.code == 'weak-password') {
        throw Exception('Слишком слабый пароль'); // Если пароль слишком слабый, выбрасываем исключение с соответствующим сообщением.
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Пользователь с таким email уже существует'); // Если email уже используется, выбрасываем исключение с соответствующим сообщением.
      } else {
        throw Exception('Ошибка регистрации: ${e.message}'); // Для всех других ошибок выводим сообщение об ошибке.
      }
    }
  }

  // Метод для проверки, подтвержден ли email пользователя.
  bool isEmailVerified() {
    final user = _auth.currentUser; // Получаем текущего пользователя.
    return user?.emailVerified ?? false; // Проверяем, подтвержден ли его email. Если пользователь не существует, возвращаем false.
  }

  // Метод для повторной отправки письма для подтверждения email.
  Future<void> resendVerificationEmail(String email) async {
    final user = _auth.currentUser; // Получаем текущего пользователя.
    if (user != null && !user.emailVerified) {
      // Если пользователь существует и его email еще не подтвержден, отправляем письмо повторно.
      await user.sendEmailVerification();
    } else {
      throw Exception('Пользователь не вошел в систему или email уже подтвержден'); // Если пользователь не вошел в систему или email уже подтвержден, выбрасываем исключение.
    }
  }

  // Метод для выхода пользователя из системы.
  Future<void> signOut() async {
    await _auth.signOut(); // Выполняем выход пользователя из системы.
  }
}

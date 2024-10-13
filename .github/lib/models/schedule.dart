import 'package:cloud_firestore/cloud_firestore.dart'; // Импортируем Firestore для работы с базой данных

//         Общая роль кода:
// Этот код позволяет получать данные о расписании занятий из Firestore
// и создавать на их основе объекты Schedule. Такие объекты можно использовать 
// для отображения информации о расписании в приложении, работы с ними
// (например, для редактирования расписания), и взаимодействия с базой данных Firestore.

// Класс Schedule (Расписание)
class Schedule {
  // Поля для хранения информации о расписании
  final String id;          // Уникальный идентификатор расписания
  final String subject;     // Название предмета
  final String startTime;   // Время начала занятия
  final String endTime;     // Время окончания занятия
  final String day;         // День недели, когда проходит занятие
  final String lessonId;    // Идентификатор урока, связанного с расписанием

  // Конструктор для создания объекта Schedule
  Schedule({
    required this.id,         // Идентификатор расписания, нужен для идентификации записи
    required this.subject,    // Название предмета занятия
    required this.startTime,  // Время начала занятия
    required this.endTime,    // Время окончания занятия
    required this.day,        // День недели, когда проходит занятие
    required this.lessonId,   // Идентификатор урока, связанного с этим расписанием
  });

  // Метод для создания объекта Schedule на основе документа Firestore
  factory Schedule.fromDocument(DocumentSnapshot doc) {
    // Извлекаем данные из документа Firestore в виде карты (Map)
    final data = doc.data() as Map<String, dynamic>;

    // Возвращаем объект Schedule, используя данные из Firestore
    return Schedule(
      id: doc.id, // Идентификатор документа становится идентификатором расписания
      subject: data['subject'] ?? '', // Если поле 'subject' отсутствует, используем пустую строку
      startTime: data['start_time'] ?? '', // Если поле 'start_time' отсутствует, используем пустую строку
      endTime: data['end_time'] ?? '', // Если поле 'end_time' отсутствует, используем пустую строку
      day: data['day'] ?? '', // Если поле 'day' отсутствует, используем пустую строку
      lessonId: data['lesson_id'] ?? '', // Если поле 'lesson_id' отсутствует, используем пустую строку
    );
  }
}

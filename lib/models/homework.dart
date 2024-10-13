import 'package:cloud_firestore/cloud_firestore.dart'; // Импортируем Firestore для работы с базой данных

//         Общая роль кода:
//Этот код позволяет получать данные о домашнем задании из Firestore
// и создавать на их основе объекты Homework. Такие объекты можно использовать
// для отображения информации о домашних заданиях в приложении, работы с ними
// (например, для редактирования или удаления), и взаимодействия с базой данных Firestore.




// Класс Homework (Домашнее задание)
class Homework {
  // Поля класса, которые хранят информацию о домашнем задании
  final String id;          // Уникальный идентификатор домашнего задания
  final String title;       // Название домашнего задания
  final String description; // Описание задания
  final DateTime dueDate;   // Дата и время, до которых нужно выполнить задание
  final String subject;     // Название предмета, к которому относится задание
  final String lessonId;    // Идентификатор урока, связанного с этим заданием

  // Конструктор класса Homework, который требует обязательные параметры для создания объекта
  Homework({
    required this.id,            // Уникальный ID, нужен для идентификации задания в базе данных
    required this.title,         // Название задания
    required this.description,   // Описание задания
    required this.dueDate,       // Дата сдачи задания
    required this.subject,       // Предмет задания
    required this.lessonId,      // ID урока, к которому относится задание
  });

  // Фабричный метод для создания объекта Homework на основе документа из Firestore
  factory Homework.fromDocument(DocumentSnapshot doc) {
    // Извлекаем данные из документа Firestore в виде карты (Map)
    final data = doc.data() as Map<String, dynamic>;

    // Возвращаем объект Homework, используя данные из Firestore
    return Homework(
      id: doc.id, // Идентификатор документа становится идентификатором задания
      title: data['title'] ?? '', // Если поле 'title' отсутствует, используем пустую строку
      description: data['description'] ?? '', // Если поле 'description' отсутствует, используем пустую строку
      dueDate: (data['due_date'] as Timestamp).toDate(), // Преобразуем временную метку Firestore в тип DateTime
      subject: data['subject'] ?? '', // Если поле 'subject' отсутствует, используем пустую строку
      lessonId: data['lesson_id'] ?? '', // Если поле 'lesson_id' отсутствует, используем пустую строку
    );
  }
}

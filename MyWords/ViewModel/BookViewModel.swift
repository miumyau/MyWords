import CoreData
import UIKit
import Foundation
// MARK: - BookViewModel

// ViewModel для управления книгами
class BookViewModel {
    static let shared = BookViewModel() // Singleton для использования общего экземпляра
    
    // Форматтер для дат (день, месяц, год)
    let datebookFormatter: DateFormatter = {
        let bookformatter = DateFormatter()
        bookformatter.dateStyle = .medium
        bookformatter.timeStyle = .none
        bookformatter.dateFormat = "dd.MM.yyyy"
        return bookformatter
    }()
    
    // Форматтер для времени (часы и минуты)
    let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    // Метод для добавления новой книги
    func addBook(name: String, totalWords: Int32, readyWords: Int32, startDate: Date, endDate: Date, coverImage: UIImage?) {
        let viewContext = PersistenceController.shared.container.viewContext
        let newBook = Book(context: viewContext)
        newBook.name = name
        newBook.totalwords = totalWords
        newBook.readywords = readyWords
        newBook.startDate = startDate
        newBook.endDate = endDate
        newBook.allhours = 0
        // Сохранение обложки книги как данных
        if let coverImage = coverImage, let imageData = coverImage.jpegData(compressionQuality: 1.0) {
            newBook.coverImageData = imageData
        }
        // Сохранение контекста
        do {
            try viewContext.save()
            print("Книга успешно сохранена")
        } catch {
            print("Ошибка при сохранении книги: \(error)")
        }
    }
    // Метод для вычисления количества слов в день
    func calculateWordsPerDay(startDate: Date, endDate: Date, totalWords: Int32, readyWords: Int32) -> Int32 {
        let calendar = Calendar.current
        // Проверка, что начальная дата меньше или равна конечной дате
        guard startDate <= endDate else {
            print("Ошибка: начальная дата должна быть меньше или равна конечной дате")
            return 0
        }
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        guard let days = components.day else {
            print("Ошибка: components.day равен nil")
            return 0
        }
        let remainingWords = max(0, Int(totalWords - readyWords))
        let wordsPerDay = Int32(days > 0 ? remainingWords / days : remainingWords)
        
        return wordsPerDay
    }
}
// MARK: - Расширение для модели Book
extension Book {
    // Массив ежедневной статистики, отсортированный по дате
    var dailyStatsArray: [DailyStats] {
        let set = dailystats as? Set<DailyStats> ?? []
        return set.sorted {
            $0.date ?? Date() < $1.date ?? Date()
        }
    }
    // Свойство для получения и установки обложки книги в формате UIImage
    var coverImage: UIImage? {
        get {
            return UIImage(data: self.coverImageData ?? Data())
        }
        set {
            if let image = newValue {
                self.coverImageData = image.jpegData(compressionQuality: 1.0) ?? Data()
            } else {
                self.coverImageData = Data() // Присваиваем пустые данные, если newValue равно nil
            }
        }
    }
    // Метод для добавления новой ежедневной статистики
    func addDailyStats(date: Date, words: Int32, hours: Int32, place: String?, mood: String?, context: NSManagedObjectContext) {
        guard let context = self.managedObjectContext else {
            print("Контекст управляемого объекта не найден.")
            return
        }
        let newStats = DailyStats(context: context)
        newStats.id = UUID()
        newStats.date = date
        newStats.words = words
        newStats.hours = hours
        newStats.place = place
        newStats.mood = mood ?? ""
        newStats.book = self
        self.readywords += words
        self.allhours += hours
        self.alldays = calculateAlldays() ?? 1
        // Сохранение новой ежедневной статистики
        do {
            try context.save()
        } catch {
            print("Не удалось сохранить новую ежедневную статистику: \(error)")
        }
        // Обновление самого продуктивного места, если оно указано
        if let place = place {
            updateMostProductivePlaceIfNeeded(place: place)
        }
        // Обновление самого продуктивного дня
        updateMostProductiveDayIfNeeded(date: date)
        // Обновление слов в день и общего количества слов за сегодня
        updateWordsPerDay()
        updateTotalWordsToday()
    }
    // Метод для обновления самого продуктивного места, если это необходимо
    func updateMostProductivePlaceIfNeeded(place: String) {
        guard let context = self.managedObjectContext else {
            print("Контекст управляемого объекта не найден.")
            return
        }
        // Текущие самые продуктивные место и количество слов
        var currentMostProductivePlace: String?
        var currentMaxWords: Int32 = 0
        let statsArray = self.dailyStatsArray
        // Поиск места с максимальным количеством введенных слов
        for stat in statsArray {
            if let statPlace = stat.place, statPlace == place {
                if stat.words > currentMaxWords {
                    currentMaxWords = stat.words
                    currentMostProductivePlace = statPlace
                }
            }
        }
        // Обновление самого продуктивного места, если это необходимо
        if let currentMostProductivePlace = currentMostProductivePlace {
            self.mostProductivePlace = currentMostProductivePlace
            // Сохранение обновленного самого продуктивного места в CoreData
            do {
                try context.save()
            } catch {
                print("Не удалось сохранить контекст: \(error)")
            }
        }
    }
    // Метод для вычисления слов в день
    func calculateWordsPerDay(startDate: Date, endDate: Date, totalWords: Int32, readyWords: Int32) -> Int32 {
        let calendar = Calendar.current
        // Проверка, что начальная дата меньше или равна конечной дате
        guard startDate <= endDate else {
            print("Ошибка: начальная дата должна быть меньше или равна конечной дате")
            return 0
        }
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        guard let days = components.day else {
            print("Ошибка: components.day равен nil")
            return 0
        }
        let remainingWords = max(0, Int(totalWords - readyWords))
        let wordsPerDay = Int32(days > 0 ? remainingWords / days : remainingWords)
        return wordsPerDay
    }
    // Метод для обновления самого продуктивного дня, если это необходимо
    func updateMostProductiveDayIfNeeded(date: Date) {
        guard let context = self.managedObjectContext else {
            print("Контекст управляемого объекта не найден.")
            return
        }
        // Текущие самые продуктивные дата и количество слов
        var currentMostProductiveDate = Date() // Инициализация значением по умолчанию
        var currentMaxWords: Int32 = 0
        let statsArray = self.dailyStatsArray
        // Поиск дня с максимальным количеством введенных слов
        for stat in statsArray {
            if let statDate = stat.date {
                // Сравнение дат с учетом компонентов даты и времени
                if Calendar.current.isDate(statDate, equalTo: date, toGranularity: .day) {
                    if stat.words > currentMaxWords {
                        currentMaxWords = stat.words
                        currentMostProductiveDate = statDate
                    }
                }
            }
        }
        // Обновление самого продуктивного дня, если это необходимо
        self.mostProductiveDay = currentMostProductiveDate
        // Сохранение обновленного самого продуктивного дня в CoreData
        do {
            try context.save()
        } catch {
            print("Не удалось сохранить контекст: \(error)")
        }
    }
    // Метод для вычисления общего количества дней
    func calculateAlldays() -> Int32? {
        guard let startDate = self.startDate else {
            print("Начальная дата не указана.")
            return nil
        }
        let endDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        if let days = components.day {
            return Int32(days == 0 ? 1 : days)
        } else {
            print("Не удалось вычислить количество дней.")
            return nil
        }
    }
    // Метод для вычисления общего количества слов за сегодня
    func calculateTotalWordsToday() -> Int? {
        guard let context = self.managedObjectContext else {
            print("Контекст управляемого объекта не найден.")
            return nil
        }
        // Получение текущей даты
        let currentDate = Calendar.current.startOfDay(for: Date())
        // Создание запроса выборки для DailyStats
        let fetchRequest: NSFetchRequest<DailyStats> = DailyStats.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@", currentDate as NSDate)
        do {
            // Получение соответствующей ежедневной статистики
            let statsForToday = try context.fetch(fetchRequest)
            // Вычисление общего количества слов за сегодня
            let totalWordsToday = statsForToday.reduce(0) { $0 + Int($1.words) }
            return totalWordsToday
        } catch {
            print("Не удалось получить ежедневную статистику за сегодня: \(error)")
            return nil
        }
    }
    // Метод для обновления количества слов в день
    func updateWordsPerDay() {
        guard let context = self.managedObjectContext else {
            print("Контекст управляемого объекта не найден.")
            return
        }
        let wordsPerDay = calculateWordsPerDay(startDate: self.startDate ?? Date(), endDate: Date(), totalWords: self.totalwords, readyWords: self.readywords)
        self.wordsperday = wordsPerDay
        // Сохранение обновленного количества слов в день в CoreData
        do {
            try context.save()
        } catch {
            print("Не удалось сохранить контекст при обновлении количества слов в день: \(error)")
        }
    }
    // Метод для обновления общего количества слов за сегодня
    func updateTotalWordsToday() {
        if let totalWordsToday = calculateTotalWordsToday() {
            self.wordstoday = Int32(totalWordsToday)
            do {
                try self.managedObjectContext?.save()
            } catch {
                print("Не удалось сохранить контекст при обновлении общего количества слов за сегодня: \(error)")
            }
        }
    }
}

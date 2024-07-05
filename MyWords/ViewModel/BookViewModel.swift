import CoreData
import UIKit
import Foundation
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
        
        if let coverImage = coverImage, let imageData = coverImage.jpegData(compressionQuality: 1.0) {
            newBook.coverImageData = imageData
        }
        
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

extension Book {
    var dailyStatsArray: [DailyStats] {
        let set = dailystats as? Set<DailyStats> ?? []
        return set.sorted {
            $0.date ?? Date() < $1.date ?? Date()
        }
    }
    
    var coverImage: UIImage? {
        get {
            return UIImage(data: self.coverImageData ?? Data())
        }
        set {
            if let image = newValue {
                self.coverImageData = image.jpegData(compressionQuality: 1.0) ?? Data()
            } else {
                self.coverImageData = Data()
            }
        }
    }
    
    func calculateTargetDate() -> Date? {
        guard let startDate = self.startDate else {
            print("Start date is nil")
            return nil
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Вычисляем компоненты дней между startDate и currentDate
        let components = calendar.dateComponents([.day], from: startDate, to: currentDate)
        
        // Получаем количество дней прошедших с startDate
        let daysPassed = components.day ?? 0
        
        // Гарантируем, что daysPassed как минимум 1, если startDate совпадает с currentDate
        let effectiveDaysPassed = max(daysPassed, 1)
        
        let readyWords = self.readywords
        let totalWords = self.totalwords
        
        guard totalWords > 0 else {
            print("Total words is not greater than 0")
            return nil
        }
        
        let averageWordsPerDay = Double(readyWords) / Double(effectiveDaysPassed)
        guard averageWordsPerDay > 0 else {
            print("Average words per day is not greater than 0")
            return nil
        }
        
        let remainingWords = totalWords - readyWords
        let remainingDays = Int(ceil(Double(remainingWords) / averageWordsPerDay))
        
        guard remainingDays > 0 else {
            print("Remaining days is not greater than 0")
            return nil
        }
        
        let targetDate = calendar.date(byAdding: .day, value: remainingDays, to: currentDate)
        
        if let targetDate = targetDate {
            print("Calculated target date: \(targetDate)")
        } else {
            print("Target date calculation failed")
        }
        
        return targetDate
    }
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
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastStatsDate = self.dailyStatsArray.last?.date ?? Date.distantPast
        
        if !calendar.isDate(lastStatsDate, inSameDayAs: today) {
            self.wordstoday = 0
        }
        
        self.readywords += words
        self.allhours += hours
        self.alldays = calculateAlldays() ?? 1
        
        do {
            try context.save()
            print("Новая ежедневная статистика успешно сохранена")
        } catch {
            print("Не удалось сохранить новую ежедневную статистику: \(error)")
        }
        
        if let place = place {
            updateMostProductivePlaceIfNeeded(place: place)
        }
        updateMostProductiveDayIfNeeded(date: date)
        updateWordsPerDay()
        updateTotalWordsToday()
    }
    
    func updateMostProductivePlaceIfNeeded(place: String) {
        guard let context = self.managedObjectContext else {
            print("Контекст управляемого объекта не найден.")
            return
        }
        var currentMostProductivePlace: String?
        var currentMaxWords: Int32 = 0
        let statsArray = self.dailyStatsArray
        for stat in statsArray {
            if let statPlace = stat.place, statPlace == place {
                if stat.words > currentMaxWords {
                    currentMaxWords = stat.words
                    currentMostProductivePlace = statPlace
                }
            }
        }
        if let currentMostProductivePlace = currentMostProductivePlace {
            self.mostProductivePlace = currentMostProductivePlace
            do {
                try context.save()
            } catch {
                print("Не удалось сохранить контекст: \(error)")
            }
        }
    }
    
    func calculateWordsPerDay(startDate: Date, endDate: Date, totalWords: Int32, readyWords: Int32) -> Int32 {
        let calendar = Calendar.current
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
    
    func updateMostProductiveDayIfNeeded(date: Date) {
        guard let context = self.managedObjectContext else {
            print("Контекст управляемого объекта не найден.")
            return
        }
        var currentMostProductiveDate = Date()
        var currentMaxWords: Int32 = 0
        let statsArray = self.dailyStatsArray
        for stat in statsArray {
            if let statDate = stat.date {
                if Calendar.current.isDate(statDate, equalTo: date, toGranularity: .day) {
                    if stat.words > currentMaxWords {
                        currentMaxWords = stat.words
                        currentMostProductiveDate = statDate
                    }
                }
            }
        }
        self.mostProductiveDay = currentMostProductiveDate
        do {
            try context.save()
        } catch {
            print("Не удалось сохранить контекст: \(error)")
        }
    }
    
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
    
    func calculateTotalWordsToday() -> Int? {
        guard let context = self.managedObjectContext else {
            print("Контекст управляемого объекта не найден.")
            return nil
        }
        let currentDate = Calendar.current.startOfDay(for: Date())
        let fetchRequest: NSFetchRequest<DailyStats> = DailyStats.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@", currentDate as NSDate)
        do {
            let statsForToday = try context.fetch(fetchRequest)
            let totalWordsToday = statsForToday.reduce(0) { $0 + Int($1.words) }
            return totalWordsToday
        } catch {
            print("Не удалось получить ежедневную статистику за сегодня: \(error)")
            return nil
        }
    }
    
    func updateWordsPerDay() {
        guard let context = self.managedObjectContext else {
            print("Контекст управляемого объекта не найден.")
            return
        }
        let wordsPerDay = calculateWordsPerDay(startDate: self.startDate ?? Date(), endDate: Date(), totalWords: self.totalwords, readyWords: self.readywords)
        self.wordsperday = wordsPerDay
        do {
            try context.save()
        } catch {
            print("Не удалось сохранить контекст при обновлении количества слов в день: \(error)")
        }
    }
    
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

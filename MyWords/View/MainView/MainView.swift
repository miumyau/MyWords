import SwiftUI
import CoreData
import UserNotifications
// MARK: - MainView
struct MainView: View {
    // MARK: - Environment Variables
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Book.name, ascending: true)], animation: .default)
    private var books: FetchedResults<Book>
    // MARK: - State Variables
    @State private var isDatePickerVisible = false
    @State private var newBook: Book? = nil
    @State private var selectedTime = Date()
    @State private var isNotificationEnabled = false {
        didSet {
            if isNotificationEnabled {
                scheduleNotification() // Планировать уведомление при включении
            } else {
                removeNotification() // Удалить уведомление при отключении
            }
        }
    }
    @State private var showNotificationPopover = false
    @State private var showNewBookPopover = false
    @State private var newBookCover: UIImage? = nil
    @State private var newBookName = ""
    @State private var newBookTotalWords: Int32 = 0
    @State private var newBookReadyWords: Int32 = 0
    @State private var isStartDatePickerVisible = false
    @State private var isEndDatePickerVisible = false
    @State private var newBookStartDate = Date()
    @State private var newBookEndDate = Date()
    @State private var showImagePicker = false
    //Очистка полей
    private func resetNewBookFields() {
        newBookName = "Новая книга"
        newBookTotalWords = 0
        newBookReadyWords = 0
        newBookCover = nil
        newBookEndDate = Date()
        newBookStartDate = Date()
    }
    // MARK: - Initializer
    init() {
        let defaultTime = Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date())!
        let savedTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date ?? defaultTime
        _selectedTime = State(initialValue: savedTime)
        _isNotificationEnabled = State(initialValue: UserDefaults.standard.bool(forKey: "isNotificationEnabled"))
    }
    // MARK: - Body
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    
                    List {ForEach(books, id: \.self) { book in
                        NavigationLink(destination: BookView(book: book)) {
                            BookRow(book: book)
                                .listRowInsets(EdgeInsets())
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                        }
                    }
                    .onDelete(perform: deleteBooks)
                    }
                    .listStyle(PlainListStyle())
                    .listRowSeparator(.hidden)
                    //Кнопка добавления новой книги
                    Button(action: {
                        resetNewBookFields()
                        showNewBookPopover.toggle()                    }) {
                            Text("Новая книга")
                                .font(.custom("MontserratAlternates-Regular", size: 20))
                                .padding()
                                .frame(width: 250.0, height: 60.0)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        .padding()
                        .frame(height: 50.0)
                }
                //Кнопка для открытия экрана управления уведомлениями
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showNotificationPopover.toggle()
                        }) {
                            Image(systemName: "bell.fill")
                                .resizable() // Позволяет изображению изменять размер
                                .frame(width: 30, height: 35) // Устанавливаем размер изображения
                                .foregroundColor(.black) // Устанавливаем черный цвет
                        }
                    }
                }
            }
            //Окно добавления книги
            if showNewBookPopover {
                NewBookPopover(showNewBookPopover: $showNewBookPopover, newBookName: $newBookName, newBookTotalWords: $newBookTotalWords, newBookReadyWords: $newBookReadyWords, newBookCover: $newBookCover, newBookStartDate: $newBookStartDate, newBookEndDate: $newBookEndDate, showImagePicker: $showImagePicker)
                    .onTapGesture {
                        showNewBookPopover = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            }
            //Окно уведомлений
            if showNotificationPopover {
                NotificationPopover(showPopover: $showNotificationPopover, isNotificationEnabled: $isNotificationEnabled, selectedTime: $selectedTime, isDatePickerVisible: $isDatePickerVisible)
                    .onTapGesture {
                        showNotificationPopover = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            }
        }
        .onAppear {
            requestNotificationPermission()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $newBookCover)
        }
    }
    //Добавление книги
    private func addBook() {
        // Call the BookManager shared instance to add a new book
        BookViewModel.shared.addBook(name: newBookName, totalWords: newBookTotalWords, readyWords: newBookReadyWords, startDate: newBookStartDate, endDate: newBookEndDate, coverImage: newBookCover)
        showNewBookPopover = false
    }
    private func calculateWordsPerDay(startDate: Date, endDate: Date, totalWords: Int32, readyWords: Int32) -> Int {
        return Int(BookViewModel.shared.calculateWordsPerDay(startDate: startDate, endDate: endDate, totalWords: totalWords, readyWords: readyWords))
    }
    //Удаление книги
    private func deleteBooks(offsets: IndexSet) {
        withAnimation {
            offsets.map { books[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                
            }
        }
    }
    // Запрос разрешений на отправку уведомлений
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
        }
    }
    // Планирование уведомлений
    private func scheduleNotification() {
        removeNotification()
        let content = UNMutableNotificationContent()
        content.title = "Ежедневная норма слов ждет⏰ "
        content.body = "Самое время вернуться к тексту!"
        content.sound = .default
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        dateComponents.second = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "DailyNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
        
        UserDefaults.standard.set(selectedTime, forKey: "notificationTime")
        UserDefaults.standard.set(isNotificationEnabled, forKey: "isNotificationEnabled")
    }
    // Удаление уведомлений
    private func removeNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["DailyNotification"])
    }
}
//ImagePicker для обложки
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
//Кастомная ячейка
struct BookRow: View {
    @ObservedObject var book: Book
    @State private var showImagePicker = false
    @State private var bookCover: UIImage?
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    VStack {
                        if book.wordstoday >= book.calculateWordsPerDay(startDate: book.startDate ?? Date(), endDate: book.endDate ?? Date(), totalWords: book.totalwords, readyWords: book.readywords) {
                            Image("AllWordsReady")
                                .resizable()
                                .frame(width: 43, height: 40)
                                .padding(.leading, -20)
                        } else {
                            Image("NotReady")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding(.leading, -20)
                        }
                        Text("\(book.wordstoday)/\(book.calculateWordsPerDay(startDate: book.startDate ?? Date(), endDate: book.endDate ?? Date(), totalWords: book.totalwords, readyWords: book.readywords))")
                            .foregroundColor(Color.white)
                            .font(.custom("MontserratAlternates-Regular", size: 8))
                            .frame(width: 60)
                            .padding(.leading, -15)
                            .multilineTextAlignment(.center)
                    }
                    Text(book.name ?? "Неизвестно")
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .foregroundColor(Color.white)
                }
                HStack {
                    Spacer()
                    Text("\(book.totalwords - book.readywords) слов\nосталось")
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .font(.custom("MontserratAlternates-Regular", size: 14))
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text("\(percentageCompleted(book))%")
                        .foregroundColor(.white)
                        .font(.custom("MontserratAlternates-Regular", size: 14))
                    Spacer()
                }
                HStack {
                    Spacer()
                    ProgressView(value: Double(book.readywords) / Double(book.totalwords), total: 1)
                        .progressViewStyle(LinearProgressViewStyle())
                        .accentColor(.white)
                        .frame(height: 8)
                    Spacer()
                }
            }
            .padding(.leading, 10)
            Spacer()
            VStack {
                Spacer()
                if let image = book.coverImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaledToFill()
                        .frame(width: 80, height: 110)
                        .background(Color.white)
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 80, height: 110)
                        .cornerRadius(8)
                        .onTapGesture {
                            showImagePicker = true
                        }
                }
                Spacer()
            }
        }
        .padding()
        .background(Color.black)
        .cornerRadius(25)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $bookCover)
                .onDisappear {
                    if let bookCover = bookCover {
                        book.coverImage = bookCover
                        try? book.managedObjectContext?.save()
                    }
                }
        }
    }
}
// MARK: - Helper Functions
//Расчет процента готовности
private func percentageCompleted(_ book: Book) -> String {
    guard book.totalwords != 0 else { return "0" } // Проверка деления на ноль
    let percentage = Double(book.readywords) / Double(book.totalwords) * 100
    if percentage.isNaN || percentage.isInfinite {
        return "0"
    } else {
        return "\(Int(percentage))"
    }
}
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


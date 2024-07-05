import SwiftUI
import CoreData
struct BookView: View {
    // MARK: - Properties
    @ObservedObject var book: Book // Наблюдаемый объект класса Book
    @Environment(\.presentationMode) var presentationMode // Режим отображения
    @State private var showAddStats = false // Показывать ли окно статистики
    @State private var showAddWordsPopover = false // Показывать ли всплывающее окно добавления слов
    @Environment(\.managedObjectContext) private var viewContext // Контекст управляемых объектов CoreData
    @State private var date = Date() // Текущая дата
    @State private var words: String = "" // Введенное количество слов
    @State private var hours: String = "" // Введенное количество часов
    @State private var place: String = "" // Введенное место работы
    @State private var mood: String = "🤩" // Выбранное настроение по умолчанию
    @State private var showEmojiSelection = false // Показывать ли меню выбора эмодзи
    // MARK: - Functions
    // Сброс всех полей статистики в начальное состояние
    private func resetStatsFields() {
        words = ""
        place = ""
        hours = ""
        mood = "🤩"
        date = Date()
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            VStack {
                // Название книги
                Text(book.name ?? "Неизвестно")
                    .font(.custom("MontserratAlternates-Regular", size: 31))
                    .padding()
                    .foregroundColor(.white)
                // Шкала прогресса
                HStack {
                    Spacer()
                    ProgressView(value: Double(book.readywords) / Double(book.totalwords), total: 1)
                        .progressViewStyle(LinearProgressViewStyle())
                        .accentColor(.white)
                        .frame(height: 12)
                        .padding(.horizontal, 20)
                    Spacer()
                }
                // Текущее количество слов
                HStack {
                    Spacer()
                    Text("\(book.readywords)/\(book.totalwords)")
                        .padding()
                        .foregroundColor(.white)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                Spacer()
                // Полное время работы над книгой
                HStack {
                    Text("Часов за текстом")
                        .padding()
                        .foregroundColor(.white)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(book.allhours)")
                        .padding()
                        .foregroundColor(.white)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .frame(alignment: .trailing)
                }
                // Среднее количество слов в день
                HStack {
                    Text("В среднем слов в день")
                        .padding()
                        .foregroundColor(.white)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if book.alldays != 0 {
                        let averageWordsPerDay = book.readywords / book.alldays
                        Text("\(averageWordsPerDay)")
                            .padding()
                            .foregroundColor(.white)
                            .font(.custom("MontserratAlternates-Regular", size: 16))
                            .frame(alignment: .trailing)
                    } else {
                        Text("0")
                            .padding()
                            .foregroundColor(.white)
                            .font(.custom("MontserratAlternates-Regular", size: 16))
                            .frame(alignment: .trailing)
                    }
                }
                // Самый продуктивный день
                HStack {
                    Text("Самый продуктивный\nдень")
                        .padding()
                        .foregroundColor(.white)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(book.mostProductiveDay ?? Date(), formatter: BookViewModel.shared.datebookFormatter)")
                        .padding()
                        .foregroundColor(.white)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .frame(alignment: .trailing)
                }
                // Самое продуктивное место
                HStack {
                    Text("Самое продуктивное\nместо")
                        .padding()
                        .foregroundColor(.white)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(book.mostProductivePlace ?? "")")
                        .padding()
                        .foregroundColor(.white)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .frame(alignment: .trailing)
                }
                // Предполагаемая дата завершения
                Text("С такой скоростью \n вы закончите к ")
                    .padding()
                    .foregroundColor(.white)
                    .font(.custom("MontserratAlternates-Regular", size: 20))
                    .multilineTextAlignment(.center)
                
                if let targetDate = book.calculateTargetDate() {
                    let endDate = book.endDate
                    Text("\(targetDate, formatter: BookViewModel.shared.datebookFormatter)")
                        .padding()
                        .foregroundColor(targetDate <= endDate! ? .green1 : .red1)
                        .font(.custom("MontserratAlternates-Regular", size: 22))
                } else {
                    Text("Невозможно рассчитать")
                        .padding()
                        .foregroundColor(.red)
                        .font(.custom("MontserratAlternates-Regular", size: 22))
                }
                Spacer()
                // Кнопка добавления слов
                Button(action: {
                    showAddWordsPopover.toggle()
                }) {
                    Text("Добавить слова")
                        .font(.custom("MontserratAlternates-Regular", size: 20))
                        .padding()
                        .frame(width: 250.0, height: 60.0)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
                // Переход на экран статистики
                NavigationLink(destination: StatisticsView(book: book).environment(\.managedObjectContext, viewContext)) {
                    Text("История")
                        .font(.custom("MontserratAlternates-Regular", size: 20))
                        .padding()
                        .frame(width: 250.0, height: 60.0)
                        .background(Color.clear)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(height: 50.0)
                .fullScreenCover(isPresented: $showAddStats) {
                    StatisticsView(book: book)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                    Text("") // Пустой текст убирает надпись "Back"
                }
            })
            .background(Color.black)
            // Всплывающее окно добавления слов
            if showAddWordsPopover {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showAddWordsPopover = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                AddWordsPopover(book: book, showAddWordsPopover: $showAddWordsPopover)
                    .frame(width: 380, height: 380)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(radius: 10)
            }
        }
    }
}


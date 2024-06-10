import Foundation
import SwiftUI
// MARK: - NewBookPopover
struct NewBookPopover: View {
    // Состояния для управления данными новой книги и состоянием всплывающего окна
    @State private var newBook: Book? = nil
    @Binding var showNewBookPopover: Bool // Показывать ли всплывающее окно новой книги
    @Binding var newBookName: String // Название новой книги
    @Binding var newBookTotalWords: Int32 // Общее количество слов в новой книге
    @Binding var newBookReadyWords: Int32 // Количество уже написанных слов
    @Binding var newBookCover: UIImage? // Обложка новой книги
    @Binding var newBookStartDate: Date // Дата начала новой книги
    @Binding var newBookEndDate: Date // Дата окончания новой книги
    @Binding var showImagePicker: Bool // Показывать ли выбор изображения для обложки
    @State private var isStartDatePickerVisible = false // Видимость DatePicker для даты начала
    @State private var isEndDatePickerVisible = false // Видимость DatePicker для даты окончания
    var body: some View {
        VStack {
            VStack {
                // Отображение обложки книги (если есть) или заглушки
                if let image = newBookCover {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 150)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .onTapGesture {
                            showImagePicker.toggle()
                        }
                } else {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 100, height: 150)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .onTapGesture {
                            showImagePicker.toggle()
                        }
                }
                // Поле для ввода названия новой книги
                TextField("Новая книга", text: $newBookName)
                    .font(.custom("MontserratAlternates-Regular", size: 24))
                    .padding()
                    .background(Color.clear)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(maxWidth: 250)
                // Выбор даты начала новой книги с использованием DatePicker
                HStack {
                    Text("Дата начала")
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        isStartDatePickerVisible.toggle()
                    }) {
                        Text("\(newBookStartDate, formatter: BookViewModel.shared.datebookFormatter)")
                            .font(.custom("MontserratAlternates-Regular", size: 16))
                            .foregroundColor(.white)
                            .padding(.trailing, -15.0)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .sheet(isPresented: $isStartDatePickerVisible) {
                        VStack {
                            DatePicker("Выберите дату начала", selection: $newBookStartDate, displayedComponents: .date)
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                            Button("Готово") {
                                isStartDatePickerVisible.toggle()
                                newBook?.startDate = newBookStartDate
                            }
                            .font(.custom("MontserratAlternates-Regular", size: 20))
                            .foregroundColor(.black)
                            .padding()
                        }
                    }
                }
                .padding(.horizontal)
                // Выбор даты окончания новой книги с использованием DatePicker
                HStack {
                    Text("Дата окончания")
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button(action: {
                        isEndDatePickerVisible.toggle()
                    }) {
                        Text("\(newBookEndDate, formatter: BookViewModel.shared.datebookFormatter)")
                            .foregroundColor(.white)
                            .padding(.trailing, -15.0)
                            .font(.custom("MontserratAlternates-Regular", size: 16))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .sheet(isPresented: $isEndDatePickerVisible) {
                        VStack {
                            DatePicker("Выберите дату окончания", selection: $newBookEndDate, displayedComponents: .date)
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                            Button("Готово") {
                                isEndDatePickerVisible.toggle()
                                newBook?.endDate = newBookEndDate
                            }
                            .font(.custom("MontserratAlternates-Regular", size: 20))
                            .foregroundColor(.black)
                            .padding()
                        }
                    }
                }
                .padding(.horizontal)
                // Поле для ввода общего количества слов в новой книге
                HStack {
                    Text("Общее количество слов")
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("0", value: $newBookTotalWords, formatter: NumberFormatter(), onCommit: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    })
                    .font(.custom("MontserratAlternates-Regular", size: 16))
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .background(Color.clear)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal)
                // Поле для ввода количества уже написанных слов в новой книге
                HStack {
                    Text("Уже написано")
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("0", value: $newBookReadyWords, formatter: NumberFormatter(), onCommit: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    })
                    .font(.custom("MontserratAlternates-Regular", size: 16))
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .background(Color.clear)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal)
                // Вычисление и отображение нормы слов в день для новой книги
                Text("Ваша норма")
                    .foregroundColor(.white)
                    .font(.custom("MontserratAlternates-Regular", size: 18))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                
                let newBookWordsPerDay = calculateWordsPerDay(startDate: newBookStartDate, endDate: newBookEndDate, totalWords: newBookTotalWords, readyWords: newBookReadyWords)
                
                Text("\(newBookWordsPerDay) слов в день")
                    .foregroundColor(.white)
                    .font(.custom("MontserratAlternates-Regular", size: 22))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .background(Color.black)
            .cornerRadius(15)
            .shadow(radius: 10)
            // Кнопки Отмена и Сохранить
            HStack {
                Button(action: {
                    showNewBookPopover = false
                }) {
                    Text("Отмена")
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .padding()
                        .background(Color.red1)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                Button(action: {
                    addBook()
                    showNewBookPopover = false
                }) {
                    Text("Сохранить")
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .padding()
                        .background(Color.green1)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
            }
            .padding(.top)
        }
        .frame(width: 350, height: 670)
        .background(Color.black)
        .cornerRadius(25)
        .shadow(radius: 10)
        .gesture(
            TapGesture().onEnded { _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $newBookCover)
        }
    }
    // Добавление новой книги
    private func addBook() {
        BookViewModel.shared.addBook(name: newBookName, totalWords: newBookTotalWords, readyWords: newBookReadyWords, startDate: newBookStartDate, endDate: newBookEndDate, coverImage: newBookCover)
        showNewBookPopover = false
    }
    // Вычисление нормы слов в день
    private func calculateWordsPerDay(startDate: Date, endDate: Date, totalWords: Int32, readyWords: Int32) -> Int {
        return Int(BookViewModel.shared.calculateWordsPerDay(startDate: startDate, endDate: endDate, totalWords: totalWords, readyWords: readyWords))
    }
}



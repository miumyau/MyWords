import SwiftUI
struct AddWordsPopover: View {
    // MARK: - Properties
    @Binding var showAddWordsPopover: Bool // Показывать ли всплывающее окно добавления слов
    @Binding var words: String // Введенное количество слов
    @Binding var hours: String // Введенное количество часов работы
    @Binding var place: String // Введенное место работы
    @Binding var mood: String // Выбранное настроение
    @State private var showEmojiSelection = false // Показывать ли меню выбора эмодзи
    //MARK: - Functions
    // Очистка полей
    private func resetStatsFields() {
        words = ""
        place = ""
        hours = ""
        mood = "🤩"
    }
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            // Поле ввода количества слов
            TextField("0", text: $words)
                .font(.custom("MontserratAlternates-Regular", size: 16))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text(correctWordsDeclension(for: words))
                .font(.custom("MontserratAlternates-Regular", size: 16))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            // Поле ввода времени работы
            HStack {
                Text("Время работы")
                    .font(.custom("MontserratAlternates-Regular", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 20)
                    .frame(width: 120, alignment: .leading)
                Spacer()
                HStack {
                    TextField("0", text: $hours)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 30)
                    Text(correctHoursDeclension(for: Int(hours) ?? 0))
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.trailing)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 35)
            }
            // Поле ввода места работы
            HStack {
                Text("Место работы")
                    .font(.custom("MontserratAlternates-Regular", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 20)
                    .frame(width: 120, alignment: .leading)
                Spacer()
                TextField("где-то", text: $place)
                    .font(.custom("MontserratAlternates-Regular", size: 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
            }
            .padding(.trailing, 20)
            // Кнопка выбора настроения
            HStack {
                Text("Настрой")
                    .font(.custom("MontserratAlternates-Regular", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 20)
                    .frame(width: 120, alignment: .leading)
                Spacer()
                Button(action: {
                    showEmojiSelection = true
                }) {
                    Text(mood)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.white)
                }
                .actionSheet(isPresented: $showEmojiSelection) {
                    ActionSheet(title: Text("Настрой"), buttons: [
                        .default(Text("🤩")) { mood = "🤩" },
                        .default(Text("😌")) { mood = "😌" },
                        .default(Text("😎")) { mood = "😎" },
                        .default(Text("😱")) { mood = "😱" },
                        .default(Text("😠")) { mood = "😠" },
                        .cancel(Text("Отмена"))
                    ])
                }
            }
            .padding(.trailing, 40)
            // Кнопки Отмена и Сохранить
            HStack {
                Button(action: {
                    resetStatsFields()
                    showAddWordsPopover = false
                }) {
                    Text("Отмена")
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .padding()
                        .background(Color.red1)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                Spacer()
                Button(action: {
                    // Вызов функции сохранения данных
                    resetStatsFields()
                    showAddWordsPopover = false
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
            .padding(.horizontal, 50)
        }
        .frame(width: 380, height: 380)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 10)
    }
}





import SwiftUI
// MARK: - StatisticsView
struct StatisticsView: View {
    @ObservedObject var book: Book // Наблюдаемый объект класса Book для отображения статистики
    @Environment(\.managedObjectContext) private var viewContext // Контекст управляемых объектов CoreData
    @Environment(\.presentationMode) var presentationMode // Режим отображения
    var body: some View {
        VStack {
            List {
                ForEach(book.dailyStatsArray, id: \.id) { stat in
                    CustomCellView(stat: stat)
                        .padding(.vertical, 5)
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                Text("") // Пустой текст убирает надпись "Back"
            }
        })
        .background(Color.white)
    }
}
// MARK: - CustomCellView
struct CustomCellView: View {
    var stat: DailyStats // Статистика за один день
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                // Дата в формате "день.месяц.год"
                Text("\(stat.date ?? Date(), formatter: BookViewModel.shared.datebookFormatter)")
                    .foregroundColor(.white)
                    .font(.custom("MontserratAlternates-Regular", size: 16))
                Spacer()
                // Детали статистики: количество слов, часов, место и настроение
                HStack {
                    Text("\(stat.words) слов")
                        .foregroundColor(.white)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                    Spacer()
                    Text("\(stat.hours) \(correctHoursDeclension(for: Int(stat.hours)))")
                        .foregroundColor(.white)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                    Spacer()
                    Text(stat.place ?? "где-то")
                        .foregroundColor(.white)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                    Spacer()
                    Text(stat.mood ?? "")
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                }
            }
            .padding()
            .background(Color.black)
            .cornerRadius(25)
        }
        .padding(.horizontal)
    }
}



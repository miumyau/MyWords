import SwiftUI
// MARK: - NotificationPopover
struct NotificationPopover: View {
    // Привязки для управления состоянием из родительского представления
    @Binding var showPopover: Bool // Показывать ли всплывающее окно
    @Binding var isNotificationEnabled: Bool // Включены ли уведомления
    @Binding var selectedTime: Date // Выбранное время отправки уведомления
    @Binding var isDatePickerVisible: Bool // Показывать ли выбор времени
    var body: some View {
        ZStack {
            VStack {
                // Верхняя часть всплывающего окна с названием и переключателем уведомлений
                HStack {
                    Text("Уведомления")
                        .foregroundColor(Color.white)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading) // Сдвигаем текст влево
                    
                    Toggle("", isOn: $isNotificationEnabled)
                        .labelsHidden()
                        .padding(.trailing, 33.0)
                }
                .padding(.bottom, 10)
                
                // Нижняя часть с выбором времени отправки и кнопкой для открытия DatePicker
                HStack {
                    Text("Время отправки")
                        .foregroundColor(Color.white)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        isDatePickerVisible.toggle() // Переключение видимости DatePicker
                    }) {
                        Text("\(selectedTime, formatter: BookViewModel.shared.hourFormatter)") // Отображение выбранного времени
                            .foregroundColor(.white)
                            .padding(.trailing, 35.0)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
            .frame(width: 370, height: 230)
            .background(Color.black)
            .cornerRadius(25)
            .shadow(radius: 10)
            .offset(y: -35) // Смещение вверх относительно базового расположения
            
            // Всплывающий DatePicker
            if isDatePickerVisible {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isDatePickerVisible = false // Закрытие DatePicker при нажатии вне него
                    }
                
                VStack {
                    Spacer()
                    VStack {
                        // DatePicker для выбора времени
                        DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(WheelDatePickerStyle())
                            .padding()
                            .frame(height: 150)
                        
                        // Кнопка "Готово" для сохранения выбранного времени
                        Button(action: {
                            // Сохранение времени в UserDefaults
                            UserDefaults.standard.set(selectedTime, forKey: "notificationTime")
                            // Закрытие DatePicker после сохранения
                            isDatePickerVisible = false
                        }) {
                            Text("Готово")
                                .font(.custom("MontserratAlternates-Regular", size: 16))
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .background(Color.white)
                    }
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .transition(.move(edge: .bottom)) // Анимация появления снизу
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}

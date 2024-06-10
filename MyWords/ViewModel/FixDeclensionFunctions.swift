import Foundation
//функция расчета правильного склонения слова "часы"
func correctHoursDeclension(for hours: Int) -> String {
    let remainder = hours % 10
    let remainder100 = hours % 100
    
    if remainder100 >= 11 && remainder100 <= 19 {
        return "часов"
    } else if remainder == 1 {
        return "час"
    } else if remainder >= 2 && remainder <= 4 {
        return "часа"
    } else {
        return "часов"
    }
} 
//функция расчета правильного склонения слова "слова"
func correctWordsDeclension(for words: String) -> String {
    let number = Int(words) ?? 0
    let remainder = number % 10
    let remainder100 = number % 100
    
    if remainder100 >= 11 && remainder100 <= 19 {
        return "слов"
    } else if remainder == 1 {
        return "слово"
    } else if remainder >= 2 && remainder <= 4 {
        return "слова"
    } else {
        return "слов"
    }
}

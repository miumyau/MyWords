import Foundation
import CoreData
extension DailyStats {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyStats> {
        return NSFetchRequest<DailyStats>(entityName: "DailyStats")
    }
    
    @NSManaged public var date: Date?
    @NSManaged public var hours: Int32
    @NSManaged public var id: UUID?
    @NSManaged public var mood: String?
    @NSManaged public var place: String?
    @NSManaged public var words: Int32
    @NSManaged public var book: Book?
    
}

extension DailyStats : Identifiable {
    
}

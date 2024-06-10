import Foundation
import CoreData
extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var alldays: Int32
    @NSManaged public var allhours: Int32
    @NSManaged public var coverImageData: Data?
    @NSManaged public var endDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var mostProductiveDay: Date?
    @NSManaged public var mostProductivePlace: String?
    @NSManaged public var name: String?
    @NSManaged public var readywords: Int32
    @NSManaged public var startDate: Date?
    @NSManaged public var totaltime: Int32
    @NSManaged public var totalwords: Int32
    @NSManaged public var wordsperday: Int32
    @NSManaged public var wordstoday: Int32
    @NSManaged public var dailystats: NSSet?
}
extension Book {

    @objc(addDailystatsObject:)
    @NSManaged public func addToDailystats(_ value: DailyStats)

    @objc(removeDailystatsObject:)
    @NSManaged public func removeFromDailystats(_ value: DailyStats)

    @objc(addDailystats:)
    @NSManaged public func addToDailystats(_ values: NSSet)

    @objc(removeDailystats:)
    @NSManaged public func removeFromDailystats(_ values: NSSet)

}

extension Book : Identifiable {

}

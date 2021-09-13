//
//  Dresses+CoreDataProperties.swift
//  DressesApp
//
//  Created by Omairys Uzcátegui on 2021-09-12.
//
//

import Foundation
import CoreData


extension Dresses {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dresses> {
        return NSFetchRequest<Dresses>(entityName: "Dresses")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var lastWorn: Date?
    @NSManaged public var name: String?
    @NSManaged public var photoData: Data?
    @NSManaged public var rating: Double
    @NSManaged public var searchKey: String?
    @NSManaged public var tiemesWorn: Int32
    @NSManaged public var tintColor: NSObject?
    @NSManaged public var url: URL?

}

extension Dresses : Identifiable {

}

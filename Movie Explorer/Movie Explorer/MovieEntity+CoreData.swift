//
//  MovieEntity+CoreData.swift
//  Movie Explorer
//
//  Created by Brijesh Ajudia on 09/08/25.
//

import Foundation
import CoreData
import UIKit

@objc(MovieEntity)
public class MovieEntity: NSManagedObject {}

extension MovieEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieEntity> {
        return NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var overview: String?
    @NSManaged public var poster_path: String?
    @NSManaged public var release_date: String?
    @NSManaged public var vote_average: Double
    @NSManaged public var page: Int32
    @NSManaged public var posterData: Data?
}

extension MovieEntity {
    func update(from model: Movie, page: Int32) {
        self.id = Int64(model.id)
        self.title = model.title
        self.overview = model.overview
        self.poster_path = model.poster_path
        self.release_date = model.release_date
        self.vote_average = model.vote_average ?? 0.0
        self.page = page
    }
}


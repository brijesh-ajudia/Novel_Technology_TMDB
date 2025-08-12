//
//  Models.swift
//  Movie Explorer
//
//  Created by Brijesh Ajudia on 09/08/25.
//

import Foundation

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let total_pages: Int
    let total_results: Int
}

struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String?
    let poster_path: String?
    let release_date: String?
    let vote_average: Double?
}

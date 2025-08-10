//
//  Network+MoviesAPI.swift
//  Movie Explorer
//
//  Created by Brijesh Ajudia on 09/08/25.
//

import Foundation
import Moya

enum MoviesAPI {
    case popular(page: Int)
    case search(query: String, page: Int)
}

extension MoviesAPI: TargetType {
    var baseURL: URL { URL(string: Constants.baseURL)! }
    var path: String {
        switch self {
        case .popular: return "/discover/movie"
        case .search: return "/search/movie"
        }
    }
    var method: Moya.Method { .get }
    var task: Task {
        switch self {
        case .popular(let page):
            return .requestParameters(parameters: ["page": page], encoding: URLEncoding.default)
        case .search(let query, let page):
            return .requestParameters(parameters: ["query": query, "page": page], encoding: URLEncoding.default)
        }
    }
    var headers: [String : String]? {
        ["Authorization": "Bearer \(Constants.tmdbBearerToken)", "Accept": "application/json"]
    }
    var sampleData: Data { Data() }
}


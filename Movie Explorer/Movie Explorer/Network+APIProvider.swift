//
//  Network+APIProvider.swift
//  Movie Explorer
//
//  Created by Brijesh Ajudia on 09/08/25.
//

import Moya
import Alamofire

final class APIProvider {
    static let shared = MoyaProvider<MoviesAPI>(plugins: [])
}


//
//  Repositories+MovieRepository.swift
//  Movie Explorer
//
//  Created by Brijesh Ajudia on 09/08/25.
//

import Foundation
import CoreData
import Moya
import SDWebImage

final class MovieRepository {
    private let provider = APIProvider.shared

    // Fetch from network and save to Core Data (background)
    func fetchMovies(page: Int, query: String?, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        
        let target: MoviesAPI = {
            if let q = query, !q.isEmpty {
                return .search(query: q, page: page)
            }
            return .popular(page: page)
        }()
        
        provider.request(target) { result in
            switch result {
            case .success(let response):
                do {
                    let decoder = JSONDecoder()
                    let resp = try decoder.decode(MovieResponse.self, from: response.data)
                    if query == nil || query?.isEmpty == true {
                        let bg = CoreDataStack.shared.newBackgroundContext()
                        bg.perform {
                            for movie in resp.results {
                                // Upsert by movie.id
                                let fetch: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
                                fetch.predicate = NSPredicate(format: "id == %d", movie.id)
                                fetch.fetchLimit = 1
                                
                                let existing = (try? bg.fetch(fetch).first)
                                let entity = existing ?? MovieEntity(context: bg)
                                entity.update(from: movie, page: Int32(resp.page))
                            }
                            
                            do { try bg.save() }
                            catch { print("BG save error: \(error)") }
                        }
                    }
                    
                    completion(.success(resp))
                    
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }

    // Try to ensure posterData exists: download via SDWebImageManager and store data
    func ensurePosterData(for entity: MovieEntity, completion: ((Bool)->Void)? = nil) {
        guard entity.posterData == nil, let path = entity.poster_path else { completion?(false); return }
        guard let url = URL(string: Constants.posterBase + path) else { completion?(false); return }
        // SDWebImageManager can fetch image and give data
        SDWebImageManager.shared.loadImage(
            with: url,
            options: [.highPriority],
            progress: nil) { image, data, error, cacheType, finished, imageURL in
                guard let data = data, finished, error == nil else {
                    completion?(false); return
                }
                let bg = CoreDataStack.shared.newBackgroundContext()
                bg.perform {
                    let fetch: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
                    fetch.predicate = NSPredicate(format: "id == %d", entity.id)
                    fetch.fetchLimit = 1
                    if let e = (try? bg.fetch(fetch).first) {
                        e.posterData = data
                        try? bg.save()
                        completion?(true)
                    } else {
                        completion?(false)
                    }
                }
        }
    }
}


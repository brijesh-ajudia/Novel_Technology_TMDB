//
//  ViewModels+MovieListViewModel.swift
//  Movie Explorer
//
//  Created by Brijesh Ajudia on 09/08/25.
//

import Foundation
import CoreData
import UIKit

protocol MovieListViewModelDelegate: AnyObject {
    func didUpdateContent()
    func didFail(with error: Error)
    func showLoading(_ show: Bool)
    func showFooterLoading(_ show: Bool)
}

final class MovieListViewModel: NSObject {
    private let repository = MovieRepository()
    weak var delegate: MovieListViewModelDelegate?

    private(set) var currentPage = 1
    private(set) var totalPages = 1
    private var query: String?
    
    private var searchResults: [Movie] = []
    private var isSearching: Bool {
           !(query?.isEmpty ?? true)
       }

    // MARK: - NSFetchedResultsController
    private lazy var fetchedResultsController: NSFetchedResultsController<MovieEntity> = {
        let fetch: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        fetch.sortDescriptors = [
            NSSortDescriptor(key: "page", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)
        ]
        let frc = NSFetchedResultsController(
            fetchRequest: fetch,
            managedObjectContext: CoreDataStack.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        return frc
    }()

    override init() {
        super.init()
        try? fetchedResultsController.performFetch()
        
        // Listen for background context saves
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidSave(_:)),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func contextDidSave(_ notification: Notification) {
        // Merge background saves into viewContext
        CoreDataStack.shared.viewContext.mergeChanges(fromContextDidSave: notification)
    }

    // MARK: - Public
    func numberOfItems() -> Int {
        return isSearching ? searchResults.count : (fetchedResultsController.fetchedObjects?.count ?? 0)
    }
    
    func object(at indexPath: IndexPath) -> Any {
        return isSearching ? searchResults[indexPath.item] : fetchedResultsController.object(at: indexPath)
    }

    func refresh(query: String? = nil) {
        self.query = query
        currentPage = 1
        delegate?.showLoading(true)
        
        repository.fetchMovies(page: 1, query: query) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.showLoading(false)
                switch result {
                case .success(let resp):
                    self.currentPage = resp.page
                    self.totalPages = resp.total_pages
                    try? self.fetchedResultsController.performFetch() // ✅ Force update
                case .failure(let err):
                    self.delegate?.didFail(with: err)
                }
            }
        }
    }
    
    func searchMovies(query: String) {
        self.query = query
        if query.isEmpty {
            searchResults.removeAll()
            delegate?.didUpdateContent()
            return
        }
        
        delegate?.showLoading(true)
        repository.fetchMovies(page: 1, query: query) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.showLoading(false)
                switch result {
                case .success(let resp):
                    self.searchResults = resp.results
                    self.delegate?.didUpdateContent()
                case .failure(let err):
                    self.delegate?.didFail(with: err)
                }
            }
        }
    }

    func loadMoreIfNeeded() {
        guard currentPage < totalPages else { return }
        delegate?.showFooterLoading(true)
        
        let next = currentPage + 1
        repository.fetchMovies(page: next, query: query) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.showFooterLoading(false)
                switch result {
                case .success(let resp):
                    self.currentPage = resp.page
                    self.totalPages = resp.total_pages
                    try? self.fetchedResultsController.performFetch() // ✅ Force update
                case .failure(let err):
                    self.delegate?.didFail(with: err)
                }
            }
        }
    }

    func performInitialLoad() {
        refresh(query: query)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension MovieListViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateContent()
    }
}

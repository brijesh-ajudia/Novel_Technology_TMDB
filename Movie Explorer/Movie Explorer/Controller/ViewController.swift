//
//  ViewController.swift
//  Movie Explorer
//
//  Created by Brijesh Ajudia on 09/08/25.
//

import UIKit
import CoreData
import Toast_Swift

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let viewModel = MovieListViewModel()
    private var loadingView: LoadingView?
    private var footerSpinner: UIActivityIndicatorView?
    private var searchTimer: Timer?
    
    private var currentSearchQuery: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        viewModel.delegate = self
        setupCollectionView()
        setupRefresh()
        setupSearchBar()
        
        showLoading(true)
        viewModel.performInitialLoad()
    }
    
    private func setupCollectionView() {
        
        collectionView.register(UINib(nibName: "MovieCVCell", bundle: nil), forCellWithReuseIdentifier: "MovieCVCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        // Register cell nib or storyboard cell
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 8
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        // footer spinner
        footerSpinner = UIActivityIndicatorView(style: .medium)
        footerSpinner?.tintColor = .white
        footerSpinner?.backgroundColor = .clear
        footerSpinner?.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 44)
    }
    
    private func setupRefresh() {
        let rc = UIRefreshControl()
        rc.backgroundColor = .clear
        rc.tintColor = UIColor.white
        rc.addTarget(self, action: #selector(didPullRefresh), for: .valueChanged)
        collectionView.refreshControl = rc
    }
    
    private func setupSearchBar() {
        self.searchBar.delegate = self
    }
    
    @objc private func didPullRefresh() {
        self.collectionView.refreshControl?.beginRefreshing()
        viewModel.refresh(query: nil)
    }
    
    internal func toggleLoading(_ show: Bool) {
        if show {
            loadingView?.hide()
            loadingView = nil
            
            loadingView = LoadingView.instantiate()
            loadingView?.show(in: view)
        } else {
            loadingView?.hide()
            loadingView = nil
        }
    }
    
    func stopTimer() {
        searchTimer?.invalidate()
        searchTimer = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer() // Stop any active search timer when leaving view
    }
}

extension ViewController: MovieListViewModelDelegate {
    func didUpdateContent() {
        collectionView.reloadData()
    }
    
    func didFail(with error: Error) {
        // show toast or alert
        DispatchQueue.main.async {
            self.view.makeToast("Error: \(error.localizedDescription)")
        }
    }
    
    func showLoading(_ show: Bool) {
        self.collectionView.refreshControl?.endRefreshing()
        toggleLoading(show)
    }
    
    func showFooterLoading(_ show: Bool) {
        DispatchQueue.main.async {
            if show {
                self.footerSpinner?.startAnimating()
                self.collectionView.addSubview(self.footerSpinner!)
                let y = self.collectionView.contentSize.height + 8
                self.footerSpinner?.frame.origin = CGPoint(x: (self.collectionView.bounds.width - 20)/2, y: y)
            } else {
                self.footerSpinner?.stopAnimating()
                self.footerSpinner?.removeFromSuperview()
            }
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate() // Cancel previous timer
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If search cleared, reset to popular movies
        if trimmed.isEmpty {
            currentSearchQuery = nil
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.viewModel.refresh(query: nil)
            }
            return
        }
        
        // Set debounce timer for search
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { [weak self] _ in
            self?.currentSearchQuery = trimmed
            self?.viewModel.searchMovies(query: trimmed)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.currentSearchQuery = nil
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }
    
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = cv.dequeueReusableCell(withReuseIdentifier: "MovieCVCell", for: indexPath) as? MovieCVCell else {
            return UICollectionViewCell()
        }
        
        if ((self.currentSearchQuery?.isEmpty) != nil) {
            let movie = viewModel.object(at: indexPath) as! Movie
            cell.configure(with: movie) // from API struct
        } else {
            let movieEntity = viewModel.object(at: indexPath) as! MovieEntity
            cell.configure(with: movieEntity) // from Core Data entity
        }
        
        return cell
    }
    
    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let obj = viewModel.object(at: indexPath)
        
        var movieEntity: MovieEntity
        
        if let entity = obj as? MovieEntity {
            // Core Data mode
            movieEntity = entity
        } else if let movie = obj as? Movie {
            // Search mode → make temp MovieEntity
            let context = CoreDataStack.shared.viewContext
            let tempEntity = MovieEntity(context: context)
            tempEntity.id = Int64(movie.id)
            tempEntity.title = movie.title
            tempEntity.release_date = movie.release_date
            if let path = movie.poster_path {
                // Download image sync or set nil; detail VC can fetch again if needed
                let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)")
                if let url = url, let data = try? Data(contentsOf: url) {
                    tempEntity.posterData = data
                }
            }
            movieEntity = tempEntity
        } else {
            return
        }
        
        let detailVC = MovieDetailViewController.instantiate(with: movieEntity)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ cv: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 8
        let totalSpacing = spacing * 3 // left + right + between columns
        let width = (cv.bounds.width - totalSpacing) / 2
        let height = width * 1.5 // 2:3 ratio
        return CGSize(width: floor(width), height: ceil(height))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    
    // pagination trigger
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 200 { // near bottom
            viewModel.loadMoreIfNeeded()
        }
    }
}



//
//  MovieDetailViewController.swift
//  Movie Explorer
//
//  Created by Brijesh Ajudia on 09/08/25.
//

import UIKit
import SDWebImage
import CoreData

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movieEntity: MovieEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        configureUI()
    }
    
    private func configureUI() {
        titleLabel.text = movieEntity.title ?? "-"
        yearLabel.text = movieEntity.release_date?.convertDateFormater() ?? "-"
        ratingLabel.text = String(format: "%.1f", movieEntity.vote_average)
        overviewLabel.text = movieEntity.overview ?? "No overview available."
        
        // Poster image
        if let data = movieEntity.posterData, let img = UIImage(data: data) {
            posterImageView.image = img
        } else if let path = movieEntity.poster_path, let url = URL(string: Constants.posterBase + path) {
            posterImageView.sd_setImage(with: url) { [weak self] image, _, _, _ in
                guard let image = image else { return }
                if let data = image.jpegData(compressionQuality: 0.9) {
                    // Save to Core Data
                    let ctx = CoreDataStack.shared.newBackgroundContext()
                    ctx.perform {
                        let fetch: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
                        fetch.predicate = NSPredicate(format: "id == %d", self?.movieEntity.id ?? 0)
                        fetch.fetchLimit = 1
                        if let e = (try? ctx.fetch(fetch).first) {
                            e.posterData = data
                            try? ctx.save()
                        }
                    }
                }
            }
        } else {
            posterImageView.image = UIImage(systemName: "photo")
        }
    }
    
    // Factory method to instantiate with storyboard
    static func instantiate(with entity: MovieEntity) -> MovieDetailViewController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        vc.movieEntity = entity
        return vc
    }
}

// MARK: - Button Actions
extension MovieDetailViewController {
    // Back Button tapped
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
    

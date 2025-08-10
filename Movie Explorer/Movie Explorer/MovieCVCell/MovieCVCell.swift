//
//  MovieCVCell.swift
//  Movie Explorer
//
//  Created by Brijesh Ajudia on 09/08/25.
//

import UIKit
import SDWebImage
import CoreData

class MovieCVCell: UICollectionViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!

    func configure(with entity: MovieEntity) {
        titleLabel.text = entity.title
        yearLabel.text = entity.release_date?.convertDateFormater() ?? "-"
        posterImageView.image = UIImage(systemName: "photo")
        
        // If posterData exists, use it
        if let data = entity.posterData, let img = UIImage(data: data) {
            posterImageView.image = img
        } else if let path = entity.poster_path, let url = URL(string: Constants.posterBase + path) {
            // SDWebImage will cache image; after download save data to CoreData via repository
            posterImageView.sd_setImage(with: url, completed: { [weak self] image, _, _, _ in
                guard let image = image else { return }
                // Save binary in background
                if let data = image.jpegData(compressionQuality: 0.9) {
                    DispatchQueue.global(qos: .background).async {
                        let ctx = CoreDataStack.shared.newBackgroundContext()
                        ctx.perform {
                            let fetch: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
                            fetch.predicate = NSPredicate(format: "id == %d", entity.id)
                            fetch.fetchLimit = 1
                            if let e = (try? ctx.fetch(fetch).first) {
                                e.posterData = data
                                try? ctx.save()
                            }
                        }
                    }
                }
            })
        }
    }
    
    func configure(with entity: Movie) {
        titleLabel.text = entity.title
        yearLabel.text = entity.release_date?.convertDateFormater() ?? "-"
        posterImageView.image = UIImage(systemName: "photo")
        
        // If posterData exists, use it
        if let path = entity.poster_path, let url = URL(string: Constants.posterBase + path) {
            // SDWebImage will cache image; after download save data to CoreData via repository
            posterImageView.sd_setImage(with: url, completed: { [weak self] image, _, _, _ in
                guard let image = image else { return }
                // Save binary in background
                if let data = image.jpegData(compressionQuality: 0.9) {
                    DispatchQueue.global(qos: .background).async {
                        let ctx = CoreDataStack.shared.newBackgroundContext()
                        ctx.perform {
                            let fetch: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
                            fetch.predicate = NSPredicate(format: "id == %d", entity.id)
                            fetch.fetchLimit = 1
                            if let e = (try? ctx.fetch(fetch).first) {
                                e.posterData = data
                                try? ctx.save()
                            }
                        }
                    }
                }
            })
        }
    }

}

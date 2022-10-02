//
//  WalpaperCollectionViewCell.swift
//  MoreThanIG
//
//  Created by Veysal on 18.09.22.
//

import UIKit
import CoreData

class WalpaperCollectionViewCell: UICollectionViewCell {
    static let identifier = "ImageCollectionViewCell"
    private let imageView : UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.cornerRadius = 30
        image.contentMode = .scaleAspectFill
        return image
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
       fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    func configure(with Url: String){
        guard let url = URL(string: Url) else {
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }.resume()
    }
}

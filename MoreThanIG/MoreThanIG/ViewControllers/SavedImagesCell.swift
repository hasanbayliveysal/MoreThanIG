//
//  SavedImagesCell.swift
//  MoreThanIG
//
//  Created by Veysal on 16.09.22.
//

import UIKit

class SavedImagesCell: UITableViewCell {

    @IBOutlet weak var savedImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        savedImage.clipsToBounds = true
        savedImage.layer.cornerRadius = 50
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

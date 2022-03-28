//
//  FavoriteCollectionViewCell.swift
//  NASA-APOD
//
//  Created by Jagadeeshwar Reddy on 28/03/22.
//

import UIKit
protocol FavouriteCollectionViewCellDelegate: AnyObject {
	func didTapDelete(_ cell: FavouriteCollectionViewCell)
}

final class FavouriteCollectionViewCell: UICollectionViewCell {
 
	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var dateLabel: UILabel!
	@IBOutlet private weak var deleteButton: UIButton!
	
	var mainImageView: UIImageView {
		return imageView
	}
	
	weak var delegate: FavouriteCollectionViewCellDelegate?
	
	@IBAction private func didTapDelete(_ sender: Any) {
		delegate?.didTapDelete(self)
	}
	
	func configure(with model: APODModel) {
		titleLabel.text = model.title
		dateLabel.text = appDateFormatter.string(from: model.date)
		imageView.kf.setImage(with: model.url, placeholder: nil, options: nil, progressBlock: { (_, _) in }, completionHandler: { _ in })
	}
	
	var isInEditingMode: Bool = false {
		didSet {
			deleteButton.isHidden = !isInEditingMode
		}
	}

	override var isSelected: Bool {
		didSet {
			if isInEditingMode {
				deleteButton.isHidden = !isInEditingMode
			}
		}
	}
}

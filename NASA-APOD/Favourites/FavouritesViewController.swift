//
//  FavouritesViewController.swift
//  NASA-APOD
//
//  Created by Jagadeeshwar Reddy on 27/03/22.
//

import UIKit
import DZNEmptyDataSet
import SimpleImageViewer

final class FavouritesViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

	private var favouriteModels: [APODModel] = [] {
		didSet {
			collectionView?.reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		collectionView?.emptyDataSetSource = self
		collectionView?.emptyDataSetDelegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadFavourites()
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		collectionView.allowsMultipleSelection = false
		let indexPaths = collectionView.indexPathsForVisibleItems
		for indexPath in indexPaths {
			let cell = collectionView.cellForItem(at: indexPath) as! FavouriteCollectionViewCell
			cell.isInEditingMode = editing
		}
	}

	private func loadFavourites() {
		if let models = APODCache.shared.getFavoriteModels() {
			self.favouriteModels = models.sorted(by: { one, two in
				one.date.timeIntervalSince1970 > two.date.timeIntervalSince1970
			})
		}
		
		if favouriteModels.isEmpty {
			navigationItem.leftBarButtonItem = nil
		} else {
			navigationItem.leftBarButtonItem = editButtonItem
		}

	}
}

extension FavouritesViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return favouriteModels.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavouriteCell", for: indexPath) as! FavouriteCollectionViewCell
		cell.delegate = self
		cell.configure(with: favouriteModels[indexPath.row])
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: (kScreenWidth - 30) / 2.0, height: (kScreenWidth - 30) / 2.0)
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! FavouriteCollectionViewCell
		let configuration = ImageViewerConfiguration { config in
			config.imageView = cell.mainImageView
		}
		
		let imageViewerController = ImageViewerController(configuration: configuration)
		present(imageViewerController, animated: true)
	}
}

extension FavouritesViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
	
	func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		let attributedString = NSAttributedString(string: "No favourites yet",
												  attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title2)])
		return attributedString
	}

	func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		let attributedString = NSAttributedString(string: "Start marking a picture you like the most by tapping on the heart symbol in the home tab.\nYour favourites are saved for offline access.",
												  attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)])
		return attributedString

	}
}

extension FavouritesViewController: FavouriteCollectionViewCellDelegate {
	func didTapDelete(_ cell: FavouriteCollectionViewCell) {
		guard let selectedRow = collectionView.indexPath(for: cell)?.row else { return }
		
		APODCache.shared.removeFavorite(date: favouriteModels[selectedRow].date)
		loadFavourites()
	}
}

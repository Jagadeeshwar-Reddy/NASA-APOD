//
//  HomeViewController.swift
//  NASA-APOD
//
//  Created by Jagadeeshwar Reddy on 27/03/22.
//

import UIKit
import SVProgressHUD
import Kingfisher

final class HomeViewController: UITableViewController {
	@IBOutlet private weak var favoriteBarButtonItem: UIBarButtonItem?
	@IBOutlet private weak var dateBarButtonItem: UIBarButtonItem?
	@IBOutlet private weak var previousDayBarButtonItem: UIBarButtonItem?
	@IBOutlet private weak var nextDayBarButtonItem: UIBarButtonItem?

	@IBOutlet private weak var apodImageView: UIImageView?
	@IBOutlet private weak var titleLabel: UILabel?
	@IBOutlet private weak var explanationLabel: UILabel?
	@IBOutlet private weak var copyrightLabel: UILabel?

	private var presenter: APODPresenterType = APODPresenter()
	private var imageViewHeight: CGFloat = 100.0
	private var currentDate: Date = Date.now
	
    override func viewDidLoad() {
        super.viewDidLoad()

		presenter.view = self
		presenter.loadAPOD(for: currentDate)
    }
	
	@IBAction func didTapAddToFavourites(_ sender: Any) {
		let isAlreadyFavourite = presenter.isAPODFavourited(for: currentDate)
		isAlreadyFavourite ? presenter.removeFromFavourite(date: currentDate) : presenter.addToFavourite(date: currentDate)
		favoriteBarButtonItem?.image = UIImage(systemName: isAlreadyFavourite ? "heart" : "heart.fill")!
	}
	
	@IBAction func didTapSearch(_ sender: Any) {
		let apodDatePicker: UIDatePicker = {
			let datePicker = UIDatePicker(frame: CGRect(x: 0,
														y: 25,
														width: isiPad ? 320 : kScreenWidth,
														height: isiPad ? 200 : 250))
			datePicker.datePickerMode = .date
			datePicker.preferredDatePickerStyle = .wheels
			datePicker.maximumDate = Date.now
			datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())! // -10 years
			return datePicker
		}()
		
		let alertVC = UIAlertController(title: NSLocalizedString("Choose a Date", comment: ""), message: nil, preferredStyle: .actionSheet)
		alertVC.view.frame = CGRect(x: 0, y: 0, width: isiPad ? 300 : kScreenWidth, height: 10)
		
		let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
			self.currentDate = apodDatePicker.date
			self.presenter.loadAPOD(for: apodDatePicker.date)
		}
		alertVC.addAction(okAction)
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
		alertVC.addAction(cancelAction)
		
		alertVC.view.addSubview(apodDatePicker)
		apodDatePicker.date = currentDate
		
		let height = NSLayoutConstraint(item: alertVC.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: apodDatePicker.frame.height + (isiPad ? 80 : 150))
		NSLayoutConstraint.activate([height])
		
		if !isiPad {
			apodDatePicker.center = CGPoint(x: view.center.x - 10, y: apodDatePicker.center.y)
		}
		
		if let popoverPresentationController = alertVC.popoverPresentationController {
			popoverPresentationController.barButtonItem = sender as? UIBarButtonItem
			popoverPresentationController.permittedArrowDirections = .up
			popoverPresentationController.sourceView = self.view
			popoverPresentationController.sourceRect = .zero
		}
		
		present(alertVC, animated: true)

	}
	
	@IBAction func didTapNextday(_ sender: Any) {
		let newDate = currentDate.addingTimeInterval(24 * 60 * 60)
		guard newDate.timeIntervalSince1970 <= Date().timeIntervalSince1970 else {
			return
		}
		presenter.loadAPOD(for: newDate)
	}
	
	@IBAction func didTapPreviousDay(_ sender: Any) {
		let newDate = currentDate.addingTimeInterval(-24 * 60 * 60)
		let minimumDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())!
		guard newDate.timeIntervalSince1970 >= minimumDate.timeIntervalSince1970 else {
			return
		}
		presenter.loadAPOD(for: newDate)
	}
}

// MARK: - Table view data source
extension HomeViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch indexPath.row {
		case 1:
			return imageViewHeight
		default:
			return UITableView.automaticDimension
		}
	}

}

extension HomeViewController: APODPresentable {
	func configure(with apod: APODModel) {
		currentDate = apod.date

		titleLabel?.text = apod.title
		explanationLabel?.text = apod.explanation
		copyrightLabel?.text = apod.copyright
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateBarButtonItem?.title = dateFormatter.string(from: apod.date)
		nextDayBarButtonItem?.isEnabled = apod.date < Date.now
		favoriteBarButtonItem?.image = UIImage(systemName: apod.isFavourite ? "heart.fill" : "heart")!

		if apod.mediaType == .image {
			let imageResourse = ImageResource(downloadURL: apod.url,
											  cacheKey: appDateFormatter.string(from: apod.date))

			apodImageView?.kf.setImage(with: imageResourse, placeholder: nil, options: nil, progressBlock: { receivedSize, totalSize in
				SVProgressHUD.showProgress(Float(receivedSize) / Float(totalSize), status: "Loading picture")
			}, completionHandler: { [weak self] result in
				guard case .success(let value) = result else { return }
				
				let calculatedHeight = kScreenWidth / value.image.size.width * value.image.size.height
				self?.imageViewHeight = calculatedHeight
				self?.apodImageView?.frame = CGRect(x: 0.0,
													y: 0.0,
													width: kScreenWidth,
													height: calculatedHeight)
				
				SVProgressHUD.dismiss()

				self?.tableView?.reloadData()
			})
		} else {
			// TODO: load video type media here
		}
	}
	
	func didFailToLoadAPOD(for date: Date, errorMessage: String) {
		let alert = UIAlertController(title: "OOPS!", message: errorMessage, preferredStyle: .alert)
		alert.addAction(.init(title: "OK", style: .cancel))
		present(alert, animated: true)
	}
	
	func showLoadingIndicator() {
		SVProgressHUD.show(withStatus: "Loading")
	}
	
	func hideLoadingIndicator() {
		SVProgressHUD.dismiss()
	}
}

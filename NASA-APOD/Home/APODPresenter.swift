//
//  APODPresenter.swift
//  NASA-APOD
//
//  Created by Jagadeeshwar Reddy on 27/03/22.
//

import Foundation

protocol APODPresentable: AnyObject {
	func configure(with apod: APODModel)
	
	func didFailToLoadAPOD(for date: Date, errorMessage: String)
	
	func showLoadingIndicator()
	func hideLoadingIndicator()
}

protocol APODPresenterType: AnyObject {
	var view: APODPresentable? { get set }
	
	func loadAPOD(for date: Date)
	
	func isAPODFavourited(for date: Date) -> Bool
	func addToFavourite(date: Date)
	func removeFromFavourite(date: Date)
}

final class APODPresenter: APODPresenterType {
	weak var view: APODPresentable?
	
	func loadAPOD(for date: Date) {
		if let model = APODCache.shared.getCacheModel(on: date) {
			view?.configure(with: model)
		} else {
			view?.showLoadingIndicator()
			
			CoreAPIManager.shared.fetchAPOD(for: date) { [weak self] (apodModel, error) in
				self?.view?.hideLoadingIndicator()
				
				guard let model = apodModel else {
					self?.view?.didFailToLoadAPOD(for: date, errorMessage: error?.localizedDescription ?? "Something went wrong while loading the data")
					return
				}
				self?.view?.configure(with: model)
				
				DispatchQueue.global().async {
					APODCache.shared.cacheModel(model: model)
				}
			}
		}
	}

	func isAPODFavourited(for date: Date) -> Bool {
		return APODCache.shared.isFavouriteModel(on: date)
	}
	
	func addToFavourite(date: Date) {
		APODCache.shared.addFavorite(date: date)
	}
	
	func removeFromFavourite(date: Date) {
		APODCache.shared.removeFavorite(date: date)
	}
}

//
//  APODCache.swift
//  NASA-APOD
//
//  Created by Jagadeeshwar Reddy on 27/03/22.
//

import Foundation

struct APODCache {
	static let shared = APODCache()
	
	private let favoriteKey     = "favorite_apod"
	private let cacheKey        = "cache_apod"
	private let kUserDefaults 	= UserDefaults(suiteName: "com.apod.cache.favourites")!
	private let apodJSONEncoder: JSONEncoder = {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .formatted(appDateFormatter)
		return encoder
	}()
	private let apodJSONDecoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(appDateFormatter)
		return decoder
	}()
	
	private init() {}

	func addFavorite(date: Date) {
		var array 		= (kUserDefaults.value(forKey: favoriteKey) as? [String]) ?? []
		let dateString 	= appDateFormatter.string(from: date)
		if !array.contains(dateString) {
			array.append(dateString)
		}
		kUserDefaults.set(array, forKey: favoriteKey)
		kUserDefaults.synchronize()
	}
	
	func removeFavorite(date: Date) {
		var array 		= (kUserDefaults.value(forKey: favoriteKey) as? [String]) ?? []
		let dateString 	= appDateFormatter.string(from: date)
		if array.contains(dateString) {
			array.remove(at: array.firstIndex(of: dateString)!)
		}
		kUserDefaults.set(array, forKey: favoriteKey)
		kUserDefaults.synchronize()
	}
	
	func getFavoriteModels() -> [APODModel]? {
		return (kUserDefaults.value(forKey: favoriteKey) as? [String])?.map {
			getCacheModel(on: appDateFormatter.date(from: $0)!)!
		}
	}
	
	func isFavouriteModel(on date: Date) -> Bool {
		if let array = (kUserDefaults.value(forKey: favoriteKey) as? [String]) {
			return array.contains(appDateFormatter.string(from: date))
		}
		return false
	}
	
	// MARK: - Cache
	
	func cacheModel(model: APODModel) {
		var dict = (kUserDefaults.value(forKey: cacheKey) as? [String: Data]) ?? [:]
		dict[appDateFormatter.string(from: model.date)] = try? apodJSONEncoder.encode(model)
		kUserDefaults.set(dict, forKey: cacheKey)
		kUserDefaults.synchronize()
	}
	
	func getCacheModel(on date: Date) -> APODModel? {
		let dict = (kUserDefaults.value(forKey: cacheKey) as? [String: Data]) ?? [:]
		if let data = dict[appDateFormatter.string(from: date)] {
			do {
				return try apodJSONDecoder.decode(APODModel.self, from: data)
			} catch {
				debugPrint(error)
			}
		}
		return nil
	}
}

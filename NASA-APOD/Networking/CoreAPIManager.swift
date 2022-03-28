//
//  CoreAPIManager.swift
//  NASA-APOD
//
//  Created by Jagadeeshwar Reddy on 27/03/22.
//

import Foundation
import Moya
import UIKit

struct CoreAPIManager {
	static let shared = CoreAPIManager()
	
	private let apiProvider = MoyaProvider<CoreAPI>()
	private init() {}
	
	func fetchAPOD(for date: Date, completionHandler: @escaping (APODModel?, GenericError?) -> Void) {
		
		apiProvider.request(.apod(date: date)) { result in
			switch result {
			case .success(let response):
				do {
					if response.statusCode == 200 {
						let jsonDecoder = JSONDecoder()
						jsonDecoder.dateDecodingStrategy = .formatted(appDateFormatter)
						let result = try jsonDecoder.decode(APODModel.self, from: response.data)
						completionHandler(result, nil)
					} else {
						completionHandler(nil, GenericError("Invalid status code: \(response.statusCode)"))
					}
				} catch {
					completionHandler(nil, GenericError("Failed to parse response from server.\n\(error.localizedDescription)"))
				}
			case .failure(let error):
				completionHandler(nil, GenericError(error.localizedDescription))
			}
		}
	}

}

public struct GenericError: LocalizedError {
	let message: String
	init(_ message: String) {
		self.message = message
	}
	public var errorDescription: String? {
		return message
	}
	public var localizedDescription: String? {
		return message
	}
}

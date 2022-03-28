//
//  APODModel.swift
//  NASA-APOD
//
//  Created by Jagadeeshwar Reddy on 27/03/22.
//

import Foundation

struct APODModel: Codable {
	let copyright: String?
	let date: Date
	let explanation: String
	let mediaType: APODMediaType
	let serviceVersion: String
	let title: String
	let url: URL
	var hdurl: URL
	
	var isFavourite: Bool {
		APODCache.shared.isFavouriteModel(on: date)
	}
	
	private enum CodingKeys: String, CodingKey {
		case copyright, date, explanation
		case mediaType = "media_type"
		case serviceVersion = "service_version"
		case title, url, hdurl
	}
}

enum APODMediaType: String, Codable {
	case image
	case video
}

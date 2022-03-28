//
//  CoreAPI.swift
//  NASA-APOD
//
//  Created by Jagadeeshwar Reddy on 27/03/22.
//

import Moya

fileprivate var apikey: String { "OxE69Mt54fBifjKSqRpbYgt2TLN26zcG0tOl1RBO" }

enum CoreAPI {
	case apod(date: Date)
}

extension CoreAPI: TargetType {
	var baseURL: URL {
		return URL(string: "https://api.nasa.gov")!
	}
	
	var path: String {
		switch self {
		case .apod:
			return "/planetary/apod"
		}
	}
	
	var task: Task {
		switch self {
		case .apod(let date):
			return .requestParameters(parameters: ["api_key": apikey,
												   "date": appDateFormatter.string(from: date)],
									  encoding: URLEncoding.default)
		}
	}
	
	var method: Method {
		.get
	}
	
	var headers: [String : String]? {
		[:]
	}
}

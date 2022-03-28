//
//  Utilities.swift
//  NASA-APOD
//
//  Created by Jagadeeshwar Reddy on 27/03/22.
//

import Foundation
import UIKit

let kScreenWidth    : CGFloat = UIScreen.main.bounds.width
let kScreenHeight   : CGFloat = UIScreen.main.bounds.height

let isiPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad

let appDateFormatter: DateFormatter = {
	let urlDateFormatter = DateFormatter()
	urlDateFormatter.dateFormat = "yyyy-MM-dd"
	urlDateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
	return urlDateFormatter
}()

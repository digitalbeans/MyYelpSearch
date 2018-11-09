//
//  DataModel.swift
//  MyYelpSearch
//
//  Created by Dean Thibault on 11/9/18.
//  Copyright © 2018 Digital Beans. All rights reserved.
//

import Foundation

struct Businesses: Codable {
	let total: Int
	let businesses: [Business]
	let region: Region
}

struct Business: Codable {
	let rating: Double
	let price: String?
	let phone: String
	let id: String
	let alias: String
	let isClosed: Bool
	let categories: [Category]
	let reviewCount: Int
	let name: String
	let url: String
	let coordinates: Center
	let imageURL: String?
	let location: Location?
	let distance: Double
	let transactions: [String]
	
	enum CodingKeys: String, CodingKey {
		case rating, price, phone, id, alias
		case isClosed = "is_closed"
		case categories
		case reviewCount = "review_count"
		case name, url, coordinates
		case imageURL = "image_url"
		case location, distance, transactions
	}
}

//struct Category: Codable {
//	let alias, title: String
//}

struct Center: Codable {
	let latitude, longitude: Double
}

struct Location: Codable {
	let city, country, address2, address3: String?
	let state, zipCode: String
	let address1: String?
	
	enum CodingKeys: String, CodingKey {
		case city, country, address2, address3, state, address1
		case zipCode = "zip_code"
	}
	
	var description: String {
		
		var descriptionString = ""
		if let address1 = address1, !address1.isEmpty {
			descriptionString += address1
		}
		if let address2 = address2, !address2.isEmpty {
			descriptionString +=  ", " + address2
		}
		if let city = city, !city.isEmpty {
			descriptionString +=  ", " + city
		}
		if !state.isEmpty {
			descriptionString +=  ", " + state
		}
		if !zipCode.isEmpty {
			descriptionString +=  ", " + zipCode
		}

		return descriptionString
	}
}

struct Region: Codable {
	let center: Center
}

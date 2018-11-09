//
//  DataLoader.swift
//  MyYelpSearch
//
//  Created by Dean Thibault on 11/9/18.
//  Copyright © 2018 Digital Beans. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

class DataLoader {
	
	static let restaurantSearchURL = "https://api.yelp.com/v3/businesses/search?term=%@&offset=%d&latitude=%f&longitude=%f&sort_by=distance"
	static let clientID = "MoIQp79-aVcdwAx-vVf8vA"
	static let apiKey = "ZCC0xk83KLrsPYDWkWPN2FSncoxQr1bHvb6Vo-lXe2TjX60-n3V7NWPZwsItysHniolw5Q850NuQ-a5t0GKxRz54g7H4QpJoIXf2Z2Q04RYJ1ZmLDrE40AfDMgblW3Yx"
	
	// Load and decode json from file and decode it
	static func loadDataFrom(searchTerm: String, category: Category? = nil, offset: Int, coordinates: CLLocationCoordinate2D, completion: @escaping (_ result: Businesses?) -> Void) {

		var urlString = String(format: restaurantSearchURL, searchTerm, offset, coordinates.latitude, coordinates.longitude)
		if let category = category {
			urlString.append("&categories=\(category.alias)")
		}
		
		guard let url = URL(string: urlString) else {
			completion(nil)
			return
		}
		
		let headers: HTTPHeaders = [
			"Authorization": "Bearer \(apiKey)",
			"Accept": "application/json"]

		Alamofire.request(url,
						  headers: headers)
			.validate()
			.responseJSON { response in
				guard response.result.isSuccess,
				      let data = response.data else {
					
						print("Error requesting data;\n \(String(describing: response.error))")
					completion(nil)
					return
				}
				
				do {
					let decoder = JSONDecoder()
					let businesses = try decoder.decode(Businesses.self, from: data)
					completion(businesses)
				}
				catch {
					print("Error decoding type \(Businesses.self);\n  \(error)")
					completion(nil)
				}
		}
	}
	
	static let categoriesURL = "https://api.yelp.com/v3/categories"

	static func loadCategoriesFrom(completion: @escaping (_ result: Categories?) -> Void) {
		
		
		guard let url = URL(string: categoriesURL) else {
			completion(nil)
			return
		}
		
		let headers: HTTPHeaders = [
			"Authorization": "Bearer \(apiKey)",
			"Accept": "application/json"]
		
		Alamofire.request(url,
						  headers: headers)
			.validate()
			.responseJSON { response in
				guard response.result.isSuccess,
					let data = response.data else {
						
						print("Error requesting data;\n \(String(describing: response.error))")
						completion(nil)
						return
				}
				
				do {
					let decoder = JSONDecoder()
					let categories = try decoder.decode(Categories.self, from: data)
					completion(categories)
				}
				catch {
					print("Error decoding type \(Businesses.self);\n  \(error)")
					completion(nil)
				}
		}
	}
}

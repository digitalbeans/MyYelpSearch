//
//  UIImageView+Offers.swift
//  MyYelpSearch
//
//  Created by Dean Thibault on 11/9/18.
//  Copyright © 2018 Digital Beans. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

// Extension to provide for downloading images asynchronously and setting in the UIImageView
extension UIImageView {
	
	func image(from url: URL, placeHolder: UIImage? = UIImage(named: Constants.Image.placeHolder)) {
		
		if let cachedImage = imageCache.object(forKey: NSString(string: url.absoluteString)) {
			self.image = cachedImage
			return
		}
		
		// fetch image asynchronously
		DispatchQueue.global().async { [weak self] in
			if let data = try? Data(contentsOf: url) {
				
				// set image in image view on the main queue
				if let downloadedImage = UIImage(data: data) {
					DispatchQueue.main.async {
						imageCache.setObject(downloadedImage, forKey: NSString(string: url.absoluteString))
						self?.image = downloadedImage
					}
				}
			}
			else {
				DispatchQueue.main.async {
					self?.image = placeHolder
				}
			}
		}
	}
}

//
//  BusinessTableViewCell.swift
//  MyYelpSearch
//
//  Created by Dean Thibault on 11/9/18.
//  Copyright © 2018 Digital Beans. All rights reserved.
//

import UIKit

class BusinessTableViewCell: UITableViewCell {

	@IBOutlet var businessImageView: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var subtitleLabel: UILabel!
	@IBOutlet var distanceLabel: UILabel!
	
	
	override func awakeFromNib() {
        super.awakeFromNib()
    }
	
	func setupCell(with business: Business) {
		
		titleLabel.text = business.name
		subtitleLabel.text = business.location?.description
		
		let meters = Measurement(value: business.distance, unit: UnitLength.meters)
		let miles = meters.converted(to: .miles).value
		distanceLabel.text = String(format: "%.2f miles", miles)
		
		if let urlString = business.imageURL, let url = URL(string: urlString) {
			
			businessImageView?.image(from: url)
		}

	}
	
	// convience method for returning reuse identifier same as class name
	override var reuseIdentifier: String? {
		
		return BusinessTableViewCell.identifier
	}

	static var identifier: String {
		
		return String(describing: self)
	}
}

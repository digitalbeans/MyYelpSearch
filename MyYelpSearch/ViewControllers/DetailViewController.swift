//
//  DetailViewController.swift
//  MyYelpSearch
//
//  Created by Dean Thibault on 5/3/20.
//  Copyright © 2020 Digital Beans. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

	@IBOutlet var closeButton: UIButton!
	@IBOutlet var businessImageView: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var subtitleLabel: UILabel!
	@IBOutlet var distanceLabel: UILabel!
	
	@IBOutlet var star1Image: UIImageView!
	@IBOutlet var star2Image: UIImageView!
	@IBOutlet var star3Image: UIImageView!
	@IBOutlet var star4Image: UIImageView!
	@IBOutlet var star5Image: UIImageView!
	@IBOutlet var starArray: [UIImageView]!
	
	var business: Business?
	var image: UIImage?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		showStars()
	}
	
	func setup() {
		
		guard let business = business else { return }
		titleLabel.text = business.name
		subtitleLabel.text = business.location?.description
		
		let meters = Measurement(value: business.distance, unit: UnitLength.meters)
		let miles = meters.converted(to: .miles).value
		distanceLabel.text = String(format: "%.2f miles", miles)
		
		if let image =  image {
			businessImageView.image = image
		}
		else if let urlString = business.imageURL, let url = URL(string: urlString) {
			
			businessImageView?.image(from: url)
		}

	}
	
	func showStars() {
		let rating = business?.rating ?? 0
		let whole = Int(floor(rating))
		let half = rating.truncatingRemainder(dividingBy: 1) >= 0.5
		
		var delay = DispatchTime.now() + 0.5
		for i in 0..<whole {
			let imageView = starArray[i]
			
			DispatchQueue.main.asyncAfter(deadline: delay, execute: {
				imageView.image = UIImage(named: "star_red")
				
				let scaleTransform = imageView.transform.scaledBy(x: 1.2, y: 1.2)
				UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: {
					imageView.transform = scaleTransform
				}, completion: { _ in
					UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: {
						imageView.transform = .identity
					})
				})
			})

			delay = delay + 0.25
		}
		
		if half {
			let imageView = self.starArray[whole]
			DispatchQueue.main.asyncAfter(deadline: delay, execute: {
				imageView.image = UIImage(named: "star-half")

				let scaleTransform = imageView.transform.scaledBy(x: 1.2, y: 1.2)
				UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: {
					imageView.transform = scaleTransform
				}, completion: { _ in
					UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: {
						imageView.transform = .identity
					})
				})
			})
		}
	}

	@IBAction func close(_ sender: Any) {
		
		dismiss(animated: true)
	}
}

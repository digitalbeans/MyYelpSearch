//
//  ViewController.swift
//  MyYelpSearch
//
//  Created by Dean Thibault on 11/9/18.
//  Copyright © 2018 Digital Beans. All rights reserved.
//

import UIKit
import CoreLocation

class RootViewController: UITableViewController {

	let locationManager = CLLocationManager()
	var businesses: [Business] = []
	var selectedCategory: Category?

    var selectedCell: BusinessTableViewCell?
    var selectedCellImageViewSnapshot: UIView?
	var animator: Animator?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		navigationItem.title = Constants.app.title
		
		tableView.tableFooterView = UIView()
		
		refreshControl = UIRefreshControl()
		refreshControl?.attributedTitle = NSAttributedString(string: Constants.app.refresh)
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

		tableView.register(UINib(nibName: BusinessTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: BusinessTableViewCell.identifier)
		
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.requestLocation()
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		tableView.backgroundView = businesses.count == 0 ? backgroundView : nil

		return businesses.count
		
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: BusinessTableViewCell.identifier, for: indexPath) as? BusinessTableViewCell else {
			return UITableViewCell()
		}
		
		let business = businesses[indexPath.row]
		cell.setupCell(with: business)
		
		return cell
	}
	
	fileprivate func presentDetailView(_ business: Business, image: UIImage?) {
		let detailViewController = DetailViewController()
		detailViewController.transitioningDelegate = self
		detailViewController.business = business
		detailViewController.image = image
		detailViewController.modalPresentationStyle = .fullScreen
		present(detailViewController, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		selectedCell = tableView.cellForRow(at: indexPath) as? BusinessTableViewCell
		selectedCellImageViewSnapshot = selectedCell?.businessImageView.snapshotView(afterScreenUpdates: false)

		let business = businesses[indexPath.row]
		presentDetailView(business, image: selectedCell?.businessImageView.image)
		
	}
	
	override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		
		let reloadDistance: CGFloat = 50
		
		let offset = scrollView.contentOffset
		let bounds = scrollView.bounds
		let inset = scrollView.contentInset
		let y = offset.y + bounds.size.height - inset.bottom
		let height = scrollView.contentSize.height
		
		if y > height + reloadDistance {
			
			guard let coordinate = locationManager.location?.coordinate else { return }
			
			loadData(coordinate: coordinate, category: selectedCategory)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		guard let identifier = segue.identifier,
		      identifier == Constants.segue.categorySelectorySegue else { return }
	
		if let categoriesTableViewController = segue.destination as? CategoriesTableViewController {
			categoriesTableViewController.categoryDelegate = self
		}
	}
	
	func loadData(coordinate: CLLocationCoordinate2D, category: Category?) {
		
		let offset = businesses.count
		refreshControl?.beginRefreshing()
		DataLoader.loadDataFrom(searchTerm: "restaurants", category: category, offset: offset, coordinates: coordinate, completion: { [weak self] (result)  in
			
			self?.refreshControl?.endRefreshing()
			guard let response = result else { return }
			
			self?.businesses.append(contentsOf: response.businesses)
			self?.tableView.reloadData()
		})
	}
	
	var backgroundView: UIView {
		
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
		label.text = Constants.Message.emptyList
		label.textAlignment = .center
		
		return label
	}

}

extension RootViewController: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		if let coordinate = locations.last?.coordinate {
			loadData(coordinate: coordinate, category: selectedCategory)
		} else {
			print("No coordinates")
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .denied {
			let alertController = UIAlertController(title: "Location detection not allowed", message: "Please allow My Yelp Search to check use your location in device settings", preferredStyle: .alert)
			
			let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
			alertController.addAction(okAction)

			present(alertController, animated: true)
		}
	}
}

extension RootViewController {
	
	@objc func refresh() {
		
		businesses = []
		tableView.reloadData()
		
		guard let coordinate = locationManager.location?.coordinate else { return }
		
		loadData(coordinate: coordinate, category: selectedCategory)
	}
}

extension RootViewController: CategorySelectorProtocol {
	func didSelectCategory(category: Category) {
		selectedCategory = category
		refresh()
	}
}

extension RootViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

		guard let navigationController = presenting as? UINavigationController,
			let firstViewController = navigationController.viewControllers.first as? RootViewController,
            let secondViewController = presented as? DetailViewController,
            let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
            else { return nil }

        animator = Animator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

		guard let secondViewController = dismissed as? DetailViewController,
            let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
            else { return nil }

        animator = Animator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
        return animator
    }
}

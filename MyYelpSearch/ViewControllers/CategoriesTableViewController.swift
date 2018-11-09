//
//  CategoriesTableViewController.swift
//  MyYelpSearch
//
//  Created by Dean Thibault on 11/9/18.
//  Copyright © 2018 Digital Beans. All rights reserved.
//

import UIKit

protocol CategorySelectorProtocol {
	func didSelectCategory(category: Category)
}

class CategoriesTableViewController: UITableViewController {
	
	var categories: [Category] = []
	var categoryDelegate: CategorySelectorProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.tableFooterView = UIView()

		loadCategories()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

		let category = categories[indexPath.row]
        cell.textLabel?.text = category.title

        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let category = categories[indexPath.row]
		categoryDelegate?.didSelectCategory(category: category)
		navigationController?.popViewController(animated: true)
	}

	func loadCategories() {
		
		refreshControl?.beginRefreshing()
		DataLoader.loadCategoriesFrom(completion: { [weak self] (result)  in
			
			self?.refreshControl?.endRefreshing()
			guard let response = result else { return }
			
			self?.categories = response.categories.filter({ $0.parentAliases?.contains("restaurants") ?? false })
			self?.tableView.reloadData()
		})
	}

}

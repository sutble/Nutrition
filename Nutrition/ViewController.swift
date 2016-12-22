//
//  ViewController.swift
//  Nutrition
//
//  Created by Aditya Garg on 12/21/16.
//  Copyright © 2016 garg. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var foodArray = ["Chole Rice", "Chicken with Rice/Vegetables", "Turkey Sandwich"]
    var filteredArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarSetup()
    }
    
    //MARK: - Search Bar
    
    func searchBarSetup(){
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70))
        searchBar.showsScopeBar = true
        searchBar.scopeButtonTitles = ["protein","carbs","fat"]
        searchBar.delegate = self
        searchBar.selectedScopeButtonIndex = 0
        tableView.tableHeaderView = searchBar
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchText.isEmpty){
            foodArray = ["Chole Rice", "Chicken with Rice/Vegetables", "Turkey Sandwich"]
        }
        
        foodArray = foodArray.filter { foodItem in
            return foodItem.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    //MARK: - Table View

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return foodArray.count
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    
    {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = foodArray[indexPath.row]
        return cell
        
    }



}


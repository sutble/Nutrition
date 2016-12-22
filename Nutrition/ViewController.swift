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
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    var searchActivated : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarSetup()
        
    }
    
    //MARK: - Search Bar
    
    func searchBarSetup(){
        
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredArray = foodArray.filter { foodItem in
            return foodItem.lowercased().contains(searchText.lowercased())
        }
        if filteredArray.count == 0 {
            searchActivated = false
        }
        else {
            searchActivated = true
        }
        tableView.reloadData()
    }
    
    
    
    //MARK: - Table View

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(searchActivated){
            return filteredArray.count
        }
        else{
        return foodArray.count
        }
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    
    {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if(searchActivated){
            cell.textLabel?.text = filteredArray[indexPath.row]
        }
        else{
            cell.textLabel?.text = foodArray[indexPath.row]
        }
        
        return cell
        
    }



}


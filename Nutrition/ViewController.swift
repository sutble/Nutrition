//
//  ViewController.swift
//  Nutrition
//
//  Created by Aditya Garg on 12/21/16.
//  Copyright © 2016 garg. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    var ref : FIRDatabaseReference!
    var refHandle : UInt!
    var mainDict = ["protein": 0 as AnyObject, "carbs" : 0 as AnyObject, "fat": 0 as AnyObject, "name": "hello" as AnyObject] as [String : AnyObject]
    
    
    var foodArray = [FoodItem]()
    var filteredArray = [FoodItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        populateTableView()
    }
    
    
    
    //MARK: - Search Bar
    
    func updateSearchResults(for searchController: UISearchController) {
        print("searchTable")
        searchController.searchResultsController?.view.isHidden = false
        self.filteredArray.removeAll(keepingCapacity: false)
        self.filteredArray = self.foodArray.filter { foodItem in
            return foodItem.name!.lowercased().contains(searchController.searchBar.text!.lowercased())
        }
        print(self.filteredArray)
        self.tableView.reloadData()
    }
    
    
    
    
    
    
    
    
    //MARK: - Table View

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
       return filteredArray.count
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    
    {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = filteredArray[indexPath.row].name!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            addFoodtoDB(foodName: filteredArray[indexPath.row].name!)
    }
    
    func populateTableView(){
        refHandle = ref.child("Misc").child("Nutrition").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                print(dictionary)
                let name = (dictionary["name"] as! String)
                let protein = (dictionary["protein"] as! NSNumber).doubleValue
                let carbs = (dictionary["carbs"] as! NSNumber).doubleValue
                let fat = (dictionary["fat"] as! NSNumber).doubleValue
                let calories = (dictionary["calories"] as! NSNumber).doubleValue

                let foodItem = FoodItem(name: name, protein: protein, carbs: carbs, fat: fat, calories: calories)
                self.foodArray.append(foodItem)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    //MARK: - Helper Functions
    func stringDate() -> String{
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: Date())
        
        let year =  components.year
        let month = components.month
        let day = components.day
        
        if (day! < 10){
            return "\(month!)" + ":" + "0\(day!)" + ":" + "\(year!)"
        }
        else{
            return "\(month!)" + ":" + "\(day!)" + ":" + "\(year!)"
        }
    }
    
    func populateDummyData(){
        foodArray.append(FoodItem(name: "Chicken and Rice/Vegetables", protein: 200, carbs: 150, fat: 35, calories: 500))
        foodArray.append(FoodItem(name: "Chole Rice", protein: 150, carbs: 150, fat: 10, calories: 300))
        foodArray.append(FoodItem(name: "Turkey Sandwich", protein: 75, carbs: 200, fat: 50, calories: 400))
        foodArray.append(FoodItem(name: "Cereal", protein: 20, carbs: 300, fat: 5, calories: 150))
        foodArray.append(FoodItem(name: "Five Guys CheeseBurger", protein: 400, carbs: 600, fat: 300, calories: 900))
    }
    
    func addFoodtoDB(foodName: String){
        
        ref?.child("Misc").child("Nutrition").child(foodName).observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
               self.mainDict = dictionary
                print("dict")
                print(self.mainDict)
            }
        })
        ref?.child(stringDate()).child("Body").child("Nutrition").observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let protein : Double = self.mainDict["protein"] as! Double
                let updatedProtein : Double = protein + (dictionary["protein"] as! Double)
                let carbs : Double = self.mainDict["carbs"] as! Double
                let updatedCarbs : Double = carbs + (dictionary["carbs"] as! Double)
                let fat : Double = self.mainDict["fat"] as! Double
                let updatedFat : Double = fat + (dictionary["fat"] as! Double)
                let calories : Double = self.mainDict["calories"] as! Double
                let updatedCalories : Double = calories + (dictionary["calories"] as! Double)
                
                DispatchQueue.main.async {
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("protein").setValue(updatedProtein)
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("carbs").setValue(updatedCarbs)
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("fat").setValue(updatedFat)
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("calories").setValue(updatedCalories)
                }
                
                
            }
        })
    }



}


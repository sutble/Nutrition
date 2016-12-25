//
//  FoodItem.swift
//  Nutrition
//
//  Created by Aditya Garg on 12/22/16.
//  Copyright © 2016 garg. All rights reserved.
//

import Foundation


class FoodItem: NSObject {
    
   public var name : String?
   public var protein : Double?
   public var carbs : Double?
   public var fat : Double?
   public var calories: Double?
    
    init(name : String, protein : Double, carbs: Double, fat: Double,calories: Double) {
        self.name = name
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.calories = calories
    }
    
    override init(){
        print("empty init")
    }
    
    
    
    
}

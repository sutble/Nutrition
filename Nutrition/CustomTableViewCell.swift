//
//  CustomTableViewCell.swift
//  Nutrition
//
//  Created by Aditya Garg on 1/3/17.
//  Copyright © 2017 garg. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
       
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func highlight(macros: [Double], significant: [Double]){
        
        let darkBlue = UIColor(red: 13/255, green: 60/255, blue: 85/255, alpha: 1)
        let orange = UIColor(red: 241/255, green: 108/255, blue: 32/255, alpha: 1)
        let lightBlue = UIColor(red: 19/255, green: 149/255, blue: 186/255, alpha: 1)
        let red = UIColor(red: 216/255, green: 66/255, blue: 38/255, alpha: 1)
        let green = UIColor(red: 60/255, green: 179/255, blue: 113/255, alpha: 1)
        
        let calories = macros[0]
        let protein = macros[1]
        let carbs = macros[2]
        let fat = macros[3]
        
        if(calories >= significant[0]){
            setHighlight(label: calorieLabel, color: red)
        }
        
        if (calories <= significant[1]){
            setHighlight(label: calorieLabel, color: green)
        }
        
        if (protein > significant[2]){
            setHighlight(label: proteinLabel, color: lightBlue)
        }
        if (carbs >= significant[3]){
            setHighlight(label: carbsLabel, color: darkBlue)
        }
        if (fat >= significant[4]){
            setHighlight(label: fatLabel, color: orange)
        }
    
    }
    
    func setHighlight(label: UILabel, color: UIColor){
        label.backgroundColor = color
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
    }
    
    func reset(){
        setReset(label: calorieLabel)
        setReset(label: proteinLabel)
        setReset(label: carbsLabel)
        setReset(label: fatLabel)
    }
    
    func setReset(label: UILabel){
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.textAlignment = .center
    }


}

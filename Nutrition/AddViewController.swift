//
//  AddViewController.swift
//  Nutrition
//
//  Created by Aditya Garg on 12/23/16.
//  Copyright © 2016 garg. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddViewController: UIViewController {
    
    var ref : FIRDatabaseReference?
    var refHandle:FIRDatabaseHandle?
    var defaults : UserDefaults?

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var proteinText: UITextField!
    @IBOutlet weak var carbsText: UITextField!
    @IBOutlet weak var fatText: UITextField!
    @IBOutlet weak var caloriesText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        defaults = UserDefaults.standard
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        proteinText.keyboardType = UIKeyboardType.decimalPad
        carbsText.keyboardType = UIKeyboardType.decimalPad
        fatText.keyboardType = UIKeyboardType.decimalPad
        caloriesText.keyboardType = UIKeyboardType.decimalPad
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    @IBAction func updateToFB(_ sender: AnyObject) {
        
        if( (!(nameText!.text?.isEmpty)!) && (!(proteinText!.text?.isEmpty)!) && (!(carbsText!.text?.isEmpty)!) && (!(fatText!.text?.isEmpty)!) && (!(caloriesText!.text?.isEmpty)!)) {
            print("updateToFB")
        
            ref?.child(stringDate()).child("Body").child("Nutrition").observeSingleEvent(of: .value, with: {(snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject] {

                    let protein : Double = dictionary["protein"] as! Double
                    let carbs : Double = dictionary["carbs"] as! Double
                    let fat : Double = dictionary["fat"] as! Double
                    let calories : Double = dictionary["calories"] as! Double
                 
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("protein").setValue(protein + (self.proteinText.text as! NSString).doubleValue)
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("carbs").setValue(carbs + (self.carbsText.text as! NSString).doubleValue)
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("fat").setValue(fat + (self.fatText.text as! NSString).doubleValue)
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("calories").setValue(calories + (self.caloriesText.text as! NSString).doubleValue)
                    self.addFood()
                }
                else{ //init the day with first values and food to DB
                    self.startTheDayRight()
                    self.addFood()
                }
            })
        }
        else{
            print("add alert option here")
        }
    }
    func setDefaults(){
        
    }
    
    func startTheDayRight(){
        self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("protein").setValue((self.proteinText.text as! NSString).doubleValue)
        self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("carbs").setValue((self.carbsText.text as! NSString).doubleValue)
        self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("fat").setValue((self.fatText.text as! NSString).doubleValue)
        self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("calories").setValue((self.caloriesText.text as! NSString).doubleValue)
    }
    
    func addFood(){
        self.ref?.child("Misc").child("Nutrition").child(self.nameText.text!).child("name").setValue(self.nameText.text!)
        self.ref?.child("Misc").child("Nutrition").child(self.nameText.text!).child("protein").setValue((self.proteinText.text as! NSString).doubleValue)
        self.ref?.child("Misc").child("Nutrition").child(self.nameText.text!).child("carbs").setValue((self.carbsText.text as! NSString).doubleValue)
        self.ref?.child("Misc").child("Nutrition").child(self.nameText.text!).child("fat").setValue((self.fatText.text as! NSString).doubleValue)
        self.ref?.child("Misc").child("Nutrition").child(self.nameText.text!).child("calories").setValue((self.caloriesText.text as! NSString).doubleValue)
    }
    
    func ifelseblock(){ //this works
        
            
            
        
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

        
        
    
    

}

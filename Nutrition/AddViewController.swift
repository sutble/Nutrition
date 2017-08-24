//
//  AddViewController.swift
//  Nutrition
//
//  Created by Aditya Garg on 12/23/16.
//  Copyright © 2016 garg. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SkyFloatingLabelTextField


class AddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomSearchControllerDelegate, UISearchBarDelegate {
    
    var ref : FIRDatabaseReference!
    var currentFoodHandle:FIRDatabaseHandle!
    var newFoodHandle: FIRDatabaseHandle!
    var defaults : UserDefaults?
    var customSearchController: foodSearchController!
    
    var nameText : SkyFloatingLabelTextField!
    var proteinText : SkyFloatingLabelTextField!
    var carbsText : SkyFloatingLabelTextField!
    var fatText : SkyFloatingLabelTextField!
    var caloriesText : SkyFloatingLabelTextField!
    
    var addButton : UIButton = UIButton(type: .custom)
    let alertController = UIAlertController(title: "Fill in all the fields", message: "", preferredStyle: UIAlertControllerStyle.alert)

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var uglyTableView: UITableView!
    
    var foodArray = [FoodItem]()
    var filteredArray = [FoodItem]()
     var mainDict = ["protein": 0 as AnyObject, "carbs" : 0 as AnyObject, "fat": 0 as AnyObject, "name": "hello" as AnyObject] as [String : AnyObject]
    
    //MARK: - Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        defaults = UserDefaults.standard
        
        let lightBlue = UIColor(red: 19/255, green: 149/255, blue: 186/255, alpha: 1)
        self.view.backgroundColor = lightBlue
    
        tapDismiss()
        configureCustomSearchController()
        populateTableView()
        setTextFields()
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.isHidden = true
        tableView.frame = uglyTableView.frame
    }

    //MARK: - Firebase
    
     func updateToFB() {
        if( (!(nameText!.text?.isEmpty)!) && (!(proteinText!.text?.isEmpty)!) && (!(carbsText!.text?.isEmpty)!) && (!(fatText!.text?.isEmpty)!) && (!(caloriesText!.text?.isEmpty)!)) {
            print("updateToFB")
            
            ref?.child(stringDate()).child("Body").child("Nutrition").observeSingleEvent(of: .value, with: {(snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    print("Misc Dictionary")
                    print(dictionary)
                    let protein : Double = dictionary["protein"] as! Double
                    let carbs : Double = dictionary["carbs"] as! Double
                    let fat : Double = dictionary["fat"] as! Double
                    let calories : Double = dictionary["calories"] as! Double
                    
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("protein").setValue(protein + (self.proteinText.text as! NSString).doubleValue)
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("carbs").setValue(carbs + (self.carbsText.text as! NSString).doubleValue)
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("fat").setValue(fat + (self.fatText.text as! NSString).doubleValue)
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("calories").setValue(calories + (self.caloriesText.text as! NSString).doubleValue)
                    self.addFood()
                    self.clearTextfield()
                }
                else{ //init the day with first values and food to DB
                    self.startTheDayRight()
                    self.addFood()
                    self.clearTextfield()
                }
            })
        }
        else{
            self.present(alertController, animated: true, completion: nil)
        }
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
    
    func populateTableView(){
        
        currentFoodHandle =     ref.child("Misc").child("Nutrition").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                print("Table View Dictionary")
                print(dictionary)
                let name = (dictionary["name"] as? String)
                let protein = (dictionary["protein"] as? NSNumber)
                let carbs = (dictionary["carbs"] as? NSNumber)
                let fat = (dictionary["fat"] as? NSNumber)
                let calories = (dictionary["calories"] as? NSNumber)
                
                if(name != nil && protein != nil && carbs != nil && fat != nil && calories != nil){
                    
                    let foodItem = FoodItem(name: name!, protein: protein!.doubleValue, carbs: carbs!.doubleValue, fat: fat!.doubleValue, calories: calories!.doubleValue)
                    self.foodArray.append(foodItem)
                    self.tableView.reloadData()
                    
                }
                    
                else{
                    print("Failed to populate dictionary")
                }
            }
        })
        
        newFoodHandle = ref.child("Misc").child("Nutrition").observe(.childChanged, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                print("Table View Dictionary")
                print(dictionary)
                let name = (dictionary["name"] as? String)
                let protein = (dictionary["protein"] as? NSNumber)
                let carbs = (dictionary["carbs"] as? NSNumber)
                let fat = (dictionary["fat"] as? NSNumber)
                let calories = (dictionary["calories"] as? NSNumber)
                
                if(name != nil && protein != nil && carbs != nil && fat != nil && calories != nil){
                
                    let foodItem = FoodItem(name: name!, protein: protein!.doubleValue, carbs: carbs!.doubleValue, fat: fat!.doubleValue, calories: calories!.doubleValue)
                    self.foodArray.append(foodItem)
                    self.tableView.reloadData()
                    
                }
                
                else{
                    print("Failed to populate dictionary")
                }
            }
        })
    }
    
    func addFoodtoDB(foodName: String){
        
        ref?.child("Misc").child("Nutrition").child(foodName).observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                self.mainDict = dictionary
                print("MainDict")
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
            else{
                let protein : Double = self.mainDict["protein"] as! Double
                let carbs : Double = self.mainDict["carbs"] as! Double
                let fat : Double = self.mainDict["fat"] as! Double
                let calories : Double = self.mainDict["calories"] as! Double
                
                DispatchQueue.main.async {
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("protein").setValue(protein)
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("carbs").setValue(carbs)
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("fat").setValue(fat)
                    self.ref?.child(self.stringDate()).child("Body").child("Nutrition").child("calories").setValue(calories)
                }
            }
            
            
            
            
            
            
        })
    }
    
    
    //MARK: - Search Controller
    
    
    func configureCustomSearchController() {
        
        let frame = CGRect(x: 0.0, y: 0.0, width: uglyTableView.frame.size.width, height: 55.0)
        let font = UIFont(name: "Futura", size: 20.0)!
        let darkBlue = UIColor(red: 13/255, green: 60/255, blue: 85/255, alpha: 1)
        let orange = UIColor(red: 241/255, green: 108/255, blue: 32/255, alpha: 1)

        customSearchController = foodSearchController(searchResultsController: self, searchBarFrame: frame , searchBarFont: font, searchBarTextColor: orange, searchBarTintColor: darkBlue)
        customSearchController.foodSearch.placeholder = "Search Food"
        
        customSearchController.customDelegate = self
        uglyTableView.tableFooterView = customSearchController.foodSearch
        uglyTableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 5
        tableView.keyboardDismissMode = .onDrag
    }
    
    
    func didStartSearching() {
        //shouldShowSearchResults = true
        print("Tapped Start Searching")
        showTableView()
        hideTextField()
        tableView.reloadData()
    }
    
    func didTapOnSearchButton() {
        print("Tapped Search Button")
        tableView.reloadData()
    }
    
    func didTapOnCancelButton() {
        print("Tapped Cancel Button")
        deactivateSearch()
        self.filteredArray.removeAll(keepingCapacity: false)
        hideTableView()
        showTextField()
        tableView.reloadData()
    }
    
    func didChangeSearchText(searchText: String) {
        print("searchTable")
        self.filteredArray.removeAll(keepingCapacity: false)
        self.filteredArray = self.foodArray.filter { foodItem in
            return foodItem.name!.lowercased().contains(searchText.lowercased())
        }
        print(self.filteredArray)
        self.tableView.reloadData()
    }
    
    func deactivateSearch(){
        customSearchController.isActive = false
        customSearchController.foodSearch.text = ""
    }
    
    //MARK: - Table View
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(customSearchController.foodSearch.text != ""){
            return filteredArray.count
        }
        
        else{
            return foodArray.count
        }
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
        
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        var array = [FoodItem]()
        if(customSearchController.foodSearch.text != ""){
            array = filteredArray
        }
        else{
            array = foodArray
        }
        let title = array[indexPath.row].name!
        let calories = array[indexPath.row].calories!
        let protein = array[indexPath.row].protein!
        let carbs = array[indexPath.row].carbs!
        let fat = array[indexPath.row].fat!
        
        cell.titleLabel?.text = title
        cell.calorieLabel?.text = "Calories: " + String(describing: calories)
        cell.proteinLabel?.text = "P: " + String(describing: protein)
        cell.carbsLabel?.text = "C: " + String(describing: carbs)
        cell.fatLabel?.text = "F: " + String(describing: fat)
        cell.reset()
        cell.highlight(macros: [calories, protein, carbs, fat], significant: [700, 100, 40, 75, 30])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var array = [FoodItem]()
        if(customSearchController.foodSearch.text != ""){
            array = filteredArray
        }
        else{
            array = foodArray
        }
        addFoodtoDB(foodName: array[indexPath.row].name!)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        successHaptic()
        deactivateSearch()
        hideTableView()
        showTextField()
    }
    
    func showTableView(){
        UIView.animate(withDuration: 0.5, animations: {
            let darkBlue = UIColor(red: 13/255, green: 60/255, blue: 85/255, alpha: 1)
            self.makeBackgroundColor(color: darkBlue)
            self.tableView.isHidden = false
            self.tableView.frame = CGRect(x: 10, y: 95, width: 354, height: 500)
        })
    }
    
    func hideTableView(){
        UIView.animate(withDuration: 0.5, animations: {
            let lightBlue = UIColor(red: 19/255, green: 149/255, blue: 186/255, alpha: 1)
            self.makeBackgroundColor(color: lightBlue)
            self.tableView.isHidden = true
            self.tableView.frame = self.uglyTableView.frame
        })
    }
    
    //MARK: - Textfield
    
    func setTextFields(){
        nameText = makeTextField(placeholder: "Name", title: "Food Name", y: 100)
        proteinText = makeTextField(placeholder: "Protein", title: "Protein in grams", y: 160)
        carbsText = makeTextField(placeholder: "Carbs", title: "Carbs in grams", y: 220)
        fatText = makeTextField(placeholder: "Fat", title: "Fat in grams", y: 280)
        caloriesText = makeTextField(placeholder: "Calories", title: "Calories", y: 340)
        
        setDecimalPad()
        
        self.view.addSubview(nameText)
        self.view.addSubview(proteinText)
        self.view.addSubview(carbsText)
        self.view.addSubview(fatText)
        self.view.addSubview(caloriesText)
    }
    
    func makeTextField(placeholder:String, title:String, y:CGFloat) -> SkyFloatingLabelTextField{
        
        let darkBlue = UIColor(red: 13/255, green: 60/255, blue: 85/255, alpha: 1)
        let orange = UIColor(red: 241/255, green: 108/255, blue: 32/255, alpha: 1)
        
        let textField = SkyFloatingLabelTextField(frame: CGRect(x:75, y:y, width:200, height:55))
        textField.placeholder = placeholder
        textField.title = title
        textField.tintColor = darkBlue // the color of the blinking cursor
        textField.textColor = darkBlue
        textField.lineColor = UIColor.white
        textField.selectedTitleColor = orange
        textField.placeholderFont = UIFont(name: "Futura", size: 20.0)!
        textField.font = UIFont(name: "Futura", size: 20.0)!
        textField.selectedLineColor = orange
        textField.placeholderColor = UIColor.white
        textField.titleLabel.textColor = UIColor.white
        
        textField.lineHeight = 2.0 // bottom line height in points
        textField.selectedLineHeight = 3.0
        return textField
    }

    func clearTextfield(){
        self.nameText.text = ""
        self.fatText.text = ""
        self.proteinText.text = ""
        self.carbsText.text = ""
        self.caloriesText.text = ""
    }
    
    func setDecimalPad(){
        proteinText.keyboardType = UIKeyboardType.decimalPad
        carbsText.keyboardType = UIKeyboardType.decimalPad
        fatText.keyboardType = UIKeyboardType.decimalPad
        caloriesText.keyboardType = UIKeyboardType.decimalPad
    }
    
    func hideTextField(){
        self.nameText.alpha = 0
        self.proteinText.alpha = 0
        self.carbsText.alpha = 0
        self.fatText.alpha = 0
        self.caloriesText.alpha = 0
        self.addButton.alpha = 0
    }
    
    func showTextField(){
        self.nameText.alpha = 1
        self.proteinText.alpha = 1
        self.carbsText.alpha = 1
        self.fatText.alpha = 1
        self.caloriesText.alpha = 1
        self.addButton.alpha = 1
    }
    
    //MARK: - Button
    
    func setupButton(){
    
        addButton.frame = CGRect(x: 75, y: 425, width: 200, height: 40.0)
        addButton.backgroundColor = UIColor.clear
        addButton.clipsToBounds = true
        addButton.setTitle("Add Food", for: .normal)
        addButton.titleLabel!.font = UIFont(name: "Futura", size: 25)
        addButton.setTitleColor(UIColor.white, for: .normal)
        addButton.addTarget(self, action: #selector(addFunc), for: .touchUpInside)
        view.addSubview(addButton)
        
        let DestructiveAction = UIAlertAction(title: "Yessir", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
            print("Yessir")
        }
        alertController.addAction(DestructiveAction)
    }
    
    func addFunc(){
        animateButton()
        successHaptic()
        updateToFB()
    }
    
    func animateButton(){
        UIView.animate(withDuration: 0.1, animations: { self.addButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) }, completion: { (finish: Bool) in UIView.animate(withDuration: 0.1, animations: { self.addButton.transform = CGAffineTransform.identity }) })
    }
    
    func successHaptic(){
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    
    
    //MARK: - Helper Functions
    func stringDate() -> String{
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: Date())
        
        let year =  components.year
        let month = components.month
        let day = components.day
        
        var monthString = ""
        var dayString = ""
        
        if (day! < 10){
            dayString = "0\(day!)"
        }
        else{
            dayString = "\(day!)"
        }
        if (month! < 10){
            monthString = "0\(month!)"
        }
        else{
            monthString = "\(month!)"
        }
        return monthString + ":" + dayString + ":" + "\(year!)"
    }
    
    func tapDismiss(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func makeBackgroundColor(color: UIColor){
        self.view.backgroundColor = color
        self.uglyTableView.backgroundColor = color
    }

    func colorReference(){
        let darkBlue = UIColor(red: 13/255, green: 60/255, blue: 85/255, alpha: 1)
        let darkBluePattern = UIColor.init(patternImage: UIImage(named: "darkBluePattern.png")!)
        let orange = UIColor(red: 241/255, green: 108/255, blue: 32/255, alpha: 1)
        let orangePattern = UIColor.init(patternImage: UIImage(named: "orangePattern.png")!)
        let lightBlue = UIColor(red: 19/255, green: 149/255, blue: 186/255, alpha: 1)
        let lightBluePattern = UIColor.init(patternImage: UIImage(named: "lightBluePatternShaded.png")!)
        let red = UIColor(red: 216/255, green: 66/255, blue: 38/255, alpha: 1)
        let green = UIColor(red: 60/255, green: 179/255, blue: 113/255, alpha: 1)
    }
}

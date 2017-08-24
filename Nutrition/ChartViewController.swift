//
//  ChartViewController.swift
//  
//
//  Created by Aditya Garg on 12/27/16.
//
//

import UIKit
import Charts
import FirebaseDatabase

class ChartViewController: UIViewController, ChartViewDelegate {
    
    struct Macro{ //names should always be lowercase
        
        var name : String
        var values : [Double] = [Double]()
        var colors : [UIColor] = [UIColor]()
        
        mutating func append(value: Double){
            self.values.append(value)
        }
        
        mutating func append(color: UIColor){
            self.colors.append(color)
        }
        
        init(name: String, value: Double, color: UIColor){
            self.name = name
            self.append(value: value)
            self.append(color: color)
        }
        
        init(name: String){
            self.name = name
        }
        
        init(name: String, value: Double){
            self.name = name
            self.append(value: value)
        }
        
    }
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    var resetButton : UIButton = UIButton(type: .custom)
    var feelingButton : UIButton = UIButton(type: .custom)
    
    var ref : FIRDatabaseReference!
    var refHandle : FIRDatabaseHandle!
    
    var proteinMacro : Double!
    var carbsMacro : Double!
    var fatMacro : Double!
    var dailyCalories : Double!
    var bufferZone : Double!
    var calBufferZone : Double!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        proteinMacro = 150
        carbsMacro = 140
        fatMacro = 74
        dailyCalories = 1902
        bufferZone = 10
        calBufferZone = 50
        
        self.view.backgroundColor = UIColor.white
        self.pieChart.delegate = self
        pieChart.legend.enabled = false
        pieChart.isUserInteractionEnabled = false
        pieChart.layer.cornerRadius = 10
        pieChart.layer.borderWidth = 3
        pieChart.layer.borderColor = UIColor.black.cgColor
        
        //setChart(macros: setMacros(protein: 100, carbs: 100, fat: 1800, calories: 1453)) //make sure these two match
        
        updateFromFB()
        
        
        let buttonHeight = 60.0
        let buttonWidth = 280.0
        let xspacing = 45.0
        let fontSize:CGFloat = 30
        //let buttonColor = UIColor(red: 43, green: 63, blue: 152, alpha: 1)
        let buttonColor = UIColor.black
 
 
        
        resetButton.frame = CGRect(x: xspacing, y: 380, width: buttonWidth, height: buttonHeight)
        resetButton.backgroundColor = buttonColor
        resetButton.clipsToBounds = true
        resetButton.setTitle("Reset", for: .normal)
        resetButton.titleLabel!.font = UIFont(name: "SubwayLogo", size: fontSize)
        resetButton.addTarget(self, action: #selector(resetFunc), for: .touchUpInside)
        view.addSubview(resetButton)
         
        
        /*
        feelingButton.frame = CGRect(x: xspacing, y: 480, width: buttonWidth, height: buttonHeight)
        feelingButton.backgroundColor = buttonColor
        feelingButton.clipsToBounds = true
        feelingButton.setTitle("Not Today", for: .normal)
        feelingButton.titleLabel!.font = UIFont(name: "SubwayLogo", size: fontSize)
        feelingButton.addTarget(self, action: #selector(feelingFunc), for: .touchUpInside)
        view.addSubview(feelingButton)
        */
        
        setupTitle()
    }
    
    func setupTitle(){
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "ScienceFair", size: 50)
        titleLabel.textColor = UIColor.black
    }
    
    
    //MARK: - Chart
    
    func updateFromFB(){
       refHandle = ref?.child(stringDate()).child("Body").child("Nutrition").observe(.value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                print("value")
                print(dictionary)
                
                let protein = (dictionary["protein"] as? NSNumber)
                let carbs = (dictionary["carbs"] as? NSNumber)
                let fat = (dictionary["fat"] as? NSNumber)
                let calories = (dictionary["calories"] as? NSNumber)
                
                if( protein != nil && carbs != nil && fat != nil && calories != nil){
                    
                   self.setChart(macros: self.setMacros(protein: protein!.doubleValue, carbs: carbs!.doubleValue, fat: fat!.doubleValue, calories: calories!.doubleValue))
                }
                    
                else{
                    print("Failed to update from Firebase")
                }
            }
        })
        
    }
    
    func setChart(macros : [Macro]) {
        
        pieChart.noDataText = "Hold on Bro..."
        pieChart.noDataFont = UIFont(name: "SubwayLogo", size: 30)
        pieChart.noDataTextColor = UIColor(red: 13/255, green: 60/255, blue: 85/255, alpha: 1)
        
        pieChart.animate(yAxisDuration: 1.0, easingOption: ChartEasingOption.easeOutCirc)
        
        var vals = [Double]()
        var colors = [UIColor]()
        
        for macro in macros{
            if(macro.name != "calories"){
            vals.append(contentsOf: macro.values)
            colors.append(contentsOf: macro.colors)
            }
        }
        
        
        var yVals: [ChartDataEntry] = [ChartDataEntry]()
        // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
        for i in 0 ..< (vals.count){ //last one is always calories
            yVals.append(BarChartDataEntry(x: Double(i), y: vals[i]))
        }
        
        let dataSet: PieChartDataSet = PieChartDataSet(values: yVals, label: "Macros")
        dataSet.sliceSpace = 0.0
        dataSet.colors = colors
        let data: PieChartData = PieChartData(dataSet: dataSet)
        data.setValueFont(UIFont(name: "SubwayLogo", size: 22.0))
        data.setValueTextColor(UIColor.black)
        
        self.pieChart.data = data
        pieChart.backgroundColor = UIColor.clear
        
        setMacroLabels(macros: macros)
        setCenter(calories: macros[macros.count-1])
        setDescription(text: "")
    }
    
    func setMacros(protein: Double, carbs: Double, fat: Double, calories: Double) -> [Macro]{
        
        let darkBlue = UIColor(red: 13/255, green: 60/255, blue: 85/255, alpha: 1)
        let darkBluePattern = UIColor.init(patternImage: UIImage(named: "darkBluePatternWide.png")!)
        let orange = UIColor(red: 241/255, green: 108/255, blue: 32/255, alpha: 1)
        let orangePattern = UIColor.init(patternImage: UIImage(named: "orangePatternWide.png")!)
        let lightBlue = UIColor(red: 19/255, green: 149/255, blue: 186/255, alpha: 1)
        let lightBluePattern = UIColor.init(patternImage: UIImage(named: "lightBluePatternWide.png")!)
        let red = UIColor(red: 216/255, green: 66/255, blue: 38/255, alpha: 1)
        let green = UIColor(red: 60/255, green: 179/255, blue: 113/255, alpha: 1)
        
        let proteinM = setSpecificMacro(name: "protein", macro: protein, goal: proteinMacro!, colors: ["Shaded":lightBlue, "Striped": lightBluePattern, "Green": green, "Red": red])
        
        let carbsM = setSpecificMacro(name: "carbs", macro: carbs, goal: carbsMacro!, colors: ["Shaded":darkBlue, "Striped": darkBluePattern, "Green": green, "Red": red])
        
        let fatM = setSpecificMacro(name: "fat", macro: fat, goal: fatMacro!, colors: ["Shaded":orange, "Striped": orangePattern, "Green": green, "Red": red])
        
        var caloriesM = setCals(protein: protein, carbs: carbs, fat: fat, calories: calories, colors: ["Green" : green, "Red": red])
    
        return [proteinM, carbsM, fatM, caloriesM]
        
    }
    
    func setSpecificMacro(name: String, macro: Double, goal: Double, colors: [String: UIColor]) -> Macro{
        
        var tempMacro = Macro(name: name)
        if (macro == 0){ //Starting //Same case as "else", only here to distinguish special events for starting
            tempMacro.append(value: macro)
            tempMacro.append(value: goal)
            tempMacro.append(color: colors["Shaded"]!)
            tempMacro.append(color: colors["Striped"]!)
            
        }
        else if(macro >= goal && macro <= (goal + bufferZone)){ //Finished
            tempMacro.append(value: macro)
            tempMacro.append(color: colors["Green"]!)
        }
        else if(macro > (goal + bufferZone)){ //Over
            tempMacro.append(value: macro)
            tempMacro.append(color: colors["Red"]!)
        }
        else{
            tempMacro.append(value: macro)
            tempMacro.append(value: (goal - macro))
            tempMacro.append(color: colors["Shaded"]!)
            tempMacro.append(color: colors["Striped"]!)
        }
        return tempMacro
    }
    
    func setCals(protein: Double, carbs: Double, fat: Double, calories: Double, colors: [String : UIColor]) -> Macro{
        let difference = (dailyCalories - calories)
        var caloriesM = Macro(name: "calories", value: difference)
        
        //Priority is first check if calories are good, then check if macros are over, then finally see if macros are good.
        if (difference <= 0 && difference > -calBufferZone){ //Finished
            caloriesM.append(color: colors["Green"]!)
        }
        /*
        else if(difference <= -calBufferZone || (protein>(proteinMacro+bufferZone)) || (carbs>(carbsMacro+bufferZone)) || (fat>(fatMacro+bufferZone))){ //Over
            caloriesM.append(color: colors["Red"]!)
        }
        else if((protein >= proteinMacro && protein <= (proteinMacro + bufferZone)) || (carbs >= carbsMacro && carbs <= (carbsMacro + bufferZone)) || (fat >= fatMacro && fat <= (fatMacro + bufferZone))){ //Finished Macros
            caloriesM.append(color: colors["Green"]!)
        }
        */
        else if( difference <= -calBufferZone){
            caloriesM.append(color: colors["Red"]!)
        }
            
        else{
            caloriesM.append(color: UIColor.black)
        }
        return caloriesM
    }
    
    func pformatterStuff(){
        //        let pFormatter: NumberFormatter = NumberFormatter()
        //        pFormatter.numberStyle = NumberFormatter.Style.percent
        //        pFormatter.maximumFractionDigits = 1
        //        pFormatter.multiplier = 1.0
        //        pFormatter.percentSymbol = " %"
        //data.setValueFormatter(pFormatter)
    }
    
    //MARK: - Labels
    
    func setMacroLabels(macros : [Macro]){
        print("setMacroLabels")
        var updatedMacros = macros
        updatedMacros.remove(at: updatedMacros.count-1) //hack
        
        let subViews = self.pieChart.subviews
        for subview in subViews{
            if subview.tag == 1000 {
                subview.removeFromSuperview()
            }
        }
        
        let FDEG2RAD = CGFloat(M_PI / 180.0)
        let drawAngles = pieChart.drawAngles
        var absoluteAngles : [CGFloat] = pieChart.absoluteAngles
        absoluteAngles.insert(0, at: 0)
        var center = pieChart.centerCircleBox
        center.x = center.x - 15 //idfg why i have to do this
        center.y = center.y - 11
        let r: CGFloat = pieChart.radius + 30 //distance from center
        var current = 0
        var last = 0
    
        print("drawAngles")
        print(drawAngles)
        print("absoluteAngles")
        print(absoluteAngles)
        print("r: ", r)
        print("center: ", center)
        
        
        for macro in updatedMacros{
            
            current = current + macro.values.count
            let x = center.x + (r * sin((absoluteAngles[last] + ((absoluteAngles[current] - absoluteAngles[last] )/2)) * FDEG2RAD))
            let y = center.y - (r * cos((absoluteAngles[last] + ((absoluteAngles[current] - absoluteAngles[last] )/2)) * FDEG2RAD)) //need to get zero in the frist one
            
            print(macro.name)
            print("count: " ,String(describing: macro.values.count))
            print("current: " , current)
            print("last: " , last)
            print("absolute angle current: " + String(describing: absoluteAngles[current]))
            print("absolute angle last: " + String(describing: absoluteAngles[last]))
            print("sin: ", ( sin((absoluteAngles[last] + ((absoluteAngles[current] - absoluteAngles[last] )/2)) * FDEG2RAD)))
            print("cos: ", ( cos((absoluteAngles[last] + ((absoluteAngles[current] - absoluteAngles[last] )/2)) * FDEG2RAD)))
            print("x,y: " + String(describing: x) + "," + String(describing: y))
            last = current
            
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: { //Should I keep this?
                
                self.drawLabel(xPos: x, yPos: y, name: macro.name)
                self.drawKey(xPos: x, yPos: y, name: macro.name)
                
                }, completion: nil)
        }
        //drawCenterX(xPos: center.x, yPos: center.y)//visually locate center
    }
    
    func drawKey(xPos:CGFloat, yPos:CGFloat, name: String){
        var dict : [String: String] = ["protein" : "lightBlueLabel.png", "carbs" : "darkBlueLabel.png", "fat" : "orangeLabel.png"]
        let image = UIImage(named: dict[name]!)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: xPos-10, y: yPos+10, width: (image?.size.width)!, height: (image?.size.height)!)
        imageView.tag = 1000
        pieChart.addSubview(imageView)
    }
    
    func drawLabel(xPos:CGFloat, yPos:CGFloat, name : String){
    
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 21))
        label.center = CGPoint(x: xPos, y: yPos)
        label.textAlignment = .center
        label.text = name
        label.font = UIFont(name: "SubwayLogo", size: 8)
        label.tag = 1000
        pieChart.addSubview(label)
        
        
    }
    
    func drawCenterX(xPos:CGFloat, yPos:CGFloat){
        let xred = "xmarks.png"
        let image = UIImage(named: xred)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: xPos, y: yPos, width: (image?.size.width)!, height: (image?.size.height)!)
        pieChart.addSubview(imageView)
    }

    
    //MARK: - Center
    
    func setCenter(calories: Macro){
        
        let circleColor = calories.colors[0]
        var textColor = UIColor.black
        var calorieColor = UIColor.black
        
        if(circleColor.isEqual(UIColor.black)){ //Makes sure that text color is visible, maybe add textcolor property to macro?
            textColor = UIColor.white
            calorieColor = UIColor.white
            
        }
        
        
        pieChart.holeRadiusPercent = 0.3
        pieChart.transparentCircleRadiusPercent = 0.0
        let caloriesString = String(describing: Int(calories.values[0]))
        let numberText = NSMutableAttributedString(string:"" + caloriesString + "", attributes: [NSForegroundColorAttributeName:textColor,NSFontAttributeName: UIFont(name: "SubwayLogo",size:32)!])
        pieChart.centerAttributedText = numberText
        setCalorieString(color: calorieColor)
        pieChart.centerTextRadiusPercent = 1.0
        pieChart.holeColor = circleColor
    }
    
    func setDescription(text: String){
        let d = Description()
        d.text = text
        pieChart.chartDescription = d
    }
    
    func setCalorieString(color : UIColor){
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        label.center = CGPoint(x: pieChart.centerCircleBox.x, y: pieChart.centerCircleBox.y+20)
        label.textAlignment = .center
        label.text = "calories left"
        label.font = UIFont(name: "ScienceFair", size: 12)
        label.textColor = color
        pieChart.addSubview(label)
    }
    
    
    //MARK: - Buttons
    
    func resetFunc(){
        print("reset")
        UIView.animate(withDuration: 0.1, animations: { self.resetButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) }, completion: { (finish: Bool) in UIView.animate(withDuration: 0.1, animations: { self.resetButton.transform = CGAffineTransform.identity }) })
        successHaptic()
        ref?.child(stringDate()).child("Body").child("Nutrition").child("protein").setValue(0)
        ref?.child(stringDate()).child("Body").child("Nutrition").child("carbs").setValue(0)
        ref?.child(stringDate()).child("Body").child("Nutrition").child("fat").setValue(0)
        ref?.child(stringDate()).child("Body").child("Nutrition").child("calories").setValue(0)
    }
    
    func feelingFunc(){
        
        UIView.animate(withDuration: 0.1, animations: { self.feelingButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) }, completion: { (finish: Bool) in UIView.animate(withDuration: 0.1, animations: { self.feelingButton.transform = CGAffineTransform.identity }) })
        successHaptic()
        
        ref?.child(stringDate()).child("Body").child("Nutrition").child("protein").setValue(-1)
        ref?.child(stringDate()).child("Body").child("Nutrition").child("carbs").setValue(-1)
        ref?.child(stringDate()).child("Body").child("Nutrition").child("fat").setValue(-1)
        ref?.child(stringDate()).child("Body").child("Nutrition").child("calories").setValue(-1)
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
    
    func successHaptic(){
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func findFontNames(){
        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
    }
    
    func tapDismiss(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        pieChart.endEditing(true)
    }
}

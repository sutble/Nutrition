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

    @IBOutlet weak var pieChart: PieChartView!
    var resetButton : UIButton = UIButton(type: .custom)
    var feelingButton : UIButton = UIButton(type: .custom)
    
    var ref : FIRDatabaseReference!
    var refHandle : FIRDatabaseHandle!
    
    
    
    var proteinMacro : Double!
    var carbsMacro : Double!
    var fatMacro : Double!
    var dailyCalories : Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        proteinMacro = 150.0
        carbsMacro = 140.0
        fatMacro = 73
        dailyCalories = 1902
        
        self.view.backgroundColor = UIColor.white
        self.pieChart.delegate = self
        pieChart.legend.enabled = false
        pieChart.isUserInteractionEnabled = false
        updateFromFB()
        
        let buttonHeight = 60.0
        let buttonWidth = 280.0
        let xspacing = 45.0
        let fontSize:CGFloat = 30
        //let buttonColor = UIColor(red: 43, green: 63, blue: 152, alpha: 1)
        let buttonColor = UIColor.black
        
        resetButton.frame = CGRect(x: xspacing, y: 400, width: buttonWidth, height: buttonHeight)
        resetButton.backgroundColor = buttonColor
        resetButton.clipsToBounds = true
        resetButton.setTitle("Reset", for: .normal)
        resetButton.titleLabel!.font = UIFont(name: "SubwayLogo", size: fontSize)
        resetButton.addTarget(self, action: #selector(resetFunc), for: .touchUpInside)
        view.addSubview(resetButton)
        
        feelingButton.frame = CGRect(x: xspacing, y: 480, width: buttonWidth, height: buttonHeight)
        feelingButton.backgroundColor = buttonColor
        feelingButton.clipsToBounds = true
        feelingButton.setTitle("Not Today", for: .normal)
        feelingButton.titleLabel!.font = UIFont(name: "SubwayLogo", size: fontSize)
        feelingButton.addTarget(self, action: #selector(feelingFunc), for: .touchUpInside)
        view.addSubview(feelingButton)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        print("swag")
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        pieChart.endEditing(true)
    }
    
    func updateFromFB(){
        ref?.child(stringDate()).child("Body").child("Nutrition").observe(.value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                print("dict")
                print(dictionary)
                let protein : Double = dictionary["protein"] as! Double
                let carbs : Double = dictionary["carbs"] as! Double
                let fat : Double = dictionary["fat"] as! Double
                let calories : Double = dictionary["calories"] as! Double
                
                if (protein != -1){
                    self.setChart(vals: self.setMacroVals(protein: protein, carbs: carbs, fat: fat, calories: self.dailyCalories - calories))
                }
                else{
                    self.setChart(vals: [-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0])
                }
                self.setMacroLabels()
            }
        })
    }
    
    
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
    
    func setMacroVals(protein: Double, carbs: Double, fat: Double, calories: Double) -> [Double]{
        return [protein, (proteinMacro - protein), carbs, (carbsMacro - carbs), fat, (fatMacro-fat), calories]
    }
    
    func setMacroLabels(){
        print("setMacroLabels")
        let FDEG2RAD = CGFloat(M_PI / 180.0)
        var drawAngles = pieChart.drawAngles
        var absoluteAngles : [CGFloat] = pieChart.absoluteAngles
        let center = pieChart.centerCircleBox
        let r: CGFloat = pieChart.radius + 30
        
        for i in stride(from: 1, to: absoluteAngles.count, by: 2){
            
            let offset =  (drawAngles[i] + drawAngles[i-1])/2.0
            let x = center.x + (r * sin((absoluteAngles[i] - offset) * FDEG2RAD))
            let y = center.y+4 - (r * cos((absoluteAngles[i] - offset) * FDEG2RAD))
            
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
                
                self.drawLabel(xPos: x, yPos: y, i: (((i+1)/2)-1))
                self.drawKey(xPos: x, yPos: y, i: (((i+1)/2)-1))
                
                }, completion: nil)
        }
        //drawCenterX(xPos: center.x-11, yPos: center.y+4)
    }
    
    func drawKey(xPos:CGFloat, yPos:CGFloat, i: Int){
        let keyArr = ["lightBlueLabel.png","darkBlueLabel.png","orangeLabel.png"]
        let image = UIImage(named: keyArr[i])
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: xPos-10, y: yPos+10, width: (image?.size.width)!, height: (image?.size.height)!)
        pieChart.addSubview(imageView)
    }
    
    func drawLabel(xPos:CGFloat, yPos:CGFloat, i : Int){
        
        var labelArray = ["Protein","Carbs","Fat","a","b","c"]
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 21))
        label.center = CGPoint(x: xPos, y: yPos)
        label.textAlignment = .center
        label.text = labelArray[i]
        label.font = UIFont(name: "SubwayLogo", size: 10)
        pieChart.addSubview(label)
        
        
    }
    
    func drawCenterX(xPos:CGFloat, yPos:CGFloat){
        let xred = "xmarks.png"
        let image = UIImage(named: xred)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: xPos, y: yPos, width: (image?.size.width)!, height: (image?.size.height)!)
        pieChart.addSubview(imageView)
    }
    
    
    func setChart(vals : [Double]) {
        pieChart.animate(yAxisDuration: 1.0, easingOption: ChartEasingOption.easeOutCirc)
        let count = 6
        
        var yVals: [ChartDataEntry] = [ChartDataEntry]()
        // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
        for i in 0 ..< count {
            yVals.append(BarChartDataEntry(x: Double(i), y: vals[i]))
        }
        
        let dataSet: PieChartDataSet = PieChartDataSet(values: yVals, label: "Macros")
        dataSet.sliceSpace = 0.0
        dataSet.colors = setColors()
        
        let data: PieChartData = PieChartData(dataSet: dataSet)
        data.setValueFont(UIFont(name: "SubwayLogo", size: 20.0))
        data.setValueTextColor(UIColor.black)
        
        self.pieChart.data = data
        pieChart.backgroundColor = UIColor.clear
        
        setCenter(calories: Int(vals[6]))
        setDescription(text: "")
    }
    
    func pformatterStuff(){
        //        let pFormatter: NumberFormatter = NumberFormatter()
        //        pFormatter.numberStyle = NumberFormatter.Style.percent
        //        pFormatter.maximumFractionDigits = 1
        //        pFormatter.multiplier = 1.0
        //        pFormatter.percentSymbol = " %"
        //data.setValueFormatter(pFormatter)
    }
    
    func setColors() -> [UIColor] {
        
        let darkBlue = UIColor(red: 13/255, green: 60/255, blue: 85/255, alpha: 1)
        let darkBluePattern = UIColor.init(patternImage: UIImage(named: "darkBluePattern.png")!)
        
        
        let orange = UIColor(red: 241/255, green: 108/255, blue: 32/255, alpha: 1)
        let orangePattern = UIColor.init(patternImage: UIImage(named: "orangePatternShaded.png")!)
        
        
        let lightBlue = UIColor(red: 19/255, green: 149/255, blue: 186/255, alpha: 1)
        let lightBluePattern = UIColor.init(patternImage: UIImage(named: "lightBluePatternShaded.png")!)
        
        return [lightBlue,lightBluePattern,darkBlue,darkBluePattern,orange,orangePattern]
    }
    
    func setCenter(calories:Int){
        
        pieChart.holeRadiusPercent = 0.3
        pieChart.transparentCircleRadiusPercent = 0.0
        let caloriesString = String(describing: calories)
        let centerText = NSAttributedString(string: caloriesString, attributes: [
            NSForegroundColorAttributeName:UIColor.white,NSFontAttributeName: UIFont(name: "SubwayLogo",size:25.0)!])
        pieChart.centerAttributedText = centerText
        pieChart.centerTextRadiusPercent = 1.0
        pieChart.holeColor = UIColor.black
    }
    
    func setDescription(text: String){
        let d = Description()
        d.text = text
        pieChart.chartDescription = d
    }
    
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

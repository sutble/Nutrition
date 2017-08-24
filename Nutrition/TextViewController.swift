//
//  textViewController.swift
//  Nutrition
//
//  Created by Aditya Garg on 12/27/16.
//  Copyright © 2016 garg. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var foodText: UITextView!
    var resetButton : UIButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        tapDismiss()
        
        //setup color
        let orange = UIColor(red: 241/255, green: 108/255, blue: 32/255, alpha: 1)
        self.view.backgroundColor = orange
        
        
        setupLabel()
        setupView()
        setupButton()
        
    }
    
    //MARK: - Button
    
    func setupButton(){
        
        let darkBlue = UIColor(red: 13/255, green: 60/255, blue: 85/255, alpha: 1)
        let lightBlue = UIColor(red: 19/255, green: 149/255, blue: 186/255, alpha: 1)
 
        
        resetButton.frame = CGRect(x: 45.0, y: 550, width: 280.0, height: 60.0)
        resetButton.backgroundColor = darkBlue
        resetButton.clipsToBounds = true
        resetButton.setTitle("Clear", for: .normal)
        resetButton.titleLabel!.font = UIFont(name: "SubwayLogo", size: 30)
        resetButton.setTitleColor(lightBlue, for: .normal)
        resetButton.addTarget(self, action: #selector(resetFunc), for: .touchUpInside)
        view.addSubview(resetButton)
    }
    
    
    
    func resetFunc(){
        animateButton()
        successHaptic()
        foodText.text = ""
    }
    
    func animateButton(){
        UIView.animate(withDuration: 0.1, animations: { self.resetButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) }, completion: { (finish: Bool) in UIView.animate(withDuration: 0.1, animations: { self.resetButton.transform = CGAffineTransform.identity }) })
    }
    
    func successHaptic(){
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    //MARK: - Label
    
    func setupLabel(){
        let darkBlue = UIColor(red: 13/255, green: 60/255, blue: 85/255, alpha: 1)
        let lightBlue = UIColor(red: 19/255, green: 149/255, blue: 186/255, alpha: 1)
        foodLabel.textAlignment = .center
        foodLabel.font = UIFont(name: "SubwayLogo", size: 40)
        foodLabel.textColor = darkBlue
    }
    
    //MARKs: - TextView
    
    func setupView(){
        foodText.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        foodText.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        foodText.keyboardDismissMode = .onDrag
    }
    
    //MARK: - Helper Functions
    
    func tapDismiss(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
    

    

}

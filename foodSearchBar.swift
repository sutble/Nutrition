//
//  foodSearchBar.swift
//  Nutrition
//
//  Created by Aditya Garg on 1/2/17.
//  Copyright © 2017 garg. All rights reserved.
//

import UIKit

class foodSearchBar: UISearchBar {

    var preferredFont: UIFont!
    
    var preferredTextColor: UIColor!
    
    init(frame: CGRect, font: UIFont, textColor: UIColor) {
        super.init(frame: frame)
        
        self.frame = frame
        preferredFont = font
        preferredTextColor = textColor
        
        searchBarStyle = UISearchBarStyle.prominent
        isTranslucent = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func indexOfSearchFieldInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0] as! UIView
        
        for i in 0 ..< searchBarView.subviews.count {
            //isKindOfClass(UITextField) 
            if searchBarView.subviews[i].isKind(of: UITextField.self){
                index = i
                break
            }
        }
        
        return index
    }
    
    override func draw(_ rect: CGRect) {
        // Find the index of the search field in the search bar subviews.
        if let index = indexOfSearchFieldInSubviews() {
            // Access the search field
            let searchField: UITextField = (subviews[0] as! UIView).subviews[index] as! UITextField
            
            // Set its frame.
            //(5.0, 5.0, frame.size.width - 10.0, frame.size.height - 10.0)
            searchField.frame = CGRect(x: 5.0, y: 5.0, width: frame.size.width - 10.0, height: frame.size.height - 10.0)
            
            // Set the font and text color of the search field.
            searchField.font = preferredFont
            searchField.textColor = preferredTextColor
            
            // Set the background color of the search field.
            searchField.backgroundColor = barTintColor
        }
        
        var startPoint = CGPoint(x: 0.0, y: frame.size.height)
        var endPoint = CGPoint(x: frame.size.width, y: frame.size.height)
        var path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        var shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = preferredTextColor.cgColor
        shapeLayer.lineWidth = 5
        
        layer.addSublayer(shapeLayer)
        
        super.draw(rect)
    }

}

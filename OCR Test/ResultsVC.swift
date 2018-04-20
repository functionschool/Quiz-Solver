//
//  ResultsVC.swift
//  OCR Test
//
//  Created by Kousei Richeson on 4/20/18.
//  Copyright © 2018 Kousei Richeson. All rights reserved.
//

import Kanna
import UIKit

class ResultsVC: UIViewController {

    // --------------------------------------------------------------
    // MARK:- Outlets
    // --------------------------------------------------------------
    @IBOutlet weak var questionLabel: UILabel!
    
    
    // --------------------------------------------------------------
    // MARK:- Variables
    // --------------------------------------------------------------
    var question = "Not Segued Correctly."
    
    
    // --------------------------------------------------------------
    // MARK:- Override Functions
    // --------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.text = question
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Recieved a memory warning")
    }
    
    
}

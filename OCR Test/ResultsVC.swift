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
    var boldedQuery: [[String]] = []
    var html: String?
    var question: String?
    var urlLinks: [String] = []
    
    
    // --------------------------------------------------------------
    // MARK:- Override Functions
    // --------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(question == nil) {
            print("Using default Question")
            question = "the main suite of protocols used on the internet is ________."
            // question = "what does API stand for"
        }
        
        questionLabel.text = question
        html = googleSearch(question: question!)
        
        if(html == nil) {
            print("Cannot Continue")
            return
        }
        
        urlLinks = extractLinks()
        boldedQuery = extractBolds()
        
        print()
        print()
        for url in urlLinks {
            print(url)
        }
        
        print()
        print()
        for array in boldedQuery {
            print(array)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Recieved a memory warning")
    }
    
    
    // --------------------------------------------------------------
    // MARK:- Functions
    // --------------------------------------------------------------
    func googleSearch(question: String) -> String? {
        let questionFormatted = (question + " quizlet").replacingOccurrences(of: " ", with: "+")
        let questionURL = "https://www.google.com/search?q=\(questionFormatted)"
        print("Attempting to fetch from: " + questionURL)
        guard let URL = URL(string: questionURL) else {
            print("Error: \(questionURL) doesn't seem to be a valid URL")
            return nil
        }
        do {
            let myHTMLString = try String(contentsOf: URL, encoding: .ascii)
            return myHTMLString
        } catch let error {
            print("Error: \(error)")
            return nil
        }
    }
    
    func extractBolds() -> [[String]] {
        var allBolds: [[String]] = []
        if let doc = try? HTML(html: html!, encoding: .utf8) {
            let xPath = "//span[@class='st']"
            for item in doc.xpath(xPath) {
                var bolds: [String] = []
                if let doc2 = try? HTML(html: item.toHTML!, encoding: .utf8) {
                    let xPath2 = "//span[@class='st']/b"
                    for item2 in doc2.xpath(xPath2) {
                        bolds.append(item2.text!)
                    }
                }
                allBolds.append(bolds)
            }
        }
        return allBolds
    }
    
    func extractLinks() -> [String] {
        var links: [String] = []
        if let doc = try? HTML(html: html!, encoding: .utf8) {
            let xPath = "//div[@class='hJND5c']/cite"
            for item in doc.xpath(xPath) {
                links.append(item.text!)
            }
        }
        return links
    }
    
    func destroyWeirdLetters(text: String) -> String {
        // Change weird space characters normal space character
        var result = text.replacingOccurrences(of: " ", with: " ")
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890–+-=().,!_")
        result = result.filter { okayChars.contains($0) }
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        return result
    }
    
}

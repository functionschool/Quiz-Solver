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
        for i in stride(from: 0, to: urlLinks.count, by: 1) {
            print(i, terminator: ". ")
            print(urlLinks[i])
        }
        print()
        print()
        for i in stride(from: 0, to: boldedQuery.count, by: 1) {
            print(i, terminator:". ")
            print(boldedQuery[i])
        }
        
        let relevantTuple = removeIrrelevants(urls: urlLinks, bolds: boldedQuery)
        urlLinks = relevantTuple.0
        boldedQuery = relevantTuple.1
        
        print()
        print()
        for i in stride(from: 0, to: urlLinks.count, by: 1) {
            print(i, terminator: ". ")
            print(urlLinks[i])
        }
        print()
        print()
        for i in stride(from: 0, to: boldedQuery.count, by: 1) {
            print(i, terminator:". ")
            print(boldedQuery[i])
        }
        
        prioritizeList(urls: urlLinks, bolds: boldedQuery)
        
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
    
    func prioritizeList(urls: [String], bolds: [[String]]) -> ([String], [[String]]) {
        let urlList = urls
        var boldList = bolds
        var indexTracker = [Int]()
        
        for i in stride(from: 0, to: boldList.count, by: 1) {
            var score = 0
            for j in stride(from: 0, to: boldList[i].count, by: 1) {
                let result = boldList[i][j]
                let resultWordCount = result.split(separator: " ").count
                if(score < resultWordCount) {
                    score = resultWordCount
                }
            }
            indexTracker.append(score)
        }
        
        print()
        print(indexTracker)
        
        print()
        let hi = mergeSort(indexTracker, urlList)
        print(hi.0)
        for i in stride(from: 0, to: hi.1.count, by: 1) {
            print(i, terminator:". ")
            print(hi.1[i])
        }

        return (urlList, boldList)
    }
    
    func mergeSort(_ scoreArray: [Int], _ urlArray: [String]) -> ([Int], [String]) {
        
        // Base Case: If array has more than 1 element, continue.
        guard scoreArray.count > 1 else { return (scoreArray, urlArray) }
        
        let middleIndex = scoreArray.count / 2
        
        let leftTuple = mergeSort(Array(scoreArray[0..<middleIndex]), Array(urlArray[0..<middleIndex]))
        let rightTuple = mergeSort(Array(scoreArray[middleIndex..<scoreArray.count]), Array(urlArray[middleIndex..<urlArray.count]))
        
        let leftScoreArray = leftTuple.0
        let rightScoreArray = rightTuple.0
        
        let leftUrlArray = leftTuple.1
        let rightUrlArray = rightTuple.1
        
        // Recursive call.
        return merge(leftScoreArray, rightScoreArray, leftUrlArray, rightUrlArray)
    }
    
    func merge(_ leftScoreArray: [Int], _ rightScoreArray: [Int], _ leftUrlArray: [String], _ rightUrlArray: [String]) -> ([Int], [String]) {
        var leftIndex = 0
        var rightIndex = 0
        var orderedScoreArray: [Int] = []
        var orderedUrlArray: [String] = []
        
        while leftIndex < leftScoreArray.count && rightIndex < rightScoreArray.count {
            let leftScoreElement = leftScoreArray[leftIndex]
            let rightScoreElement = rightScoreArray[rightIndex]
            let leftUrlElement = leftUrlArray[leftIndex]
            let rightUrlElement = rightUrlArray[rightIndex]
            
            if leftScoreElement > rightScoreElement {
                orderedScoreArray.append(leftScoreElement)
                orderedUrlArray.append(leftUrlElement)
                leftIndex += 1
            } else if leftScoreElement < rightScoreElement {
                orderedScoreArray.append(rightScoreElement)
                orderedUrlArray.append(rightUrlElement)
                rightIndex += 1
            } else {
                orderedScoreArray.append(leftScoreElement)
                orderedUrlArray.append(leftUrlElement)
                leftIndex += 1
                orderedScoreArray.append(rightScoreElement)
                orderedUrlArray.append(rightUrlElement)
                rightIndex += 1
            }
        }
        
        while leftIndex < leftScoreArray.count {
            orderedScoreArray.append(leftScoreArray[leftIndex])
            orderedUrlArray.append(leftUrlArray[leftIndex])
            leftIndex += 1
        }
        
        while rightIndex < rightScoreArray.count {
            orderedScoreArray.append(rightScoreArray[rightIndex])
            orderedUrlArray.append(rightUrlArray[rightIndex])
            rightIndex += 1
        }
        
        return (orderedScoreArray, orderedUrlArray)
        
    }
    
    func removeIrrelevants(urls: [String], bolds: [[String]]) -> ([String], [[String]]) {
        var removeTheseIndexes = [Int]()
        var urlList = urls
        var boldList = bolds
        
        for i in stride(from: 0, to: urlLinks.count, by: 1) {
            if (urlList[i].range(of: "...") != nil) {
                removeTheseIndexes.append(i)
            }
            if (urlList[i].range(of: "quizlet.com") == nil) {
                removeTheseIndexes.append(i)
            }
        }
        
        urlList = urlList.enumerated().filter {
            !removeTheseIndexes.contains($0.offset)
        }.map { $0.element }
        
        boldList = boldList.enumerated().filter {
            !removeTheseIndexes.contains($0.offset)
            }.map { $0.element }
        
        return (urlList, boldList)
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
            // For Bing:
            // let xPath = "//div[@class='b_attribution']/cite"
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

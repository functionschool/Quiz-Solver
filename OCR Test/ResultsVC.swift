//
//  ResultsVC.swift
//  OCR Test
//
//  Created by Kousei Richeson on 4/20/18.
//  Copyright © 2018 Kousei Richeson. All rights reserved.
//

import Kanna
import Foundation
import UIKit

class ResultsVC: UIViewController {

    // --------------------------------------------------------------
    // MARK:- Outlets
    // --------------------------------------------------------------
    @IBOutlet weak var questionLabel: UILabel!
    
    
    // --------------------------------------------------------------
    // MARK:- Variables
    // --------------------------------------------------------------
    var question: String?
    
    
    // --------------------------------------------------------------
    // MARK:- Override Functions
    // --------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var boldedQuery: [[String]] = []
        var urlList: [String] = []
        var html: String?
        
        
        if(question == nil) {
            print("Using default Question")
            // question = "the main suite of protocols used on the internet is ________."
            question = "what does API stand for"
            // question = "Who was the first president"
            // question = "a ________ is person who reports a business that is engaged in an illegal activity or an unethical act to a regulatory agency."
        }
        
        questionLabel.text = question
        
//        html = definitiveSearch(question: question!)
//        if(html == nil) {
//            print("Cannot Continue")
//            return
//        }
//        let yoTest = extractDefiniteAnswer(html: html!)
//        print(yoTest)
//        if(yoTest == nil) {
//            print("Poop")
//        } else {
//            return
//        }
        
        html = googleSearch(question: question!)
        
        if(html == nil) {
            print("Cannot Continue")
            return
        }
        
        urlList = extractLinks(html: html!)
        boldedQuery = extractBolds(html: html!)
        
        let relevantTuple = removeIrrelevants(urls: urlList, bolds: boldedQuery)
        urlList = relevantTuple.0
        boldedQuery = relevantTuple.1
        
        let proritiyTuple = prioritizeList(urls: urlList, bolds: boldedQuery)
        urlList = proritiyTuple.0
        boldedQuery = proritiyTuple.1
        
        print()
        print()
        for i in stride(from: 0, to: urlList.count, by: 1) {
            print(i, terminator: ". ")
            print(urlList[i])
        }
        
        let searchQueries = matrixToArray(matrix: boldedQuery)
        
        print()
        print()
        for i in stride(from: 0, to: searchQueries.count, by: 1) {
            print(i, terminator:". ")
            print(searchQueries[i])
        }
        
        let searchQueryScores = scoreSearchQueries(queries: searchQueries)
        
        print()
        for i in stride(from: 0, to: searchQueryScores.count, by: 1) {
            print(i, terminator:". ")
            print(searchQueryScores[i])
        }
        
        var answerArray = [String]()
        
        for i in stride(from: 0, to: searchQueries.count, by: 1) {
            html = quizletSearch(searchFor: searchQueries[i], url: urlList[i])
            if(html == nil) {
                print("Cannot Continue")
                return
            }
            let potentialAnswer = extractAnswer(html: html!, searchFor: searchQueries[i])
            answerArray.append(potentialAnswer ?? "nil")
        }
        
        print()
        print(answerArray)
        
        print()
        print(answerArray)

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
    
    func quizletSearch(searchFor query: String, url quizletUrl: String) -> String? {
        print("Attempting to fetch from: " + quizletUrl)
        guard let URL = URL(string: quizletUrl) else {
            print("Error: \(quizletUrl) doesn't seem to be a valid URL")
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
    
    func matrixToArray(matrix: [[String]]) -> [String] {
        var array = [String]()
        for i in stride(from: 0, to: matrix.count, by: 1) {
            var score = 0
            var insertThis = ""
            for j in stride(from: 0, to: matrix[i].count, by: 1) {
                let element = matrix[i][j]
                let elementWordCount = element.split(separator: " ").count
                if(score < elementWordCount) {
                    insertThis = element
                    score = elementWordCount
                }
            }
            array.append(insertThis)
        }
        return array
    }
    
    func scoreSearchQueries(queries: [String?]) -> [Double] {
        let questionWordCount = Double((question?.split(separator: " ").count)!)
        var queryScores = [Double]()
        for i in stride(from: 0, to: queries.count, by: 1) {
            let queryWordCount = Double((queries[i]?.split(separator: " ").count)!)
            if(queries[i] == nil) {
                queryScores.append(0.0)
            } else if(questionWordCount < queryWordCount) {
                queryScores.append(100.0)
            } else {
                var score = 100.0
                let fraction = queryWordCount / questionWordCount
                score = score * fraction
                queryScores.append(score)
            }
        }
        return queryScores
    }
    
//    func definitiveSearch(question: String) -> String? {
//        let questionFormatted = (question).replacingOccurrences(of: " ", with: "+")
//        let questionURL = "https://www.google.com/search?q=\(questionFormatted)"
//        print("Attempting to fetch from: " + questionURL)
//        guard let URL = URL(string: questionURL) else {
//            print("Error: \(questionURL) doesn't seem to be a valid URL")
//            return nil
//        }
//        do {
//            let myHTMLString = try String(contentsOf: URL, encoding: .ascii)
//            return myHTMLString
//        } catch let error {
//            print("Error: \(error)")
//            return nil
//        }
//    }
//
//    func extractDefiniteAnswer(html: String) -> String? {
//        if let doc = try? HTML(html: html, encoding: .utf8) {
//            let xPath = "//div[@class='Z0LcW']/cite"
//            for item in doc.xpath(xPath) {
//                print("Noice")
//                return item.toHTML
//            }
//        }
//        return nil
//    }
    
    func prioritizeList(urls: [String], bolds: [[String]]) -> ([String], [[String]]) {
        var urlList = urls
        var boldList = bolds
        var scoreTracker = [Float]()
        
        for i in stride(from: 0, to: boldList.count, by: 1) {
            var score: Float = 0.0
            for j in stride(from: 0, to: boldList[i].count, by: 1) {
                let result = boldList[i][j]
                let resultWords = result.components(separatedBy: " ")
                if(score < Float(resultWords.count)) {
                    score = Float(resultWords.count)
                }
            }
            score = score + Float(boldList[i].count-1) * 0.1
            scoreTracker.append(score)
        }
        
        let tuple = mergeSort(scoreTracker, urlList, boldList)
        urlList = tuple.1
        boldList = tuple.2

        return (urlList, boldList)
    }
    
    func mergeSort(_ scoreArray: [Float], _ urlArray: [String], _ boldMatrix: [[String]]) -> ([Float], [String], [[String]]) {
        
        // Base Case: If array has more than 1 element, continue.
        guard scoreArray.count > 1 else { return (scoreArray, urlArray, boldMatrix) }
        
        let middleIndex = scoreArray.count / 2
        
        let leftTuple = mergeSort(Array(scoreArray[0..<middleIndex]), Array(urlArray[0..<middleIndex]), Array(boldMatrix[0..<middleIndex]))
        let rightTuple = mergeSort(Array(scoreArray[middleIndex..<scoreArray.count]), Array(urlArray[middleIndex..<urlArray.count]), Array(boldMatrix[middleIndex..<boldMatrix.count]))
        
        let leftScoreArray = leftTuple.0
        let rightScoreArray = rightTuple.0
        
        let leftUrlArray = leftTuple.1
        let rightUrlArray = rightTuple.1
        
        let leftBoldMatrix = leftTuple.2
        let rightBoldMatrix = rightTuple.2
        
        // Recursive call.
        return merge(leftScoreArray, rightScoreArray, leftUrlArray, rightUrlArray, leftBoldMatrix, rightBoldMatrix)
    }
    
    func merge(_ leftScoreArray: [Float], _ rightScoreArray: [Float], _ leftUrlArray: [String], _ rightUrlArray: [String], _ leftBoldMatrix: [[String]], _ rightBoldMatrix: [[String]]) -> ([Float], [String], [[String]]) {
        var leftIndex = 0
        var rightIndex = 0
        var orderedScoreArray: [Float] = []
        var orderedUrlArray: [String] = []
        var orderedBoldMatrix: [[String]] = []
        
        while leftIndex < leftScoreArray.count && rightIndex < rightScoreArray.count {
            let leftScoreElement = leftScoreArray[leftIndex]
            let rightScoreElement = rightScoreArray[rightIndex]
            let leftUrlElement = leftUrlArray[leftIndex]
            let rightUrlElement = rightUrlArray[rightIndex]
            let leftBoldArray = leftBoldMatrix[leftIndex]
            let rightBoldArray = rightBoldMatrix[rightIndex]
            
            if leftScoreElement > rightScoreElement {
                orderedScoreArray.append(leftScoreElement)
                orderedUrlArray.append(leftUrlElement)
                orderedBoldMatrix.append(leftBoldArray)
                leftIndex += 1
            } else if leftScoreElement < rightScoreElement {
                orderedScoreArray.append(rightScoreElement)
                orderedUrlArray.append(rightUrlElement)
                orderedBoldMatrix.append(rightBoldArray)
                rightIndex += 1
            } else {
                orderedScoreArray.append(leftScoreElement)
                orderedUrlArray.append(leftUrlElement)
                orderedBoldMatrix.append(leftBoldArray)
                leftIndex += 1
                orderedScoreArray.append(rightScoreElement)
                orderedUrlArray.append(rightUrlElement)
                orderedBoldMatrix.append(rightBoldArray)
                rightIndex += 1
            }
        }
        
        while leftIndex < leftScoreArray.count {
            orderedScoreArray.append(leftScoreArray[leftIndex])
            orderedUrlArray.append(leftUrlArray[leftIndex])
            orderedBoldMatrix.append(leftBoldMatrix[leftIndex])
            leftIndex += 1
        }
        
        while rightIndex < rightScoreArray.count {
            orderedScoreArray.append(rightScoreArray[rightIndex])
            orderedUrlArray.append(rightUrlArray[rightIndex])
            orderedBoldMatrix.append(rightBoldMatrix[rightIndex])
            rightIndex += 1
        }
        
        return (orderedScoreArray, orderedUrlArray, orderedBoldMatrix)
        
    }
    
    func removeIrrelevants(urls: [String], bolds: [[String]]) -> ([String], [[String]]) {
        var removeTheseIndexes = [Int]()
        var urlLinks = urls
        var boldList = bolds
        
        for i in stride(from: 0, to: urlLinks.count, by: 1) {
            if (urlLinks[i].range(of: "quizlet.com/") == nil) {
                removeTheseIndexes.append(i)
            }
            else if (urlLinks[i].range(of: "...") != nil) {
                print("Removed a result due to ... error")
                removeTheseIndexes.append(i)
            }
        }
        
        urlLinks = urlLinks.enumerated().filter {
            !removeTheseIndexes.contains($0.offset)
        }.map { $0.element }
        
        boldList = boldList.enumerated().filter {
            !removeTheseIndexes.contains($0.offset)
            }.map { $0.element }
        
        return (urlLinks, boldList)
    }
    
    func extractAnswer(html: String, searchFor query: String) -> String? {
        if let doc = try? HTML(html: html, encoding: .utf8) {
            let xPathSet = "//div[@class='SetPageTerm-content']"
            for set in doc.xpath(xPathSet) {
                if let doc2 = try? HTML(html: set.toHTML!, encoding: .utf8) {
                    var pairArray = [String]()
                    let xPathPair = "//span[@class='TermText notranslate lang-en']"
                    for pair in doc2.xpath(xPathPair) {
                        pairArray.append(pair.text!)
                    }
                    if(pairArray[0].range(of: query) != nil) {
                        return pairArray[1]
                    }
                    if(pairArray[1].range(of: query) != nil) {
                        return pairArray[0]
                    }
                }
            }
        }
        return nil
    }
    
    func extractBolds(html: String) -> [[String]] {
        var allBolds: [[String]] = []
        if let doc = try? HTML(html: html, encoding: .utf8) {
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
    
    func extractLinks(html: String) -> [String] {
        var links: [String] = []
        if let doc = try? HTML(html: html, encoding: .utf8) {
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

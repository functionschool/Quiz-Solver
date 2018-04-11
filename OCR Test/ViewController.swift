//
//  ViewController.swift
//  OCR Test
//
//  Created by Kousei Richeson on 3/27/18.
//  Copyright © 2018 Kousei Richeson. All rights reserved.
//

import UIKit
import CoreImage
import TesseractOCR
import MobileCoreServices
import Kanna

class ViewController: UIViewController, G8TesseractDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    

    var recText = "Error"
    // var testImage = UIImage(named: "HQ3")!
    var currentFilter: CIFilter!
    var context: CIContext!
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imageView.image = imageView.image?.fixOrientation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Recieved a memory warning")
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        showCamera()
    }
    
    @IBAction func readButtonPressed(_ sender: Any) {
        recText = extractText()
        textView.text = recText
    }
    
    @IBAction func addFilter(_ sender: Any) {
        imageView.image = editImage(image: imageView.image!)
    }
    
    func extractText() -> String {
        
        var picture = imageView.image
        
        // picture = editImage(image: picture!)

        picture = picture?.g8_blackAndWhite()
//        picture = sharpenImage(image: picture!, intensity: 1.5)
        
        // picture = picture?.fixOrientation()
        imageView.image = picture
        
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.delegate = self
            // tesseract.image = picture
            tesseract.image = imageView.image
            tesseract.recognize()
            print(tesseract.recognizedText)
            return tesseract.recognizedText
        }
        return "error"
    }
    
    
    func editImage(image: UIImage) -> UIImage {
        var img1: CIImage = CIImage(image: image)!
         // img1 = img1.applyingFilter("CIUnsharpMask", parameters:["inputImage" : img1, "inputIntensity" : intensity])
         img1 = img1.applyingFilter("CINoiseReduction", parameters:["inputImage" : img1, "inputNoiseLevel" : 1.80, "inputSharpness" : 1.20])
        let uiImg = convert(cmage: img1)
        return uiImg
    }
    
    func convert(cmage: CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage, scale: 1.0, orientation: UIImageOrientation.up)
        return image
    }
    
    
//    func findAnswer() {
//        print("A")
//
//        // let processedImage = processImage(image: testImage, intensity: 1.5)
//        let processedImage = testImage
//        print("B")
//        if let tesseract = G8Tesseract(language: "eng") {
//            tesseract.delegate = self
//            // tesseract.image = processedImage.g8_blackAndWhite()
//            tesseract.recognize()
//
//            recText = tesseract.recognizedText
//            // textView.text = recText
//        }
//        print("C")
//        // print(recText)
//        // print("========")
//
//        var array: [String] = []
//        recText.enumerateLines { line, _ in
//            array.append(line)
//        }
//        print("D")
//        print(array)
//        let data = extractData(array: array)
//        var question = data[0]
//        var answer1 = answerFormatter(text: data[1])
//        var answer2 = answerFormatter(text: data[2])
//        var answer3 = answerFormatter(text: data[3])
//        print("E")
//        // MAKE SURE TO MAKE NON-CASE SENSITIVE
//        // REMOVE ALL NON-IMPORTANT WORDS
//
////        question = "According to an infamous 80s hoax, April Fool Day was created by a roman court jester named what"
////        answer1 = answerFormatter(text: "Kugel")
////        answer2 = answerFormatter(text: "constantine")
////        answer3 = answerFormatter(text: "boskin")
//
//        print("F")
//        let questionFormatted = question.replacingOccurrences(of: " ", with: "+")
//        // questionPlus = destroyWeirdLetters(text: questionPlus)
//        let questionURL = "http://www.google.com/search?q=\(questionFormatted)"
//
//
//        print("G")
//        let answer1Words = answer1.split(separator: " ")
//        let answer2Words = answer2.split(separator: " ")
//        let answer3Words = answer3.split(separator: " ")
//
//
//        print("========")
//        print(questionURL)
//        print(question)
//        print(answer1)
//        print(answer2)
//        print(answer3)
//
//        var html = "<p>Default HTML</p>"
//
//        let attemptURL = questionURL
//        guard let URL = URL(string: attemptURL)
//            else {
//                print("Error: \(attemptURL) doesn't seem to be a valid URL")
//                return
//        }
//
//        do {
//            let myHTMLString = try String(contentsOf: URL, encoding: .ascii)
//            // print("HTML : \(myHTMLString)")
//            html = myHTMLString
//        } catch let error {
//            print("Error: \(error)")
//        }
//
//        var score1 = 0
//        var score2 = 0
//        var score3 = 0
//
//        for word in answer1Words {
//            let count = html.components(separatedBy: word).count - 1
//            score1 = score1 + count
//        }
//        score1 = score1 / answer1Words.count
//
//        for word in answer2Words {
//            let count = html.components(separatedBy: word).count - 1
//            score2 = score2 + count
//        }
//        score2 = score2 / answer2Words.count
//
//        for word in answer3Words {
//            let count = html.components(separatedBy: word).count - 1
//            score3 = score3 + count
//        }
//        score3 = score3 / answer3Words.count
//
//        print(score1)
//        print(score2)
//        print(score3)
//
////        scoreA.text = String(score1)
////        scoreB.text = String(score2)
////        scoreC.text = String(score3)
//
//    }
    
//    func editImage(image: UIImage, intensity: NSNumber) -> UIImage {
//        var img1: CIImage = CIImage(image: image)!
//        // img1 = img1.applyingFilter("CIUnsharpMask", parameters:["inputImage" : img1, "inputIntensity" : intensity])
//        img1 = img1.applyingFilter("CIUnsharpMask", parameters:["inputImage" : img1, "inputIntensity" : intensity])
//        let uiImg = convert(cmage: img1)
//        return uiImg
//    }
//
//    func convert(cmage: CIImage) -> UIImage {
//        let context:CIContext = CIContext.init(options: nil)
//        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
//        let image:UIImage = UIImage.init(cgImage: cgImage)
//        return image
//    }
    
    func extractData(array: [String]) -> [String] {
        var elements = [String]()
        var question: String = ""
        var questionFound = false
        var questionIndex = -1
        var trackIndex = -1
        
        // Part 1: Find the Question
        for index in stride(from: array.count-1, through: 0, by: -1) {
            
            if(questionFound == true) {
                break
            }
            
            if(array[index].last == "?") {
                question = array[index]
                questionIndex = index
                for i in stride(from: index-1, through: 0, by: -1) {
                    if(array[i] != "") {
                        question = array[i] + " " +  question
                    } else {
                        elements.append(question)
                        questionFound = true
                        break
                    }
                }
            }
            
        }
        
        // Part 2: Find the Answers
        trackIndex = questionIndex + 1
        while(elements.count != 4) {
            if(trackIndex >= array.count) {
                print("OUT OF BOUNDS ERROR")
                return ["Out","of","Bounds"]
            } else {
                if(array[trackIndex] != "") {
                    elements.append(array[trackIndex])
                }
            }
            trackIndex = trackIndex + 1
        }
        
        return elements
    }
    
    func destroyWeirdLetters(text: String) -> String {
        // Change weird space characters normal space character
        var result = text.replacingOccurrences(of: " ", with: " ")
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890–+-=().,!_")
        result = result.filter { okayChars.contains($0) }
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        return result
    }
    
    func answerFormatter(text: String) -> String {
        var result = text
        // result = result.lowercased()
        result = result.replacingOccurrences(of: " the ", with: " ")
        result = result.replacingOccurrences(of: " of ", with: " ")
        result = result.replacingOccurrences(of: " a ", with: " ")
        result = result.replacingOccurrences(of: " an ", with: " ")
        result = result.replacingOccurrences(of: " and ", with: " ")
        result = result.replacingOccurrences(of: " in ", with: " ")
        result = result.replacingOccurrences(of: "'s", with: "s")
        return result
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Here")
        self.dismiss(animated: true, completion: nil)
        print("Here1")
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let fixedImage = img.fixedOrientation
            imageView.image = fixedImage()
            // imageView.image = img
        }
        print("Here2")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
            //newMedia = true
        }
        else {
            let alert = UIAlertController(title: "Camera Error", message: "No Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }

}






extension UIImage {
    
    func orientate(img: UIImage) -> UIImage {
        
        if (img.imageOrientation == UIImageOrientation.up) {
            return img;
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
        
    }
    
    func fixedOrientation() -> UIImage {
        // No-op if the orientation is already correct
        if (imageOrientation == UIImageOrientation.up) {
            return self
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransform.identity
        
        if (imageOrientation == UIImageOrientation.down
            || imageOrientation == UIImageOrientation.downMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        }
        
        if (imageOrientation == UIImageOrientation.left
            || imageOrientation == UIImageOrientation.leftMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
        }
        
        if (imageOrientation == UIImageOrientation.right
            || imageOrientation == UIImageOrientation.rightMirrored) {
            
            transform = transform.translatedBy(x: 0, y: size.height);
            transform = transform.rotated(by: CGFloat(-Double.pi / 2));
        }
        
        if (imageOrientation == UIImageOrientation.upMirrored
            || imageOrientation == UIImageOrientation.downMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if (imageOrientation == UIImageOrientation.leftMirrored
            || imageOrientation == UIImageOrientation.rightMirrored) {
            
            transform = transform.translatedBy(x: size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx:CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                      bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0,
                                      space: cgImage!.colorSpace!,
                                      bitmapInfo: cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        
        if (imageOrientation == UIImageOrientation.left
            || imageOrientation == UIImageOrientation.leftMirrored
            || imageOrientation == UIImageOrientation.right
            || imageOrientation == UIImageOrientation.rightMirrored
            ) {
            
            
            ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.height,height:size.width))
            
        } else {
            ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.width,height:size.height))
        }
        
        
        // And now we just create a new UIImage from the drawing context
        let cgimg:CGImage = ctx.makeImage()!
        let imgEnd:UIImage = UIImage(cgImage: cgimg)
        
        return imgEnd
    }

    
}


//
//  PictureViewController.swift
//  OCR Test
//
//  Created by Kousei Richeson on 3/27/18.
//  Copyright © 2018 Kousei Richeson. All rights reserved.
//

import CoreImage
import CropViewController
import MobileCoreServices
import TesseractOCR
import UIKit


class PictureVC: UIViewController, UITextFieldDelegate {
    

    // --------------------------------------------------------------
    // MARK:- Outlets
    // --------------------------------------------------------------
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorBackground: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var extractTextButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    
    // --------------------------------------------------------------
    // MARK:- Variables
    // --------------------------------------------------------------
    var context: CIContext!
    var currentFilter: CIFilter!
    var imagePicker: UIImagePickerController!
    var recText: String = "Default Error"
    var currentTime: Double = 0.0
    
    
    // --------------------------------------------------------------
    // MARK:- Override Functions
    // --------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imageView.image = imageView.image?.fixOrientation()
        activityIndicator.isHidden = true
        activityIndicatorBackground.isHidden = true
        activityIndicatorBackground.layer.cornerRadius = 10
        textView.layer.cornerRadius = 10
        cameraButton.layer.cornerRadius = 10
        extractTextButton.layer.cornerRadius = 10
        filterButton.layer.cornerRadius = 10
        goButton.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Recieved a memory warning")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PicturePath" {
            if let destination = segue.destination as? ResultsVC {
                if let text = sender as? String {
                    destination.question = text
                }
            }
        }
    }
    
    
    // --------------------------------------------------------------
    // MARK:- Actions
    // --------------------------------------------------------------
    @IBAction func addFilter(_ sender: Any) {
        imageView.image = applyCINoiseReduction(image: imageView.image!)
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        showCamera()
    }
    
    @IBAction func cropButtonPressed(_ sender: Any) {
        presentCropViewController()
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "PicturePath", sender: textView.text)
    }
    
    @IBAction func readButtonPressed(_ sender: Any) {
        
        activityIndicator.isHidden = false
        activityIndicatorBackground.isHidden = false
        activityIndicator.startAnimating()
        let passedImage = imageView.image
        extractTextButton.isEnabled = false
        textView.isEditable = false
        
        let task = DispatchWorkItem {
            //.... writing stuff in background ....
            self.recText = self.extractText(passedImage: passedImage)
            
            DispatchQueue.main.async {
                //.... done writing stuff, updating ui ....
                self.imageView.image = self.imageView.image?.g8_blackAndWhite()
                self.textView.text = self.recText
                self.activityIndicator.isHidden = true
                self.activityIndicatorBackground.isHidden = true
                self.extractTextButton.isEnabled = true
                self.textView.isEditable = true
            }
        }
        
        DispatchQueue.global().async(execute: task)
        
    }
    
    
}



// --------------------------------------------------------------
// MARK:- Camera Functions
// --------------------------------------------------------------
extension PictureVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let fixedImage = img.fixOrientation
            imageView.image = fixedImage()
        }
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
        }
        else {
            let alert = UIAlertController(title: "Camera Error", message: "No Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
}


// --------------------------------------------------------------
// MARK:- Crop VC Functions
// --------------------------------------------------------------
extension PictureVC: CropViewControllerDelegate {

    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        imageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentCropViewController() {
        let image: UIImage = imageView.image!
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }
    
}


// --------------------------------------------------------------
// MARK:- Image Editing Functions
// --------------------------------------------------------------
extension PictureVC {
    
    func applyCINoiseReduction(image: UIImage) -> UIImage {
        var img1: CIImage = CIImage(image: image)!
        img1 = img1.applyingFilter("CINoiseReduction", parameters:["inputImage" : img1, "inputNoiseLevel" : 1.80, "inputSharpness" : 1.20])
        let uiImg = convert(cmage: img1)
        return uiImg
    }
    
    func applyCIUnsharpMask(image: UIImage) -> UIImage {
        var img1: CIImage = CIImage(image: image)!
        img1 = img1.applyingFilter("CIUnsharpMask", parameters:["inputImage" : img1, "inputIntensity" : 1.00])
        let uiImg = convert(cmage: img1)
        return uiImg
    }
    
    func convert(cmage: CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage, scale: 1.0, orientation: UIImageOrientation.up)
        return image
    }
    
}


// --------------------------------------------------------------
// MARK:- Other Functions
// --------------------------------------------------------------
extension PictureVC {
    
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
    
    func destroyWeirdLetters(text: String) -> String {
        // Change weird space characters normal space character
        var result = text.replacingOccurrences(of: " ", with: " ")
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890–+-=().,!_")
        result = result.filter { okayChars.contains($0) }
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        return result
    }
    
}


// --------------------------------------------------------------
// MARK:- Tesseract Functions
// --------------------------------------------------------------
extension PictureVC: G8TesseractDelegate {

    func extractText(passedImage: UIImage?) -> String {
        if(passedImage == nil) {
            print("Image was nil")
            return ""
        }
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.delegate = self
            tesseract.image = passedImage
            tesseract.recognize()
            print(tesseract.recognizedText)
            return tesseract.recognizedText
        }
        return "error"
    }
    
}





//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Quốc Đạt on 25.08.17.
//  Copyright © 2017 QuocDat. All rights reserved.
//

import UIKit
import os.log
import CoreData

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
         This value is either passed by `MealTableViewController` in `prepare(for:sender:)`
         or constructed as part of adding a new meal.
     */
    var meal: Meal?
    var managedObjectContext: NSManagedObjectContext?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if managedObjectContext == nil {
            managedObjectContext = AppDelegate.shared.persistentContainer.viewContext
        }
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        // Set up views if editing an existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text = meal.name
            photoImageView.image = meal.photo as? UIImage
            ratingControl.rating = Int(meal.rating)
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        guard let managedObjectContext = managedObjectContext else {return}
        if meal == nil {
            // Creat a meal
            meal = Meal(context: managedObjectContext)
        }
        if let meal = meal {
            //ConfigureMeal
            meal.name = nameTextField.text ?? ""
            meal.photo = photoImageView.image
            meal.rating = Int16(ratingControl.rating)
        }
        
    }
    
    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        //Hide The Keyboard
        nameTextField.resignFirstResponder()
        
        
        creatAlert(title: "Choose Photo", message: "Where do you want to choose your Photo ?")
        
    }
    
    //Creat Alert to choose camera or library
    func creatAlert (title: String, message: String) {
        let alert =  UIAlertController ( title: title, message: message, preferredStyle: .alert)
        let takePhotoFromLibary = UIAlertAction(title:"Choose photo from library" , style: .default, handler: { (action) in
            // let users pick photo from library
            
            let imagePickerController = UIImagePickerController()
            
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        })
        
        let takeNewPhoto = UIAlertAction(title: "Take a new photo", style: .default, handler: { (action) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        })
        alert.addAction(takePhotoFromLibary)
        alert.addAction(takeNewPhoto)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
}

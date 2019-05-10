//
//  AppDelegate.swift
//  Notes
//
//  Created by Hooman Ramezani on 2019-04-19.
//  Copyright © 2019 Hooman Ramezani. All rights reserved.
//

import UIKit
import CoreData

class noteViewController: UIViewController, UITextFieldDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var noteInfoView: UIView! // entire info view
    @IBOutlet weak var noteImageViewView: UIView! // entire image view
    
    @IBOutlet weak var noteNameLabel: UITextField! // note name text
    @IBOutlet weak var noteDescriptionLabel: UITextView! // note desc text
    
    @IBOutlet weak var noteImageView: UIImageView! // image box
    
    // object space used to fetch, create and save managed objects
    var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    }
    
    // controller to manage results of core data fetch request and display data to the user
    // used to populate our table
    var notesFetchedResultsController: NSFetchedResultsController<Note>!
    var notes = [Note]()
    var note: Note?
    var isExisting = false // if we need to edit existing note is set to true, if new one is added set to False
    var indexPath: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load data
        // if note exists all these values will be loaded in
        if let note = note {
            noteNameLabel.text = note.noteName // if note is loaded
            noteDescriptionLabel.text = note.noteDescription
            noteImageView.image = UIImage(data: note.noteImage! as Data)

        }
        
        // if theres a name the note is existing, used when we save
        if noteNameLabel.text != "" {
            isExisting = true
        }
        
        // Delegates
        noteNameLabel.delegate = self
        noteDescriptionLabel.delegate = self
        
        // Styles
        noteInfoView.layer.shadowColor =  UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).cgColor
        noteInfoView.layer.shadowOffset = CGSize(width: 2, height: 2)
        noteInfoView.layer.shadowRadius = 2
        noteInfoView.layer.shadowOpacity = 0.2
        noteInfoView.layer.cornerRadius = 5
        
        noteImageViewView.layer.shadowColor =  UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).cgColor
        noteImageViewView.layer.shadowOffset = CGSize(width: 2, height: 2)
        noteImageViewView.layer.shadowRadius = 2
        noteImageViewView.layer.shadowOpacity = 0.2
        noteImageViewView.layer.cornerRadius = 5
        
        noteImageView.layer.cornerRadius = 5
        
        noteNameLabel.setBottomBorder()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // Core data - saves managedobjectcontext
    func saveToCoreData(completion: @escaping ()->Void){
        managedObjectContext!.perform {
            do {
                try self.managedObjectContext?.save() // commits unsaved changes
                completion()
                print("Note saved to CoreData.")
                
            }
            
            catch let error {
                print("Could not save note to CoreData: \(error.localizedDescription)")
                
            }
            
        }
        
    }
    
    // Image Picker
    @IBAction func pickImageButtonWasPressed(_ sender: Any) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self // delegates send messages to self
        pickerController.allowsEditing = true // user can edit image
        
        // pop up that appears when user clicks imageview, choose action to preform
        let alertController = UIAlertController(title: "Add an Image", message: "Choose From", preferredStyle: .actionSheet)
        
        // choose from camera action
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        // choose from photos library
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        // choose from saved photos album
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        // close alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        // add actions to alert controller
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        // present configured alertController view when image is pressed
        present(alertController, animated: true, completion: nil)
        
    }
    
    // called when photo is chosen
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil) // dismisses image picker when selection is made
        
        // if image was chosen set it as the current notes image
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.noteImageView.image = image
            
        }
    }
    
    // called when user selects the cancel button
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }

    // Save
    @IBAction func saveButtonWasPressed(_ sender: UIBarButtonItem) {
        // check if note name is empty or default
        if noteNameLabel.text == "" || noteNameLabel.text == "NOTE NAME" || noteDescriptionLabel.text == "" || noteDescriptionLabel.text == "Note Description..." {
            
            // alert to remind user to fill all fields
            let alertController = UIAlertController(title: "Missing Information", message:"You left one or more fields empty. Please make sure that all fields are filled before attempting to save.", preferredStyle: UIAlertControllerStyle.alert)
            // dismisses the alertcontroller
            // an action that can be taken in the alert
            let OKAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)
            
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        // if not empty proceed to save the note
        else {
            // for brand new note must add to CoreData
            if (isExisting == false) {
                // copy note info
                let noteName = noteNameLabel.text
                let noteDescription = noteDescriptionLabel.text
                
                if let moc = managedObjectContext {
                    // create note in managedObjectContext
                    let note = Note(context: moc)
                    
                    // give managedObjectContext note the information
                    note.noteName = noteName
                    note.noteDescription = noteDescription
                    
                    // if note has an image add it to managedObjectContext in JPEG form
                    if let data = UIImageJPEGRepresentation(self.noteImageView.image!, 1.0) {
                        note.noteImage = data as NSData as Data
                    }
                
                    // save managedObjectContext to store information in CoreData
                    saveToCoreData() {
                        // close the detail view controller
                        
                        // first check if presenting in navigation controller
                        let isPresentingInAddFluidPatientMode = self.presentingViewController is UINavigationController
                        // if in navigation controller dismiss the view controller and navigation controller
                        if isPresentingInAddFluidPatientMode {
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                        // if not pop the view controller and display the tableviewcontroller
                        else {
                            self.navigationController!.popViewController(animated: true)
                            
                        }

                    }

                }
            
            }
            // for existing note
            else if (isExisting == true) {
                
                let note = self.note // note variable from coredata
                
                let managedObject = note
                
                // edit data using setvalue
                managedObject!.setValue(noteNameLabel.text, forKey: "noteName")
                managedObject!.setValue(noteDescriptionLabel.text, forKey: "noteDescription")
                
                if let data = UIImageJPEGRepresentation(self.noteImageView.image!, 1.0) {
                    managedObject!.setValue(data, forKey: "noteImage")
                }
                
                do {
                     // commit changes and return to tableviewcontroller
                    try context.save()
                    
                    let isPresentingInAddFluidPatientMode = self.presentingViewController is UINavigationController
                    
                    if isPresentingInAddFluidPatientMode {
                        self.dismiss(animated: true, completion: nil)
                    }
                    else {
                        self.navigationController!.popViewController(animated: true)
                    }
                }
                
                catch {
                    print("Failed to update existing note.")
                }
            }
        }
    }
    
    // Cancel - return to tableviewcontroller without changing anything
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddFluidPatientMode = presentingViewController is UINavigationController
        
        if isPresentingInAddFluidPatientMode {
            dismiss(animated: true, completion: nil)
            
        }
        
        else {
            navigationController!.popViewController(animated: true)
            
        }
        
    }
    
    // Text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //  dismiss the keyboard when the user taps the return button

        textField.resignFirstResponder()
        return false
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // if return is pressed app hides the keyboard
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
            
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // when you begin editing if textview.text is note description then we set the text to blank
        if (textView.text == "Note Description...") {
            textView.text = ""
            
        }
    }
}

extension UITextField {
    // applies a red bottom border (shadow) to the text element its used on
    func setBottomBorder() {
        // first removes border style and sets background color to white
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        // create a shadow below text field for border
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(red: 245.0/255.0, green: 79.0/255.0, blue: 80.0/255.0, alpha: 1.0).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 0.0
    }
}

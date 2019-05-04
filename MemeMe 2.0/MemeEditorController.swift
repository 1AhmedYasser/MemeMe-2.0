//
//  MemeEditorController.swift
//  MemeMe 1.0
//
//  Created by Ahmed yasser on 4/6/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit

class MemeEditorController: UIViewController, UIImagePickerControllerDelegate ,UINavigationControllerDelegate{

    // MARK: Controller outlets
    @IBOutlet weak var displayedImage: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet var mainView: UIView!
    
    // picker view controller
    var controller: pickerViewController!
    
    // Text field delegate
    let textFieldDelegate = textFieldController()
    // Default meme text attributes
    var memeTextAttributes = [NSAttributedString.Key: Any]()
    
    // Meme to be passed in edit mode and its index in the memes array in the app delegate
    var memeToEdit: MemeModel!
    var memeToEditIndex: Int!
    
    // MARK: View loaded into memory
    // Setup meme text attribute and set "imapact" font as the meme default font with size 40
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup top and bottom textfields
        setupTextField(textField: topTextField)
        setupTextField(textField: bottomTextField)
        
        // Initialize the picker view controller using the 3 argument constructor
        controller = pickerViewController(view: view,top: topTextField,bottom: bottomTextField)
    }
    
    // MARK: Setup Text Fields
    // Add default text attributes and set text alignment and delegate to a text field
    func setupTextField(textField : UITextField){
        memeTextAttributes = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth:  -5
        ]
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = textFieldDelegate
    }
    
    // MARK: save meme
    func save() {
        // Create the meme
        let meme = MemeModel(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: displayedImage.image!, memedImage: generateMemedImage())
        if memeToEdit != nil{
          (UIApplication.shared.delegate as! AppDelegate).memes[memeToEditIndex] = meme
        } else {
          (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
        }
    }
    
    // MARK: dismiss controller
    // Resets the app state to the original state
    @IBAction func cancelImage(_ sender: Any) {
        self.memeToEdit = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Generate meme image
    // Hide toolbars and scale image and render the view to an image and show the toolbars again
    func generateMemedImage() -> UIImage {
        changeContentState(state: true,mode: .scaleToFill)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        changeContentState(state: false, mode: .scaleAspectFit)
        return memedImage
    }
    
    // MARK: Toolbars state
    // A helper method that changes the toolbars hidden state to a given state boolean value
    func changeContentState(state: Bool,mode: UIView.ContentMode){
        topToolBar.isHidden = state
        displayedImage.contentMode = mode
        bottomToolBar.isHidden = state
    }
    
    //  MARK: Share meme
    /*  create a meme image and launch the activity view and pass the memed image to it
        and after completion save the memed image and dismiss the activity view controller
     */
    @IBAction func shareMeme(_ sender: Any) {
        let meme = MemeModel(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: displayedImage.image!, memedImage: generateMemedImage())
        
        let memeImage = meme.memedImage
        let controller = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        controller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
                self.save()
                controller.dismiss(animated: true, completion: nil)
                self.memeToEdit = nil
                self.dismiss(animated: true, completion: nil)
            }else{
                return
            }
        }
        present(controller,animated: true,completion: nil)
    }

    // MARK: View will appear
    /* check if the device has a camera and toogle the camera button accordingly
     and subscribe to keyboard notfications
     */
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
        // If controller is opened in editor mode
        if memeToEdit != nil {
          topTextField.text = memeToEdit.topText
          displayedImage.image = memeToEdit.originalImage
          bottomTextField.text = memeToEdit.bottomText
          shareButton.isEnabled = true
        }
          cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
          subscribeToKeyboardNotifications()
    }
    
    // MARK: View will disappear
    // unsubscribe from keyboard notfications
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
     // MARK: Pick image from photo library or camera
    @IBAction func pickAnImage(_ sender: Any) {
        switch (sender as AnyObject).tag {
        case 0:
            initializeImagePicker(source: .photoLibrary)
        case 1:
            initializeImagePicker(source: .camera)
        default:
            print("Error")
        }
    }
    
    // MARK: Image picker initializer
    /* A helper method: Initializes the image picker controller with a given source type and present it
       and allow editing (Cropping)
     */
    func initializeImagePicker(source: UIImagePickerController.SourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = true
        present(imagePicker,animated: true,completion: nil)
    }
    
    // MARK: Image picked
    // Retreive image from image picker controller and set it as the displayed image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let retrievedImage = info[.editedImage] as? UIImage {
            setDisplayedImage(image: retrievedImage)
        } else if let retrievedImage = info[.originalImage] as? UIImage {
            setDisplayedImage(image: retrievedImage)
        }
    }
    
    // MARK: Set Displayed Image
    // A helper method that change the app state given an ui image and dismiss the image picker controller
    func setDisplayedImage(image: UIImage){
        changeState(state: true, image: image)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Cancel image picker
    // dismiss the image picker controller from view
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Show Picker
    // Calls the picker view controller showPicker() method to show the picker view
    @IBAction func changeFont(_ sender: Any) {
        controller.showPicker()
    }
    
    // MARK: App state change
    // A helper method that sets the displayed image and alter the share and cancel enable property
    func changeState(state: Bool,image: UIImage? = nil){
        displayedImage.image = image
        shareButton.isEnabled = state
        cancelButton.isEnabled = state
    }
    
    // keyboard Settings
    // Activate keyboard notifications on keyboard presence and absence
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Disables keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // if the bottom text field is the first responder then shift the view up
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
        view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    // if the keyboard is dismissed then shift the view back to its original state
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    // Returns the keyboard height as a float value
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
}


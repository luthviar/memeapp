//
//  ViewController.swift
//  memeapp
//
//  Created by Luthfi Abdurrahim on 04/07/21.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var photoLibraryButton: UIBarButtonItem!
    @IBOutlet weak var fontsButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    let DEFAULT_TOP_TEXT : String = "TOP"
    let DEFAULT_BOTTOM_TEXT : String = "BOTTOM"
    let DEFAULT_FIELD_TEXT_SIZE: CGFloat = 40
    let DEFAULT_IMAGE: UIImage = UIImage(named: "chooseImage")!
    
    var memeObjects : [Meme] = []
    var memeTextAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.font : UIFont(name: FontNames.impact.rawValue, size: 40)!,
        NSAttributedString.Key.strokeWidth : -4.0
    ] as [NSAttributedString.Key : Any]
    
    
    let availableFontsWithValue: [String:String] = [
        "Impact" : FontNames.impact.rawValue,
        "Times New Roman" : FontNames.timesNewRoman.rawValue,
        "Comic Sans" : FontNames.comic.rawValue,
        "Papyrus" : FontNames.papyrus.rawValue,
    ]
    
    enum TextFieldPosition: Int {
        case top = 1, bottom
    }
    
    enum BarButtonItemsTag: Int {
        case album, camera, fonts, cancel, share
    }
    
    enum FontNames: String {
        case impact = "impact"
        case timesNewRoman = "TimesNewRomanPSMT"
        case comic = "ComicSansMS"
        case papyrus = "Papyrus"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI(isDefault: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        unsubscribeToKeyboardNotifications()
    }
    
    // MARK: FUNCTION HELPER
    
    func setupUI(isDefault: Bool = true) {
        updateStyleTextField(textField: topTextField, isDefault: isDefault)
        updateStyleTextField(textField: bottomTextField, isDefault: isDefault)
        
        photoLibraryButton.tag = BarButtonItemsTag.album.rawValue
        cameraButton.tag = BarButtonItemsTag.camera.rawValue
        fontsButton.tag = BarButtonItemsTag.fonts.rawValue
        shareButton.tag = BarButtonItemsTag.share.rawValue
        cancelButton.tag = BarButtonItemsTag.cancel.rawValue
        
        topTextField.tag = 1
        bottomTextField.tag = 2
        
        shareButton.isEnabled = false
        imageView.image = DEFAULT_IMAGE
    }
    
    func updateStyleTextField(textField: UITextField, isDefault: Bool = true) {
        textField.defaultTextAttributes = memeTextAttributes
        
        if isDefault {
            topTextField.text = DEFAULT_TOP_TEXT
            bottomTextField.text = DEFAULT_BOTTOM_TEXT
        }
        textField.textAlignment = .center
        textField.autocapitalizationType = .allCharacters
        textField.delegate = self
    }
    
    func pickAnImageFromSource(source: UIImagePickerController.SourceType) {
        //Code To Pick An Image From Source
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    func showPopUpFonts(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for item in availableFontsWithValue {
            
            alert.addAction(UIAlertAction(title: item.key, style: .default, handler: {_ in
                self.memeTextAttributes[NSAttributedString.Key.font] = UIFont(name: item.value, size: self.DEFAULT_FIELD_TEXT_SIZE)!
                self.updateStyleTextField(textField: self.topTextField, isDefault: false)
                self.updateStyleTextField(textField: self.bottomTextField, isDefault: false)
            }))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func share() {
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = { activity, completed, items, error in
            if (completed) {
                self.save()
            }
            self.dismiss(animated: true, completion: nil)
        }
        
        present(activityController, animated: true, completion: nil)
    }
    
    // MARK: IMAGE PICKER CONTROLLER
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            self.imageView.image = image
            self.shareButton.isEnabled = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        //Hide Toolbar And Navigation Bar
        navigationBar.isHidden = true
        toolBar.isHidden = true
        
        // Render View To An Image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Show Toolbar and Navigation Bar
        navigationBar.isHidden = false
        toolBar.isHidden = false
        
        return memedImage
    }
    
    func save() {
        // Create The Meme
        let memedImage = generateMemedImage()
        let memeImageObj = Meme(top: topTextField.text!, bottom: bottomTextField.text!, image: imageView.image, memedImage:memedImage)
        memeObjects.append(memeImageObj)
        // Save meme to array, for future use
        print(memeObjects.count)
        
    }
    
    // MARK: TEXTFIELD PROTOCOLS DELEGATION
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //MAKE ALWAYS CAPITALS
        textField.text = (textField.text! as NSString).replacingCharacters(in: range, with: string.uppercased())

            return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == DEFAULT_TOP_TEXT || textField.text == DEFAULT_BOTTOM_TEXT {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            switch TextFieldPosition(rawValue: textField.tag) {
            case .top:
                textField.text = DEFAULT_TOP_TEXT
            case .bottom:
                textField.text = DEFAULT_BOTTOM_TEXT
            case .none:
                textField.text = ""
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    // MARK: IBACTION
  
    @IBAction func barButtonAction(_ sender: UIBarButtonItem) {
        switch BarButtonItemsTag(rawValue: sender.tag) {
        case .album:
            pickAnImageFromSource(source: .photoLibrary)
        case .camera:
            pickAnImageFromSource(source: .camera)
        case .fonts:
            showPopUpFonts("Choose Font", message: "Let's choose your best font for the meme!")
        case .cancel:
            setupUI(isDefault: true)
        case .share:
            share()
        default:
            showAlert("Sorry, try again.", message: "")
        }
    }
    
    
    // MARK: KEYBOARD HANDLING
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = getKeyboardHeight(notification) * (-1)
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
}

//
//  ViewController.swift
//  Sariah
//
//  Created by Isaiah Turner on 6/24/15.
//  Copyright (c) 2015 Sariah. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var textView: UITextView!
    
    var pg: Firebase!
    var keyboardShowing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        pg = Firebase(url:"https://sariah.firebaseio.com/")
        pg.childByAppendingPath(".info/connected").observeEventType(.Value, withBlock: {
            snapshot in
            println(snapshot)
            var isOnline = snapshot.value as! Bool
            var iconImage: UIImage!
            if (isOnline) {
                self.textView.editable = true
                iconImage = UIImage(named: "Online")
            } else {
                self.textView.editable = false
                iconImage = UIImage(named: "Offline")
            }
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: self.resizeImage(iconImage.imageWithRenderingMode(.AlwaysOriginal), newHeight: 30), style: .Plain, target: self, action: "alertInfo")
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0.925, green: 0.725, blue: 0.165, alpha: 1)
        })
        pg.childByAppendingPath("notes").childByAppendingPath(self.title).observeEventType(.Value, withBlock: {
            snapshot in
            self.textView.text = snapshot.value as? String;
        })
        
    }
    func keyboardShow(n:NSNotification) {
        self.keyboardShowing = true
        
        let d = n.userInfo!
        var r = (d[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        r = self.textView.convertRect(r, fromView:nil)
        self.textView.contentInset.bottom = r.size.height
        self.textView.scrollIndicatorInsets.bottom = r.size.height
    }
    
    @IBAction func save(sender: AnyObject) {
        pg.childByAppendingPath("notes").childByAppendingPath(self.title).setValue(textView.text)
        textView.resignFirstResponder()
    }
    
    func keyboardHide(n:NSNotification) {
        self.keyboardShowing = false
        self.textView.contentInset.bottom = 0
        self.textView.scrollIndicatorInsets.bottom = 0
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertInfo() {
        var controller = UIAlertController(title: "Connection Status", message: "This icon indicates your connection status. You can only edit while online. The last available version will be restored automatically.", preferredStyle: UIAlertControllerStyle.Alert);
        controller.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func textViewDidChange(textView: UITextView) {
        pg.childByAppendingPath("notes").childByAppendingPath(self.title).setValue(textView.text)
    }
    
    func resizeImage(image: UIImage, newHeight: CGFloat) -> UIImage {
        
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}


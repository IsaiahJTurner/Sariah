//
//  NotesTableViewController.swift
//  Sariah
//
//  Created by Isaiah Turner on 6/24/15.
//  Copyright (c) 2015 Sariah. All rights reserved.
//

import UIKit

class NotesTableViewController: UITableViewController {
    var sariah: Firebase!
    var notes = NSMutableArray();
    var isOnline = false
    override func viewDidLoad() {
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.navigationController!.navigationBar.tintColor = UIColor(red: 0.925, green: 0.725, blue: 0.165, alpha: 1)
        sariah = Firebase(url:"https://sariah.firebaseio.com/")
        sariah.childByAppendingPath(".info/connected").observeEventType(.Value, withBlock: {
            snapshot in
            self.isOnline = snapshot.value as! Bool
            var iconImage: UIImage!
            if (self.isOnline) {
                iconImage = UIImage(named: "Online")
            } else {
                iconImage = UIImage(named: "Offline")
            }
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: self.resizeImage(iconImage.imageWithRenderingMode(.AlwaysOriginal), newHeight: 30), style: .Plain, target: self, action: "alertInfo")
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 0.925, green: 0.725, blue: 0.165, alpha: 1)
            self.tableView.reloadData()
        })
        sariah.childByAppendingPath("notes").observeEventType(.ChildRemoved, withBlock: {
            snapshot in
            for note in self.notes {
                if note["name"] as! String == snapshot.key as String {
                    self.notes.removeObject(note)
                }
                self.tableView.reloadData()
            }
        })
        sariah.childByAppendingPath("notes").observeEventType(.Value, withBlock: {
            snapshot in
            self.notes = NSMutableArray()
            if let snap = snapshot.value as? NSDictionary {
                for (title, text) in snap {
                    self.notes.addObject([
                        "name": title,
                        "text": text
                        ])
                }
                println(self.notes);
                self.tableView.reloadData()
            }
        })
    }
    @IBAction func addNote(sender: AnyObject) {
        var alertController = UIAlertController(title: "Create Note", message: "Please enter a title for the note", preferredStyle: UIAlertControllerStyle.Alert);
        var noteTitleTextField:UITextField?
        
        alertController.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Note Title"
            noteTitleTextField = textField
        });
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil));
        alertController.addAction(UIAlertAction(title: "Create", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.sariah.childByAppendingPath("notes").childByAppendingPath(noteTitleTextField!.text).setValue("")
        }));
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showNote", sender: self)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.isOnline
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
        sariah.childByAppendingPath("notes").childByAppendingPath(tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text).removeValue()
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var vc = segue.destinationViewController as? ViewController
        vc?.title = self.tableView.cellForRowAtIndexPath( self.tableView.indexPathForSelectedRow()!)?.textLabel?.text
    }
    override func  tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count;
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        var note = notes.objectAtIndex(indexPath.row) as! NSDictionary
        cell.textLabel?.text = note["name"] as? String
        return cell
    }
    func alertInfo() {
        var controller = UIAlertController(title: "Connection Status", message: "This icon indicates your connection status. You can only edit while online. The last available version will be restored automatically.", preferredStyle: UIAlertControllerStyle.Alert);
        controller.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(controller, animated: true, completion: nil)
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
//
//  FileListTableViewController.swift
//  OnTrack
//
//  Created by Daren David Taylor on 27/09/2015.
//  Copyright © 2015 LondonSwift. All rights reserved.
//

import UIKit

protocol FileListTableViewControllerDelegate {
    func fileListTableViewController(fileListTableViewController: FileListTableViewController, didSelectFile: String)
    func fileListTableViewControllerDidCancel(fileListTableViewController: FileListTableViewController)
}

class FileListTableViewController: UITableViewController {
    
    var delegate: FileListTableViewControllerDelegate?
    
    let fileManager = NSFileManager.defaultManager()
    
    var file:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
    }
    
    @IBAction func didPressCancel(sender: AnyObject) {
        self.delegate?.fileListTableViewControllerDidCancel(self)
    }
    lazy var fileList: [String] = {
        
        do {
            var list = try self.fileManager.contentsOfDirectoryAtPath(NSURL.applicationDocumentsDirectory().path!) as [String]
            
            
            if let file = self.file {
                if let index = list.indexOf(file) {
                    list.removeAtIndex(index)
                }
            }
            
            print(list)
            if let index = list.indexOf("Inbox") {
                list.removeAtIndex(index)
            }
            print(list)
            
            return list
            
        }
        catch {
            print(error)
            
            return [String]()
        }
        
    }()
}

extension FileListTableViewController /* : UITableViewDataSource*/ {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FileListTableViewCellIdentifier", forIndexPath: indexPath) as! FileListTableViewCell
        
        
        let filename = self.fileManager.displayNameAtPath(self.fileList[indexPath.row])
        
        let path:String?
        
        if let url = NSURL(string: filename) {
            
            path = url.URLByDeletingPathExtension?.lastPathComponent
        }
        else {
            path = filename
        }
        
        
        cell.buyButton.hidden = indexPath.row != 2 ? true : false
        
        cell.fileNameLabel.text = path
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fileList.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
}

extension FileListTableViewController /* : UITableViewDelegate*/ {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.fileListTableViewController(self, didSelectFile: self.fileList[indexPath.row])
    }
}

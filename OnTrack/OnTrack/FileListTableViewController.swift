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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
    }
    
    @IBAction func didPressCancel(sender: AnyObject) {
        self.delegate?.fileListTableViewControllerDidCancel(self)
    }
    lazy var fileList: [String] = {
        
        do {
            return try self.fileManager.contentsOfDirectoryAtPath(NSURL.applicationDocumentsDirectory().path!)
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
        cell.fileNameLabel.text = self.fileManager.displayNameAtPath(self.fileList[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fileList.count
    }
}

extension FileListTableViewController /* : UITableViewDelegate*/ {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.fileListTableViewController(self, didSelectFile: self.fileList[indexPath.row])
    }
}

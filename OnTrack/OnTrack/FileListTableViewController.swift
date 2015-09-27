//
//  FileListTableViewController.swift
//  OnTrack
//
//  Created by Daren David Taylor on 27/09/2015.
//  Copyright © 2015 LondonSwift. All rights reserved.
//

import UIKit

class FileListTableViewController: UITableViewController {
    
    let fileManager = NSFileManager.defaultManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
    }
   
    lazy var fileList: [NSURL] = {
       
        
      //  self.fileManager.con
        
   //     return self.fileManager.contentsOfDirectoryAtPath(NSURL.applicationDocumentsDirectory(), in)
     
        return [NSURL]()
        }()
}

extension FileListTableViewController /* : UITableViewDataSource*/ {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FileListTableViewCellIdentifier", forIndexPath: indexPath) as! FileListTableViewCell
        
       //     let path =
        
        
        print(self.fileList)
        
        
            cell.fileNameLabel.text = self.fileManager.displayNameAtPath(self.fileList[indexPath.row].absoluteString)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fileList.count
    }

}
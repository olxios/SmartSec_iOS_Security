//
//  ViewController.swift
//  SmartSecExample_Swift
//
//  Created by Olga Dalton on 07/05/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSURLConnectionDelegate {
    
    @IBOutlet var localImageView : UIImageView!
    @IBOutlet var remoteImageView : UIImageView!
    @IBOutlet var testTextField : UITextField!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NSUserDefaults.standardUserDefaults().setObject("TestObject", forKey: "testKey")
        
        let testValue : AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("testKey")
        println("Retrieve object back \(testValue)")
        
        let plainTestValue : AnyObject? = NSUserDefaults.standardUserDefaults().plainObjectForKey("testKey")
        println("Retrieve plain object back \(plainTestValue)")
        
        loadLocalImage()
        loadRemoteImage()
        performURLRequest()
        accessCoreData()
        
        var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            [unowned self] in self.showSecondViewController()
        })

    }

    private func loadLocalImage() {
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let docsUrl = urls[urls.count-1] as! NSURL
        let path = docsUrl.path!.stringByAppendingPathComponent("test_image.png")
        
        let image = UIImage(named: "test_image")
        let data = UIImagePNGRepresentation(image)
        
        data.writeToFile(path, atomically: true)
        
        let resultImage2 = UIImage(contentsOfFile: path)
        localImageView.image = resultImage2
    }

    private func loadRemoteImage() {
        
        let url = NSURL(string: "http://swiftiostutorials.com/cat_pic.png")
        remoteImageView.sd_setImageWithURL(url, placeholderImage : nil)
    }
    
    private func accessCoreData() {
        
        let entity = TestEntity1.insertNewObjectIfNeeded("test2")
        entity.itemID = "test2"
        entity.attribute1 = 8;
        entity.attribute4 = NSDecimalNumber(mantissa: 100, exponent: 23, isNegative: false)
        entity.attribute6 = 7.6
        entity.attribute7 = "testing attributes :)";
        entity.attribute9 = NSDate()
        
        let testData = "testing data attribute".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        entity.attribute10 = testData!
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.saveContext()
        
        let entity2 = TestEntity1.itemWithID("test2")!
        println("ItemId = \(entity2.itemID)")
        println("Attribute 1 = \(entity2.attribute1)")
        println("Attribute 4 = \(entity2.attribute4)")
        println("Attribute 6 = \(entity2.attribute6)")
        println("Attribute 7 = \(entity2.attribute7)")
        println("Attribute 9 = \(entity2.attribute9)")
        println("Attribute 10 = \(entity2.attribute10)")
    }

    private func performURLRequest() {

        let requestUrl = "https://twitter.com"
        let url = NSURL(string: requestUrl)
        
        let request = NSURLRequest(URL: url!,
            cachePolicy: .ReloadIgnoringLocalCacheData,
            timeoutInterval: 5.0)
        
        let connection = NSURLConnection(request: request, delegate: self)
        connection!.start()
    }

    private func showSecondViewController() {
        
        //enableDebuggerChecks()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewControllerWithIdentifier("SecondViewController") as! UIViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func dismissKeyboard(sender : AnyObject) {
        sender.resignFirstResponder()
    }
    
    // MARK: 
    // MARK: NSURLConnectionDelegate
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("Did fail with error \(error)")
    }
    
    func connection(connection: NSURLConnection, didFinishLoading error: NSError) {
        println("Did finish loading \(connection)")
    }
    
    func connection(connection: NSURLConnection, willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
        
        println("Will send request for auth challenge \(challenge)")
        
        let credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust)
        challenge.sender.useCredential(credential, forAuthenticationChallenge: challenge)

    }
}


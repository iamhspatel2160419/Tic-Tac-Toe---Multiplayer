//
//  ViewController.swift
//  Tic Tac Toe - Multiplayer
//
//  Created by Neesarg Banglawala on 04/03/16.
//  Copyright © 2016 Neesarg Banglawala. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate {
    
    @IBOutlet var fields: [TTTImageView]!
    
    var currentPlayer: String!
    var appDelegate: AppDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handlerReceiveDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        
        setupFields()
        currentPlayer = "x"
        
    }
    
    @IBAction func newGame(sender: AnyObject) {
        resetFields()
        
        let messageDict = ["string": "New Game"]
        do {
            let messageData = try NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
            
            do {
                try appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch {
                print("Error while sending New Game NSJSON notification to connected peers!")
            }
        } catch {
            print("Error while converting messageDict to messageData NSJSONDataObject!")
        }
    }
    
    @IBAction func connectWithPlayer(sender: AnyObject) {
        if appDelegate.mpcHandler.session != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            
            self.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil)
            
        }
    }
    
    func peerChangedStateWithNotification(notification: NSNotification) {
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        
        let state = userInfo.objectForKey("state") as! Int
        
        if state != MCSessionState.Connecting.rawValue {
            self.navigationItem.title = "Connected"
        }
    }
    
    func handlerReceiveDataWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo! as Dictionary
        let receivedData: NSData = userInfo["data"] as! NSData
         do {
            let message = try NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            let senderPeerID: MCPeerID = userInfo["peerID"] as! MCPeerID
            let senderDisplayeName = senderPeerID.displayName
            
            if ((message.objectForKey("string")?.isEqualToString("New Game")) != nil) {
                let alert = UIAlertController(title: "Tic Tac Toe", message: "\(senderDisplayeName) has started new game!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                resetFields()
            } else {
                
                let field: Int? = message.objectForKey("field")?.integerValue
                let player: String? = message.objectForKey("player") as? String
                
                if field != nil && player != nil {
                    fields[field!].player = player
                    fields[field!].setThePlayer(player!)
                    
                    if player == "x" {
                        currentPlayer = "o"
                    } else {
                        currentPlayer = "x"
                    }
                    
                    checkResults()
                }
            }
            
        } catch {
            print("error while receiving and JSON operations!")
        }
    }
    
    func fieldTapped(recognizer: UITapGestureRecognizer) {
        let tappedField = recognizer.view as! TTTImageView
        tappedField.setThePlayer(currentPlayer)
        
        let messageDictionary = ["field": tappedField.tag, "player": currentPlayer]
        
        do {
            
            let messageData = try NSJSONSerialization.dataWithJSONObject(messageDictionary, options: NSJSONWritingOptions.PrettyPrinted)
            do {
                try appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch {
                print("Error while sending data!")
            }
            
        } catch {
            print("Error with NSJSONConversion")
        }
        
        checkResults()
        
    }
    
    func setupFields() {
        for index in 0 ... fields.count - 1 {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: "fieldTapped:")
            gestureRecognizer.numberOfTapsRequired = 1
            
            fields[index].addGestureRecognizer(gestureRecognizer)
        }
    }
    
    func resetFields() {
        for index in 0 ..< fields.count {
            fields[index].image = nil
            fields[index].activated = false
            fields[index].player = ""
        }
        
        currentPlayer = "x"
    }
    
    func checkResults() {
        var winner: String = ""
        
        if fields[0].player == "x" && fields[1].player == "x" && fields[2].player == "x" {
            winner = "x"
        } else if fields[0].player == "o" && fields[1].player == "o" && fields[2].player == "o" {
            winner = "o"
        } else if fields[3].player == "x" && fields[4].player == "x" && fields[5].player == "x" {
            winner = "x"
        } else if fields[3].player == "o" && fields[4].player == "o" && fields[5].player == "o" {
            winner = "o"
        } else if fields[6].player == "x" && fields[7].player == "x" && fields[8].player == "x" {
           winner = "x"
        } else if fields[6].player == "o" && fields[7].player == "o" && fields[8].player == "o" {
            winner = "o"
        } else if fields[0].player == "x" && fields[3].player == "x" && fields[6].player == "x" {
            winner = "x"
        } else if fields[0].player == "o" && fields[3].player == "o" && fields[6].player == "o" {
            winner = "o"
        } else if fields[1].player == "x" && fields[4].player == "x" && fields[7].player == "x" {
            winner = "x"
        } else if fields[1].player == "o" && fields[4].player == "o" && fields[7].player == "o" {
            winner = "o"
        } else if fields[2].player == "x" && fields[5].player == "x" && fields[8].player == "x" {
            winner = "x"
        } else if fields[2].player == "o" && fields[5].player == "o" && fields[8].player == "o" {
            winner = "o"
        } else if fields[0].player == "x" && fields[4].player == "x" && fields[8].player == "x" {
            winner = "x"
        } else if fields[0].player == "o" && fields[4].player == "o" && fields[8].player == "o" {
            winner = "o"
        } else if fields[2].player == "x" && fields[4].player == "x" && fields[6].player == "x" {
            winner = "x"
        } else if fields[2].player == "o" && fields[4].player == "o" && fields[6].player == "o" {
            winner = "o"
        }
        
        if winner != "" {
            let alert = UIAlertController(title: "Tic Tac Toe", message: "The winner is \(winner)", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
                self.resetFields()
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
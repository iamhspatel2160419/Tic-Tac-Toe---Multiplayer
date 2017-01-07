//
//  TTTImageView.swift
//  Tic Tac Toe - Multiplayer
//
//  Created by Neesarg Banglawala on 04/03/16.
//  Copyright © 2016 Neesarg Banglawala. All rights reserved.
//

import UIKit

class TTTImageView: UIImageView {
    var player: String?
    var activated: Bool = false
    
    func setThePlayer(_player: String) {
        self.player = _player
        
        if activated == false {
            if _player == "x" {
                self.image = UIImage(named: "x")
            } else {
                self.image = UIImage(named: "o")
            }
            
            activated = true
        }
    }

}

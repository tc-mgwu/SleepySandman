//
//  GameViewController.swift
//  SleepySandman
//
//  Created by Toni Chen on 1/29/15.
//  Copyright (c) 2015 TonicGames. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
    super.viewDidLoad()
    let scene =
    //create game size
    GameScene(size:CGSize(width: 2048, height: 1536))
   
    let skView = self.view as SKView
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true
    
    //scale game universally
    scene.scaleMode = .AspectFill
    skView.presentScene(scene)
    }
    override func prefersStatusBarHidden() -> Bool {
    return true
    }
}
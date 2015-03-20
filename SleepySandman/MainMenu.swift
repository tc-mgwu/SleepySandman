//
//  MainMenu.swift
//  SleepySandman
//
//  Created by Toni Chen on 3/19/15.
//  Copyright (c) 2015 TonicGames. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenu: SKScene {
    
    
    var _playButton:SKSpriteNode = SKSpriteNode(imageNamed:"Playbutton.png")
    override func didMoveToView(view: SKView) {
        
      
        
        let background = SKSpriteNode(imageNamed:"MainMenu")
        background.position = CGPoint(x:self.size.width/2, y:self.size.height/2)
        self.addChild(background)
        
        
        _playButton.position = CGPoint(x: self.size.width/2, y: self.size.height/3)
      
        self.addChild(_playButton)
    }
    
    func sceneTapped() {
        let myScene = GameScene(size:self.size)
        myScene.scaleMode = scaleMode
        let reveal = SKTransition.doorwayWithDuration(1.5)
        self.view?.presentScene(myScene, transition: reveal)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)  {
        sceneTapped()
    }
    
}
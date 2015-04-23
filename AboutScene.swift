//
//  AboutScene.swift
//  SleepySandman
//
//  Created by Toni Chen on 4/10/15.
//  Copyright (c) 2015 TonicGames. All rights reserved.
//


import Foundation
import SpriteKit

class AboutScene: SKScene {

    let textLabel:SKLabelNode = SKLabelNode(fontNamed: "MERKIN")
    
    override func didMoveToView(view: SKView) {
        
        
        
        
        let background = SKSpriteNode(imageNamed:"background1")
        background.position = CGPoint(x:self.size.width/2, y:self.size.height/2)
        self.addChild(background)
        
        
        let aboutWindow = SKSpriteNode(imageNamed: "AboutWindowInstructions")
        aboutWindow.anchorPoint = CGPointMake(0.5, 0.5)
        aboutWindow.position = CGPointMake(0, 0)
        aboutWindow.xScale = 0.7
        aboutWindow.yScale = 0.7
        background.addChild(aboutWindow)

        
        var backBT = SgButton(normalImageNamed: "BackBT_Normal.png", highlightedImageNamed: "BackBT_Down.png", disabledImageNamed: "BackBT_Inactive.png", buttonFunc: tappedButtonBack)
        backBT.yScale = 1.5
        backBT.xScale = 1.5
        backBT.position = CGPoint(x: aboutWindow.size.width-2200, y: aboutWindow.size.height-1600)
       
        aboutWindow.addChild(backBT)

        
      
        
    }


    func tappedButtonBack(button: SgButton) {
        println("tappedButton tappedButton tag=\(button.tag)")
        let myScene = MainMenu(size:self.size)
        myScene.scaleMode = scaleMode
        let reveal = SKTransition.doorwayWithDuration(1.5)
        self.view?.presentScene(myScene, transition: reveal)
        
    }
    
//    func tappedButton(button: SgButton) {
//        println("tappedButton tappedButton tag=\(button.tag)")
//        let myScene = GameScene(size:self.size) //change this to another scene later--instructions & about
//        myScene.scaleMode = scaleMode
//        let reveal = SKTransition.doorwayWithDuration(1.5)
//        self.view?.presentScene(myScene, transition: reveal)
//        
//    }

}

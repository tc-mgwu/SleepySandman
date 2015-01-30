//
//  GameScene.swift
//  SleepySandman
//
//  Created by Toni Chen on 1/29/15.
//  Copyright (c) 2015 TonicGames. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    //method calls before screen appears
    //do initial set up here
    override func didMoveToView(view: SKView)
    {
        backgroundColor = SKColor.whiteColor()
        let background = SKSpriteNode(imageNamed: "background1")
        addChild(background)
    }

}

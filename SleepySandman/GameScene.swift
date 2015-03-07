//
//  GameScene.swift
//  SleepySandman
//
//  Created by Toni Chen on 1/29/15.
//  Copyright (c) 2015 TonicGames. All rights reserved.
//

import SpriteKit
import Foundation

class GameScene: SKScene {

    let hudHeight: CGFloat = 60
    var score = 0
    let hudLayerNode = SKNode()
    let sandman: SKSpriteNode = SKSpriteNode(imageNamed: "sandman1")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let sandmanMovePointsPerSec: CGFloat = 480.0
    let catMovePointsPerSec:CGFloat = 480.0

    var velocity = CGPointZero
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    let sandmanRotateRadiansPerSec:CGFloat = 4.0 * π
    var invincible = false
    let sandmanAnimation: SKAction
    
    var numberFirst = 0
    var numberSecond = 0

    var equation = 0
    var answer = 0
    var lives = 5
    var gameOver = false
    
    
    let backgroundLayer = SKNode()
    let backgroundMovePointsPerSec: CGFloat = 150.0
    
    let sheep = SheepNode(imageNamed: "sheep")
    
    
    let playerLabel:SKLabelNode = SKLabelNode(fontNamed: "MERKIN")

    
    let sheepCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "Bloop.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "hitCatLady.wav", waitForCompletion: false)


    func setUpUI() {
        let backgroundSize = CGSize(width: size.width, height: hudHeight)
        let backgroundColor = SKColor.blackColor()
        let hudBarBackground = SKSpriteNode(color: backgroundColor, size: backgroundSize)
        
        hudBarBackground.position = CGPoint(x:0, y: size.height - hudHeight)
        hudBarBackground.anchorPoint = CGPointZero
        hudLayerNode.addChild(hudBarBackground)
       
    
    }
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin,
            width: size.width,
            height: playableHeight) // 4
        
        //animate character
        //create array to store all textures
        var textures:[SKTexture] = []
        //string setup
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "sandman\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
       sandmanAnimation = SKAction.repeatActionForever(
            SKAction.animateWithTextures(textures, timePerFrame: 0.1))
        
        super.init(size: size) // 5

        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    
    override func didMoveToView(view: SKView)
    {
        playBackgroundMusic("BackgroundMusic.mp3")
        backgroundLayer.zPosition = -1
        addChild(backgroundLayer)
        backgroundColor = SKColor.whiteColor()
        
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPointZero
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            backgroundLayer.addChild(background)
        }

        sandman.zPosition = 100
        sandman.position = CGPoint(x: 400, y: 400)
        backgroundLayer.addChild(sandman)
       
        spawnEquation()
        
        
        //spawn enemies forever
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnEnemy),
                SKAction.waitForDuration(2.0)])))
       
        //spawn sheep forever
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnSheep),
            SKAction.waitForDuration(2.0)])))

    }
    
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPointZero
        backgroundNode.name = "background"
        // 2
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPointZero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        // 3
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPointZero
        background2.position =
            CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        // 4
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        return backgroundNode
        
    }
    override func update(currentTime: NSTimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime

        if let lastTouch = lastTouchLocation {
            let diff = lastTouch - sandman.position
            /*if (diff.length() <= sandmanMovePointsPerSec * CGFloat(dt)) {
            sandman = lastTouchLocation!
            velocity = CGPointZero
            stopsandmanAnimation()
            } else {*/
            moveSprite(sandman, velocity: velocity)
//            rotateSprite(sandman, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
            //}
        }
        
        boundsCheckSandman()
        moveTrain()
        moveBackground()
        checkCollisions()
        
        
        if lives <= 0 && !gameOver {
            gameOver = true
            println("You lose!")
            backgroundMusicPlayer.stop()
            
            
            // create a new scene by creating an instance of the new scene itself
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            
            // create a transition object
            let reveal = SKTransition.crossFadeWithDuration(0.5)
            
            //call SKview's presentScene(transition:) method
            view?.presentScene(gameOverScene, transition: reveal)
            
        }
    }

    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    
    func moveSandmanToward(location: CGPoint)
    {
        startSandmanAnimation()
        let offset = location - sandman.position
        let direction = offset.normalized()
        velocity = direction * sandmanMovePointsPerSec
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveSandmanToward(touchLocation)
    }
    
    override func touchesBegan(touches: NSSet,
        withEvent event: UIEvent) {
            let touch = touches.anyObject() as UITouch
            let touchLocation = touch.locationInNode(backgroundLayer)
            sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: NSSet,
        withEvent event: UIEvent) {
            let touch = touches.anyObject() as UITouch
            let touchLocation = touch.locationInNode(backgroundLayer)
            sceneTouched(touchLocation)
    }
    
    func boundsCheckSandman() {
        let bottomLeft = backgroundLayer.convertPoint(
            CGPoint(x: 0, y: CGRectGetMinY(playableRect)),
            fromNode: self)
        let topRight = backgroundLayer.convertPoint(
            CGPoint(x: size.width, y: CGRectGetMaxY(playableRect)),
            fromNode: self)
        
        
        if sandman.position.x <= bottomLeft.x {
            sandman.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if sandman.position.x >= topRight.x {
            sandman.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if sandman.position.y <= bottomLeft.y {
            sandman.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if sandman.position.y >= topRight.y {
            sandman.position.y = topRight.y
            velocity.y = -velocity.y
        } 
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        // Your code here!
        let shortest = shortestAngleBetween(sprite.zRotation, velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    
    //SPAWN ENEMY
    func spawnEnemy()
    {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        let enemyScenePos = CGPoint(
            x: size.width + enemy.size.width/2,
            y: CGFloat.random(
                min: CGRectGetMinY(playableRect) + enemy.size.height/2,
                max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
        enemy.position = backgroundLayer.convertPoint(enemyScenePos, fromNode: self)
        backgroundLayer.addChild(enemy)
        
        let actionMove = SKAction.moveByX(-size.width-enemy.size.width, y: 0, duration: 2.0)
        //removes enemy
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
    }
    
    //MAIN CHARACTER ANIMATION: tags animation key
    func startSandmanAnimation()
    {
        if sandman.actionForKey("animation") == nil
        {
        sandman.runAction(
            SKAction.repeatActionForever(sandmanAnimation),
            withKey: "animation")
        }
    }
    //stops animation with key "animation"
    func stopSandmanAnimation() {
        sandman.removeActionForKey("animation")
    }

    //SPAWN SHEEP
    func spawnSheep()
    {
//        var sheepValue: Int = 0
        //spawn sheep at random location
//        let sheep = SKSpriteNode(imageNamed: "sheep")
        
        let sheep = SheepNode(imageNamed: "sheep")
        sheep.name = "sheep"
        let sheepScenePos = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(playableRect)-50,
                            max: CGRectGetMaxX(playableRect)-50),
            y: CGFloat.random(min: CGRectGetMinY(playableRect)-50,
                            max: CGRectGetMaxY(playableRect)-50))
        sheep.position = backgroundLayer.convertPoint(sheepScenePos, fromNode: self)
        sheep.setScale(0)
        backgroundLayer.addChild(sheep)
        
        //scale Sheep up
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        sheep.zRotation = -π / 16.0
        
        //rotate left, then reverse for rotate right- repeat actions in seq
        let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        //sets up wiggle and scale at same time
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        sheep.runAction(SKAction.sequence(actions))
        
//        var sheepValue: Int = Int(arc4random_uniform(UInt32(12))+1)
        //generate number between 1-12 and print as string
        sheep.sheepValue = Int(arc4random_uniform(UInt32(12))+1)

        let myString = String(sheep.sheepValue)
        let sheepLabel = SKLabelNode(fontNamed: "MERKIN")
        sheepLabel.name = "sheepmathproblem"
        sheepLabel.fontColor = SKColor.darkGrayColor()
        sheepLabel.fontSize = 30
        sheepLabel.text = myString

        sheep.addChild(sheepLabel)
        println("sheepValue: \(sheep.sheepValue)")
        
   
    }
    
    func spawnEquation() {
    //change global vars of n1 and n2 by casting uint32 as ints to pick random from 1-5
    self.numberFirst = Int(arc4random_uniform(UInt32(6))+1)
    self.numberSecond = Int(arc4random_uniform(UInt32(6))+1)
    self.equation = numberFirst + numberSecond
    //Debug things- print numbers in console
    println("numberFirst: \(self.numberFirst)")
    println("numberSecond: \(self.numberSecond)")

    self.answer = self.equation
    println("equation: \(self.equation)")
        
    //convert int to string using formatter
    let equationString = String(format: "%d + %d", numberFirst, numberSecond)
     
    //player equation label
    let sandmanEquation = self.equation
    playerLabel.text = equationString
    playerLabel.fontColor = SKColor.darkGrayColor()
    playerLabel.position = CGPoint(x:sandman.size.width-135, y:sandman.size.height-345)
    playerLabel.fontSize = 32;
    sandman.addChild(playerLabel)
    
    }
    
    func sandmanHitSheep(sheep: SKSpriteNode) {
      
        runAction(sheepCollisionSound)
        sheep.name = "train"
        sheep.removeAllActions()
        sheep.setScale(1)
        sheep.zRotation = 0
//        let turnColor = SKAction.colorizeWithColor(SKColor.blueColor(), colorBlendFactor: 1.0, duration: 0.2)
//            sheep.runAction(turnColor)
        
        sheep.removeAllChildren()
        sandman.removeAllChildren()
        spawnEquation()
    
    }
    
    
    func sandmanHitEnemy(enemy: SKSpriteNode) {
        runAction(enemyCollisionSound)
        loseSheep()
        lives--
        
        invincible = true
       
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime) % slice
            node.hidden = remainder > slice / 2
        }
        let setHidden = SKAction.runBlock() {
            self.sandman.hidden = false
            self.invincible = false
        }
        sandman.runAction(SKAction.sequence([blinkAction, setHidden]))
   
    }
    
    func checkCollisions() {
        var hitSheep: [SheepNode] = []
        backgroundLayer.enumerateChildNodesWithName("sheep") { node, _ in
            
        let sheep = node as SheepNode
       
        if CGRectIntersectsRect(sheep.frame, self.sandman.frame) {
            
        if sheep.sheepValue == self.equation {
//            println("sheepValue: \(sheep.sheepValue)")
//            println("equation: \(self.equation)")
            hitSheep.append(sheep)
            
            }
        
        }
     
        }
        for sheep in hitSheep {
        sandmanHitSheep(sheep)
        }
        
        if invincible {
        return
        }
                
        var hitEnemies: [SKSpriteNode] = []
        backgroundLayer.enumerateChildNodesWithName("enemy") { node, _ in
        let enemy = node as SKSpriteNode
        if CGRectIntersectsRect(
        CGRectInset(node.frame, 20, 20), self.sandman.frame) {
        hitEnemies.append(enemy)
        }
        }
        for enemy in hitEnemies {
        sandmanHitEnemy(enemy)
        }
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func moveTrain() {
        var targetPosition = sandman.position
        var trainCount = 0
            
        backgroundLayer.enumerateChildNodesWithName("train") {
            node, _ in
            trainCount++
        
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catMovePointsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.runAction(moveAction)
            }
            targetPosition = node.position
        }
            
            if trainCount >= 10 && !gameOver {
                gameOver = true
                println("You win!")
                
                backgroundMusicPlayer.stop()
                // create a new scene by creating an instance of the new scene itself
                let gameOverScene = GameOverScene(size: size, won: true)
                gameOverScene.scaleMode = scaleMode
                
                // create a transition object
                let reveal = SKTransition.crossFadeWithDuration(0.5)
              
                //call SKview's presentScene(transition:) method
                view?.presentScene(gameOverScene, transition: reveal)
                
            }
    }
    
    func loseSheep() {
        // variable to track number of sheep removed from line
        var loseCount = 0
        backgroundLayer.enumerateChildNodesWithName("train") { node, stop in
           
            // find random offset from sheep's current pos
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            // run animation to make sheep move toward a random spot, spin around
            //and scale to 0, then remove sheep from scene. set sheep's name to an 
            //empty string so it's not longer considered a sheep
            node.name = ""
            node.runAction(
                SKAction.sequence([
                SKAction.group([
                    SKAction.rotateByAngle(π*4, duration: 1.0),
                    SKAction.moveTo(randomSpot, duration: 1.0),
                    SKAction.scaleTo(0, duration: 1.0)
                    ]),
                SKAction.removeFromParent()
                ]))
            // update variable that is tracking the number of sheep you've removed
            //once you remove 2 or more, stop enumerating line of sheep
            loseCount++
            if loseCount >= 2 {
                stop.memory = true
            }
        }
    }


    
    func moveBackground() {
        let backgroundVelocity =
        CGPoint(x: -backgroundMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        backgroundLayer.position += amountToMove
        
        
        backgroundLayer.enumerateChildNodesWithName("background") { node, _ in
            let background = node as SKSpriteNode
            let backgroundScreenPos = self.backgroundLayer.convertPoint(
                background.position, toNode: self)
            if backgroundScreenPos.x <= -background.size.width {
                background.position = CGPoint (
                    x: background.position.x + background.size.width*2,
                    y: background.position.y)
                }
            }
        }
    
}


class SheepNode: SKSpriteNode
{
    var sheepValue:Int = 0
    
}
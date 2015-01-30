//
//  GameScene.swift
//  SleepySandman
//
//  Created by Toni Chen on 1/29/15.
//  Copyright (c) 2015 TonicGames. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    
    let zombie: SKSpriteNode = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPointZero
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
    
    let zombieAnimation: SKAction
    
    
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
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
        zombieAnimation = SKAction.repeatActionForever(
            SKAction.animateWithTextures(textures, timePerFrame: 0.1))
        
        super.init(size: size) // 5
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    override func didMoveToView(view: SKView)
    {
        backgroundColor = SKColor.whiteColor()
        
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        //background.zRotation = CGFloat(M_PI) / 8
        background.zPosition = -1
        addChild(background)
        
        let mySize = background.size
        println("Size: \(mySize)")
        
        zombie.position = CGPoint(x: 400, y: 400)
        addChild(zombie)
        
        //spawn enemies forever
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnEnemy),
                SKAction.waitForDuration(2.0)])))
       
        //spawn sheep forever
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnSheep),
            SKAction.waitForDuration(1.0)])))
        
//        zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
//        debugDrawPlayableArea()
    }
    
    override func update(currentTime: NSTimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        println("\(dt*1000) milliseconds since last update")
        
        if let lastTouch = lastTouchLocation
        {
            let diff = lastTouch - zombie.position
            if (diff.length() <= zombieMovePointsPerSec * CGFloat(dt))
            {
                zombie.position = lastTouchLocation!
                velocity = CGPointZero
                stopZombieAnimation()
            }
            else
            {
                moveSprite(zombie, velocity: velocity)
                rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
            }
        }
        
        boundsCheckZombie()
        checkCollisions()
        
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        println("Amount to move: \(amountToMove)")
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint)
    {
        startZombieAnimation()
        let offset = location - zombie.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    
    override func touchesBegan(touches: NSSet,
        withEvent event: UIEvent) {
            let touch = touches.anyObject() as UITouch
            let touchLocation = touch.locationInNode(self)
            sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: NSSet,
        withEvent event: UIEvent) {
            let touch = touches.anyObject() as UITouch
            let touchLocation = touch.locationInNode(self)
            sceneTouched(touchLocation)
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0,
            y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width,
            y: CGRectGetMaxY(playableRect))
        
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
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
        enemy.position = CGPoint(
            x: size.width + enemy.size.width/2,
            y: CGFloat.random(
                min: CGRectGetMinY(playableRect) + enemy.size.height/2,
                max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
        addChild(enemy)
        
        let actionMove =
        SKAction.moveToX(-enemy.size.width/2, duration: 3.5)
        //removes enemy
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
    }
    
    //MAIN CHARACTER ANIMATION: tags animation key
    func startZombieAnimation()
    {
        if zombie.actionForKey("animation") == nil
        {
        zombie.runAction(
            SKAction.repeatActionForever(zombieAnimation),
            withKey: "animation")
        }
    }
    //stops animation with key "animation"
    func stopZombieAnimation() {
        zombie.removeActionForKey("animation")
    }

    //SPAWN SHEEP
    func spawnSheep()
    {
        //spawn cat at random location
        let sheep = SKSpriteNode(imageNamed: "sheep")
        sheep.name = "sheep"
        sheep.position = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(playableRect),
                max: CGRectGetMaxX(playableRect)),
            y: CGFloat.random(min: CGRectGetMinY(playableRect),
                max: CGRectGetMaxY(playableRect)))
        
        sheep.setScale(0)
        addChild(sheep)
        
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
   
    }
    
    
    func zombieHitSheep(sheep: SKSpriteNode) {
        sheep.removeFromParent()
    }
    func zombieHitEnemy(enemy: SKSpriteNode) {
        enemy.removeFromParent()
    }
    
    func checkCollisions() {
        var hitSheep: [SKSpriteNode] = []
        enumerateChildNodesWithName("sheep") { node, _ in
        let sheep = node as SKSpriteNode
       
        if CGRectIntersectsRect(sheep.frame, self.zombie.frame) {
        hitSheep.append(sheep)
        }
        }
        for sheep in hitSheep {
        zombieHitSheep(sheep)
        }
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodesWithName("enemy") { node, _ in
        let enemy = node as SKSpriteNode
        if CGRectIntersectsRect(
        CGRectInset(node.frame, 20, 20), self.zombie.frame) {
        hitEnemies.append(enemy)
        }
        }
        for enemy in hitEnemies {
        zombieHitEnemy(enemy)
        }
    }
    
    
    
    
    
}

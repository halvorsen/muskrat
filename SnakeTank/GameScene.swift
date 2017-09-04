//
//  GameScene.swift
//  plinker
//
//  Created by Aaron Halvorsen on 6/24/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

protocol refreshDelegate: class {
    func gameOver()
    func changeScore(amount: Int)
    
}

class GameScene: SKScene, BrothersUIAutoLayout, SKPhysicsContactDelegate {
    var continueFollowing = true
    var playerBounce = [AVAudioPlayer]()
    var playerPing = [AVAudioPlayer]()
    var viewController: GameViewController!
    var delegateRefresh: refreshDelegate?
    var on = false
    private let ballRadius:CGFloat = 3
    var snakeTail = [SKShapeNode]()
    var boundaries = [SKShapeNode]()
    var startTouchLocation = CGPoint(x: 0, y: 0)
    var endTouchLocation = CGPoint(x: 0, y: 0)
    var boundary = SKShapeNode()
    var timer1 = Timer()
    var timer2 = Timer()
    var timer3 = Timer()
    var swipeUp = UISwipeGestureRecognizer()
    var swipeDown = UISwipeGestureRecognizer()
    var swipeLeft = UISwipeGestureRecognizer()
    var swipeRight = UISwipeGestureRecognizer()
    var tap = UITapGestureRecognizer()
    var snakeHead = SKShapeNode()
    var topFoodAmount = 8
    
    override init(size: CGSize) {
        super.init(size: size)
        tap = UITapGestureRecognizer(target: self, action: #selector(GameScene.fireFunc(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    
//    override func didMove(to view: SKView) {
//        
//        
//        
//    }
    
    var foodArray = [SKShapeNode]()
    var foodLabels = [SKLabelNode]()
    let foodSize: CGFloat = 3.5
    private func addFood(value: Int) {
        let randomX = CGFloat(arc4random_uniform(370))*sw
        let randomY = CGFloat(arc4random_uniform(662))*sh
        let rect = CGRect(x: 0, y: 0, width: foodSize*ballRadius*sw, height: foodSize*ballRadius*sw)
        let food = SKShapeNode(rect: rect, cornerRadius: sw)
        
        food.position = CGPoint(x: randomX, y: randomY)
        food.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
        food.physicsBody?.categoryBitMask = 10
        food.physicsBody?.collisionBitMask = 0
        
        
        food.zPosition = 10000
        
        let myLabel = SKLabelNode(fontNamed:"HelveticaNeue-Bold")
        myLabel.text = String(value)
        myLabel.fontSize = 7*fontSizeMultiplier
        myLabel.horizontalAlignmentMode = .center
        myLabel.verticalAlignmentMode = .center
        myLabel.position = CGPoint(x: 0.5*foodSize*ballRadius*sw, y: foodSize*ballRadius*sw/2)
        myLabel.zPosition = 10001
        myLabel.fontColor = .white
        foodArray.append(food)
        foodLabels.append(myLabel)
        
        food.addChild(myLabel)
        addChild(food)
    }
    
    let monsterDictionary : [Int:Monster] = [
        0:.zombie,
        1:.eagle,
        2:.butterfly,
        3:.tiger,
        4:.mouse,
        5:.deer
    ]
    
    @objc private func addRandomMonster() {
        
        let random = Int(arc4random_uniform(6))
        addMonster(type: monsterDictionary[random]!)
        if monsterDictionary[random]! == .zombie {
            addMonster(type: .zombie)
            addMonster(type: .zombie)
        } else if monsterDictionary[random]! == .butterfly {
            addMonster(type: .butterfly)
        }
    }
    var isFirstTap = true
    @objc func fireFunc(_ tapOnScreen: UITapGestureRecognizer) {
        print("tap!")
        if isFirstTap {
            isFirstTap = false
            
//            let skView = self.view as! SKView
//            skView.showsFPS = true
//            skView.showsNodeCount = true
//            skView.showsPhysics = true
            
            self.physicsWorld.gravity = CGVector.zero
            self.physicsWorld.contactDelegate = self
            self.backgroundColor = UIColor.clear
            
            self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            self.physicsBody?.categoryBitMask = 100
            
            swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.goUp(_:)))
            swipeUp.direction = .up
            swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.goDown(_:)))
            swipeDown.direction = .down
            swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.goRight(_:)))
            swipeRight.direction = .right
            swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.goLeft(_:)))
            swipeLeft.direction = .left
            
            
            snakeHead = SKShapeNode(circleOfRadius: ballRadius*sw )
            snakeHead.position = CGPoint(x: 375*sw/2, y: 333.5*sh)
            snakeHead.fillColor = .green
            snakeHead.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius*sw)
            snakeHead.physicsBody?.affectedByGravity = false
            snakeHead.physicsBody?.categoryBitMask = 1
            snakeHead.physicsBody?.contactTestBitMask = 10 | 100
            // snakeHead.physicsBody?.contactTestBitMask = 10 | 100
            snakeHead.physicsBody?.collisionBitMask = 0
            snakeHead.zPosition = 10001
            
            addChild(snakeHead)
            
            for _ in 0...6 {
                addFood(value: 2)
            }
            //snake tail time
            timer1 = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(GameScene.followFunc), userInfo: nil, repeats: true)
            //monster timer
            timer2 = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(GameScene.monsterFunc), userInfo: nil, repeats: true)
            //add monster timer
            timer3 = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(GameScene.addRandomMonster), userInfo: nil, repeats: true)
            
        } else {
            
            
            guard snakeTail.count > 0 else {return}
            let shotSpeed = duration/6
            let tail = addOneTail()
            tail.zPosition = 20000
            tail.physicsBody?.categoryBitMask = 25
            // tail.physicsBody?.contactTestBitMask = 666
            snakeTail.last!.removeFromParent()
            snakeTail.removeLast()
            delegateRefresh?.changeScore(amount: -1)
            addChild(tail)
            switch direction! {
            case .up:
                let moveObject = SKAction.move(to: CGPoint(x: tail.position.x, y: tail.position.y + 1000*sh), duration: shotSpeed)
                tail.run(moveObject)
            case .down:
                let moveObject = SKAction.move(to: CGPoint(x: tail.position.x, y: tail.position.y - 1000*sh), duration: shotSpeed)
                tail.run(moveObject)
            case .right:
                let moveObject = SKAction.move(to: CGPoint(x: tail.position.x + 1000*sh, y: tail.position.y), duration: shotSpeed)
                tail.run(moveObject)
            case .left:
                let moveObject = SKAction.move(to: CGPoint(x: tail.position.x - 1000*sh, y: tail.position.y), duration: shotSpeed)
                tail.run(moveObject)
            default:
                break
            }
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    let timeInterval = 0.05
    let trailTime = 0.05
    let snakeSpeed: CGFloat = 1200
    @objc func followFunc() {
        guard snakeTail.count > 0 else {return}
        for i in 1..<snakeTail.count {
            let moveObject = SKAction.move(to: snakeTail[i-1].position, duration: trailTime)
            snakeTail[i].run(moveObject)
        }
        let moveObject = SKAction.move(to: CGPoint(x: snakeHead.position.x - ballRadius*sw, y: snakeHead.position.y - ballRadius*sh), duration: trailTime + 0.01)
        snakeTail[0].run(moveObject)
        
        
    }
    
    enum Facing {
        case up,down,left,right
    }
    var direction: Facing? = .up
    var duration: Double = 10
    @objc private func goUp(_ swipe: UISwipeGestureRecognizer?) {
        print("swipeup")
        let moveObject = SKAction.move(to: CGPoint(x:snakeHead.position.x, y:snakeHead.position.y + snakeSpeed*sh), duration: duration)
        snakeHead.run(moveObject)
        if direction == .down {
            snakeHead.removeAllActions()
        }
        direction = .up
    }
    @objc private func goDown(_ swipe: UISwipeGestureRecognizer?) {
        let moveObject = SKAction.move(to: CGPoint(x:snakeHead.position.x, y:snakeHead.position.y - snakeSpeed*sh), duration: duration)
        snakeHead.run(moveObject)
        if direction == .up {
            snakeHead.removeAllActions()
        }
        direction = .down
        
    }
    @objc private func goRight(_ swipe: UISwipeGestureRecognizer?) {
        let moveObject = SKAction.move(to: CGPoint(x:snakeHead.position.x + snakeSpeed*sh, y:snakeHead.position.y), duration: duration)
        snakeHead.run(moveObject)
        if direction == .left {
            snakeHead.removeAllActions()
        }
        direction = .right
        
    }
    @objc private func goLeft(_ swipe: UISwipeGestureRecognizer?) {
        
        let moveObject = SKAction.move(to: CGPoint(x:snakeHead.position.x - snakeSpeed*sh, y:snakeHead.position.y), duration: duration)
        snakeHead.run(moveObject)
        if direction == .right {
            snakeHead.removeAllActions()
        }
        direction = .left
        
    }
    
    private func delayAdd() {
        let myDouble = Double(arc4random_uniform(5)) + 1.0
        Global.delay(bySeconds: myDouble) {
            let random = Int(arc4random_uniform(2))
            if random == 0 {
                self.addFood(value: Int(arc4random_uniform(UInt32(self.topFoodAmount))) + 1)
            } else {
                self.addFood(value: Int(arc4random_uniform(2)) + 1)
            }
        }
    }
    
    
    private func addTails(amount: Int) {
        
        for i in 0..<amount {
            
            let tail = addOneTail()
            tail.zPosition = 10000 - CGFloat(i)
            tail.physicsBody?.categoryBitMask = 5
            //  tail.physicsBody?.contactTestBitMask = 666
            tail.physicsBody?.affectedByGravity = false
            snakeTail.append(tail)
            addChild(tail)
        }
        
    }
    
    private func addOneTail() -> SKShapeNode {
        let rect = CGRect(x: 0, y: 0, width: 2*ballRadius*sw, height: 2*ballRadius*sw)
        let tail = SKShapeNode(rect: rect, cornerRadius: sw)
        tail.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: rect.size.width, height: rect.size.height), center: CGPoint(x: tail.frame.midX, y: tail.frame.midY))
        //    tail.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: rect.size.width + 2, height: rect.size.height + 2))
        //tail.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
        tail.physicsBody?.affectedByGravity = false
        // tail.physicsBody?.contactTestBitMask = 666
        tail.physicsBody?.collisionBitMask = 0
        tail.position = CGPoint(x: snakeHead.position.x - ballRadius*sw, y: snakeHead.position.y - ballRadius*sw)
        tail.fillColor = .white
        return tail
    }
    
    enum Monster {
        case zombie, eagle, butterfly, tiger, mouse, deer
    }
    
    enum MonsterEnterance {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    @objc func monsterFunc() {
        
        for (node,type) in monsters {
            var sign:CGFloat = -1
            let random = arc4random_uniform(2)
            if random == 1 {
                sign = 1
            }
            var sign2:CGFloat = -1
            let random2 = arc4random_uniform(2)
            if random2 == 1 {
                sign2 = 1
            }
            
            
            switch type {
            case .zombie:
                let distance: CGFloat = abs(node.position.x - snakeHead.position.x) + abs(node.position.y - snakeHead.position.y)
                let moveObject = SKAction.move(to: CGPoint(x: snakeHead.position.x, y: snakeHead.position.y), duration: Double(distance/15))
                node.run(moveObject)
            case .eagle:
                var locationX = CGFloat()
                var locationY = CGFloat()
                if node.position.x > 60 && node.position.x < 315 {
                    
                    locationX = node.position.x - 50*sign
                    
                } else if node.position.x > 60 {
                    locationX = node.position.x - 50
                } else {
                    locationX = node.position.x + 50
                }
                if node.position.y > 60 && node.position.y < 607 {
                    
                    locationY = node.position.y - 50*sign2
                    
                } else if node.position.y > 60 {
                    locationY = node.position.y - 50
                } else {
                    locationY = node.position.y + 50
                }
                
                let moveObject = SKAction.move(to: CGPoint(x: locationX, y: locationY), duration: 0.5)
                node.run(moveObject)
            case .butterfly:
                var locationX = CGFloat()
                var locationY = CGFloat()
                if node.position.x > 60 && node.position.x < 315 {
                    
                    locationX = node.position.x - 50*sign
                    
                } else if node.position.x > 60 {
                    locationX = node.position.x - 50
                } else {
                    locationX = node.position.x + 50
                }
                if node.position.y > 60 && node.position.y < 607 {
                    
                    locationY = node.position.y - 50*sign2
                    
                } else if node.position.y > 60 {
                    locationY = node.position.y - 50
                } else {
                    locationY = node.position.y + 50
                }
                
                let moveObject = SKAction.move(to: CGPoint(x: locationX, y: locationY), duration: 1.0)
                node.run(moveObject)
            case .tiger:
                let distance: CGFloat = abs(node.position.x - snakeHead.position.x) + abs(node.position.y - snakeHead.position.y)
                let moveObject = SKAction.move(to: CGPoint(x: snakeHead.position.x, y: snakeHead.position.y), duration: Double(distance/75))
                node.run(moveObject)
            case .mouse:
                let x = node.position.x
                let y = node.position.y
                if (x > 325 && y > 617) {
                    let moveObject = SKAction.move(to: CGPoint(x: 355, y: 20), duration: 5.0)
                    node.run(moveObject)
                    
                } else if (x < 50 && y < 50) {
                    let moveObject = SKAction.move(to: CGPoint(x: 20, y: 647), duration: 2.5)
                    node.run(moveObject)
                } else if (x > 325 && y < 50) {
                    let moveObject = SKAction.move(to: CGPoint(x: 20, y: 20), duration: 5.0)
                    node.run(moveObject)
                } else if (x < 50 && y > 617) {
                    let moveObject = SKAction.move(to: CGPoint(x: 355, y: 647), duration: 2.5)
                    node.run(moveObject)
                }
                
            case .deer:
                let x = node.position.x
                let y = node.position.y
                if (x > 325 && y > 617) {
                    let moveObject = SKAction.move(to: CGPoint(x: 20, y: 20), duration: 15.0)
                    node.run(moveObject)
                    
                } else if (x < 50 && y < 50) {
                    let moveObject = SKAction.move(to: CGPoint(x: 335, y: 20), duration: 7.5)
                    node.run(moveObject)
                } else if (x > 325 && y < 50) {
                    let moveObject = SKAction.move(to: CGPoint(x: 20, y: 647), duration: 15.0)
                    node.run(moveObject)
                } else if (x < 50 && y > 617) {
                    let moveObject = SKAction.move(to: CGPoint(x: 335, y: 647), duration: 7.5)
                    node.run(moveObject)
                }
                
            }
        }
    }
    
    
    
    func chooseRandomEnterance() -> CGPoint {
        let random = arc4random_uniform(4)
        var location = CGPoint()
        switch random {
        case 0:
            location = CGPoint(x: 8*sw, y: 8*sh)
        case 1:
            location = CGPoint(x: 8*sw, y: 659*sh)
        case 2:
            location = CGPoint(x: 367*sw, y: 8*sh)
        default:
            location = CGPoint(x: 367*sw, y: 659*sh)
            
        }
        return location
    }
    var monsters = [(SKShapeNode,Monster)]()
    func addMonster(type: Monster) {
        let enteranceLocation = chooseRandomEnterance()
        switch type {
        case .zombie:
            let zombie = Zombie(origin: enteranceLocation)
            monsters.append((zombie,.zombie))
            addChild(zombie)
        case .eagle:
            let eagle = Eagle(origin: enteranceLocation)
            monsters.append((eagle,.eagle))
            addChild(eagle)
        case .butterfly:
            let butterfly = Butterfly(origin: enteranceLocation)
            monsters.append((butterfly,.butterfly))
            addChild(butterfly)
        case .tiger:
            let tiger = Tiger(origin: enteranceLocation)
            monsters.append((tiger,.tiger))
            addChild(tiger)
        case .mouse:
            let mouse = Mouse(origin: enteranceLocation)
            monsters.append((mouse,.mouse))
            addChild(mouse)
            
        case .deer:
            let deer = Deer(origin: enteranceLocation)
            monsters.append((deer,.deer))
            addChild(deer)
        }
    }
    
    private func resetGame() {
        
        timer1.invalidate()
        timer2.invalidate()
        timer3.invalidate()
        self.removeAllChildren()
        snakeTail.removeAll()
        monsters.removeAll()
        foodArray.removeAll()
        
        
        
    }
    
    func restartGame() {
        
        snakeHead = SKShapeNode(circleOfRadius: ballRadius*sw )
        snakeHead.position = CGPoint(x: 100*sw, y: 333.5*sh)
        snakeHead.fillColor = .black
        snakeHead.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius*sw)
        snakeHead.physicsBody?.affectedByGravity = false
        snakeHead.physicsBody?.categoryBitMask = 1
        snakeHead.physicsBody?.contactTestBitMask = 10 | 100
        snakeHead.physicsBody?.collisionBitMask = 0
        snakeHead.zPosition = 10001
        
        addChild(snakeHead)
        
        for _ in 0...6 {
            addFood(value: 2)
        }
        
        //snake tail time
        timer1 = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(GameScene.followFunc), userInfo: nil, repeats: true)
        //monster timer
        timer2 = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(GameScene.monsterFunc), userInfo: nil, repeats: true)
        //add monster timer
        timer3 = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(GameScene.addRandomMonster), userInfo: nil, repeats: true)
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("didbegin")
        print("A: \(contact.bodyA.categoryBitMask)")
        print("B: \(contact.bodyB.categoryBitMask)")
        
        if contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 666 {
            // monster gotchya
            print("ate monster!")
            if let item = contact.bodyB.node as? SKShapeNode {
                item.removeFromParent()
                loop: for i in 0..<monsters.count {
                    if item == monsters[i].0 {
                        
                        monsters.remove(at: i)
                        
                        break loop
                    }
                }
            }
            
        } else if contact.bodyA.categoryBitMask == 10 && contact.bodyB.categoryBitMask == 1 {
            
            // head hit food
            print("EAT")
            if let item = contact.bodyA.node as? SKShapeNode {
                item.removeFromParent()
                loop: for i in 0..<foodArray.count {
                    if item == foodArray[i] {
                        let amount = Int(foodLabels[i].text!)!
                        delegateRefresh?.changeScore(amount: amount)
                        foodArray.remove(at: i)
                        foodLabels.remove(at: i)
                        addTails(amount: amount)
                        
                        delayAdd()
                        break loop
                    }
                }
            }
        } else if contact.bodyA.categoryBitMask == 100 && contact.bodyB.categoryBitMask == 1 {
            //hit wall
            print("hit wall")
            switch direction! {
            case .up:
                goDown(nil)
            case .down:
                goUp(nil)
            case .left:
                goRight(nil)
            case .right:
                goLeft(nil)
            default:
                break
            }
            
        } else if contact.bodyA.categoryBitMask == 5 && contact.bodyB.categoryBitMask == 666 {
            // monster gotchya
            print("monster attack!")
            delegateRefresh?.gameOver()
            resetGame()
            
        } else if contact.bodyA.categoryBitMask == 25 && contact.bodyB.categoryBitMask == 666 {
            // monster gotchya
            print("shot monster!")
            if let item = contact.bodyB.node as? SKShapeNode {
                item.removeFromParent()
                loop: for i in 0..<monsters.count {
                    if item == monsters[i].0 {
                        
                        monsters.remove(at: i)
                        
                        break loop
                    }
                }
            }
            
        }
        
        
        
    }
    
    func moveSprite(sprite: SKShapeNode, location: CGPoint) {
        let action = SKAction.move(to: location, duration: 0.0)
        sprite.run(action)
    }
    
    func lockSprite(sprite: SKShapeNode, isDynamic: Bool) {
        sprite.physicsBody?.isDynamic = isDynamic
    }
    
    func colorSprite(sprite: SKShapeNode, colorString: String) {
        switch colorString {
        case "color1":
            sprite.fillColor = CustomColor.color1
        case "color2":
            sprite.fillColor = CustomColor.color2
        case "color3":
            sprite.fillColor = CustomColor.color3
        case "color4":
            sprite.fillColor = CustomColor.color4
        case "boundaryColor": break
        //        sprite.fillColor = CustomColor.boundaryColor
        default:
            break
        }
    }
    
    var touchOnce = true
    var touchDownPoint = CGPoint()
    //    func touchDown(atPoint pos : CGPoint) {
    //        if touchOnce {
    //            //        delegateRefresh?.fire()
    //            //        fired = false
    //            touchDownPoint = pos
    //            endTouchLocation = pos
    //            startTouchLocation = pos
    //            //        delegateRefresh?.refresh(start: startTouchLocation, end: endTouchLocation)
    //            //        delegateRefresh?.turn(on: true)
    //        }
    //    }
    //    var previouslySavedTouch = CGPoint()
    //    var savedTouch = CGPoint(x: 0,y: 0)
    //    func touchMoved(toPoint pos : CGPoint) {
    //        if touchOnce {
    //            //        endTouchLocation = pos
    //            //        delegateRefresh?.refresh(start: startTouchLocation, end: endTouchLocation)
    //            //            previouslySavedTouch = savedTouch
    //            //            savedTouch = pos
    //        }
    //    }
    //
    //
    //
    //    func touchUp(atPoint pos : CGPoint) {
    //        if touchOnce {
    //            endTouchLocation = previouslySavedTouch
    //            guard abs(pos.x - touchDownPoint.x) > 2 || abs(pos.y - touchDownPoint.y) > 2 else {return}
    //
    //            endTouchLocation = pos
    //            let dx = startTouchLocation.x - endTouchLocation.x
    //            let dy = startTouchLocation.y - endTouchLocation.y
    //            let amplitude = CGFloat(sqrt(Double(dx*dx + dy*dy)))
    //            //            icsBody?.applyImpulse(CGVector(dx: -16000*dx/amplitude, dy: -16000*dy/amplitude))
    //
    //            //            timer1 = Timer.scheduledTimer(withTimeInterval: 4.5, repeats: false) {_ in
    //            //                self.changeDamping(amount: 3)
    //            //            }
    //            //            timer2 = Timer.scheduledTimer(withTimeInterval: 5.5, repeats: false) {_ in
    //            //                self.changeDamping(amount: 10)
    //            //            }
    //            //            timer3 = Timer.scheduledTimer(withTimeInterval: 6, repeats: false) {_ in
    //            //                self.changeDamping(amount: self.initialDamping)
    //            //            }
    //
    //
    //            touchOnce = false
    //            Global.delay(bySeconds: 0.5) {
    //                self.touchOnce = true
    //            }
    //        }
    //
    //    }
    //
    func tapTouch() {
        if touchOnce {
            guard abs(startTouchLocation.x - endTouchLocation.x) > 2 || abs(startTouchLocation.y - endTouchLocation.y) > 2 else {return}
            
            //            timer1.invalidate()
            //            timer2.invalidate()
            //            timer3.invalidate()
            
            let dx = startTouchLocation.x - endTouchLocation.x
            let dy = startTouchLocation.y - endTouchLocation.y
            let amplitude = CGFloat(sqrt(Double(dx*dx + dy*dy)))
            
            //            timer1 = Timer.scheduledTimer(withTimeInterval: 4.5, repeats: false) {_ in
            //                self.changeDamping(amount: 3)
            //            }
            //            timer2 = Timer.scheduledTimer(withTimeInterval: 5.5, repeats: false) {_ in
            //                self.changeDamping(amount: 10)
            //            }
            //            timer3 = Timer.scheduledTimer(withTimeInterval: 6, repeats: false) {_ in
            //                self.changeDamping(amount: self.initialDamping)
            //            }
            
            touchOnce = false
            Global.delay(bySeconds: 0.5) {
                self.touchOnce = true
            }
        }
        
    }
    //
    //
    //    //    func resetGame() {
    //    //        let count = 0
    //    //        for ball in balls
    //    //
    //    //    }
    //
    //
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    //    }
    //
    //    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    //    }
    //
    //    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    //    }
    //
    //    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    //    }
    //
    
    
}




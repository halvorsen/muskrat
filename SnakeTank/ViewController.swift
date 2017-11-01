//
//  ViewController.swift
//  SnakeTank
//
//  Created by Jenn Halvorsen on 8/30/17.
//  Copyright © 2017 Right Brothers. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import GCHelper
import StoreKit
import SwiftyStoreKit

class ViewController: UIViewController, ARSCNViewDelegate, BrothersUIAutoLayout, UIGestureRecognizerDelegate, SCNPhysicsContactDelegate {
    
    let cover = UIView()
    var score = UILabel()
    var scoreInt = Int() {
        didSet{
            print("did set score")
            DispatchQueue.main.async {
                self.score.font = UIFont(name: "HelveticaNeue-Bold", size: 72*self.fontSizeMultiplier)
                self.score.text = "\(self.scoreInt)"
            }
            
            
            Global.points = scoreInt
            
        }
        
    }
    var myColor = CustomColor.color2
    let instructionLabel = UILabel()
    var timer = Timer()
    var wrapper = SCNNode()
    var snakeTail = [SCNNode]()
    var timer1 = Timer()
    var timer2 = Timer()
    var timer3 = Timer()
    var swipeUp = UISwipeGestureRecognizer()
    var swipeDown = UISwipeGestureRecognizer()
    var swipeLeft = UISwipeGestureRecognizer()
    var swipeRight = UISwipeGestureRecognizer()
    var tap = UITapGestureRecognizer()
    var tapMenu = UITapGestureRecognizer()
    let foodSize: CGFloat = 3.5
    var snakeHead = SCNNode()
    var snakeHinge = SCNNode()
    var menuHinge = SCNNode()
    var muskrat = SCNNode()
    var currentScore = SCNNode()
    var bestScore = SCNNode()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   Global.isColorThemes = true //hack
        let index = UserDefaults.standard.integer(forKey: "MuskratColorTheme")
        myColor = CustomColor.colors[index]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/snake.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        score.frame = CGRect(x: 20*sw, y: 0*sh, width: 375*sw, height: 86*sh)
        score.font = UIFont(name: "HelveticaNeue-Bold", size: 72*fontSizeMultiplier)
        score.textColor = CustomColor.color1
        score.alpha = 1.0
        score.textAlignment = .left
        score.text = "Tap to Shoot"
        score.alpha = 0.0
        view.addSubview(score)
        
        tap.delegate = self
        
        tapMenu.delegate = self
        
        
        wrapper = scene.rootNode.childNode(withName: "wrapper", recursively: false)!
        snakeHead = wrapper.childNode(withName: "headHinge", recursively: false)!.childNode(withName: "head", recursively: false)!
        //  snakeHead.geometry = SCNSphere(radius: Global.monsterRadius*1.8)
        snakeHinge = wrapper.childNode(withName: "headHinge", recursively: false)!
        menuHinge = wrapper.childNode(withName: "menuHinge", recursively: false)!
        muskrat = menuHinge.childNode(withName: "muskrat", recursively: false)!
        bestScore = menuHinge.childNode(withName: "bestScore", recursively: false)!
        if let textGeometry = bestScore.geometry as? SCNText {
            textGeometry.string = "BEST \(Global.topScore)"
        }
        currentScore = menuHinge.childNode(withName: "currentScore", recursively: false)!
        muskrat.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "AaronArtboard3")
        startScene()
        //   floatMenu()
    }
    
    private func setColors() {
        snakeHead.geometry?.firstMaterial?.diffuse.contents = myColor
        //      snakeHead.geometry?.firstMaterial?.selfIllumination.contents = myColor
        for i in 0..<CustomColor.colors.count {
            if myColor == CustomColor.colors[i] {
                CustomColor.current = i
                muskrat.geometry?.firstMaterial?.diffuse.contents = CustomColor.muskrats[i]
            }
        }
        let nodes = [
            menuHinge.childNode(withName: "currentScore", recursively: false)!,
            menuHinge.childNode(withName: "bestScore", recursively: false)!,
            menuHinge.childNode(withName: "box1", recursively: false)!,
            menuHinge.childNode(withName: "box2", recursively: false)!,
            menuHinge.childNode(withName: "box3", recursively: false)!,
            
            ]
        for node in nodes {
            node.geometry?.firstMaterial?.diffuse.contents = myColor
            //        node.geometry?.firstMaterial?.selfIllumination.contents = myColor
            //      node.geometry?.firstMaterial?.multiply.contents = myColor
        }
        
        
    }
    
    var animationDots = [Enemy]()
    private func startScene() {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        setColors()
        
        snakeHead.opacity = 0.0
        // Run the view's session
        sceneView.session.run(configuration)
        
        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.goUp(_:)))
        swipeUp.direction = .up
        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.goDown(_:)))
        swipeDown.direction = .down
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.goRight(_:)))
        swipeRight.direction = .right
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.goLeft(_:)))
        swipeLeft.direction = .left
        rotateMenu(angle:CGFloat.pi)
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    private func rotateMenu(angle: CGFloat) {
        let action = SCNAction.rotateBy(x: 0, y: angle, z: 0, duration: 2.0)
        action.timingMode = .easeInEaseOut
        menuHinge.runAction(action)
    }
    
    
    
    func changeScore(amount: Int) {
        
        scoreInt += amount
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sceneView.addGestureRecognizer(swipeUp)
        sceneView.addGestureRecognizer(swipeDown)
        sceneView.addGestureRecognizer(swipeRight)
        sceneView.addGestureRecognizer(swipeLeft)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.fireFunc(_:)))
        //  sceneView.addGestureRecognizer(tap)
        tapMenu = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapMenuFunc(_:)))
        sceneView.addGestureRecognizer(tapMenu)
    }
    
    @objc private func tapMenuFunc(_ gesture: UITapGestureRecognizer) {
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let results: [SCNHitTestResult] = sceneView.hitTest(gesture.location(in: view), options: hitTestOptions)
        
        
        for result in results {
            if let name = result.node.name {
                
                if name == "box1" || name == "play" {
                    play()
                    return
                } else if name == "box2" || name == "gameCenter" {
                    gameCenter()
                    return
                } else if name == "box3" || name == "colorTheme" {
                    if Global.isColorThemes {
                    colorTheme()
                    } else {
                        needToPayForTheme()
                    }
                    return
                }
            }
        }
    }
    var isFirstPlay = true
    private func play() {
        
        if isFirstPlay {
            score.text = "TAP SHOOT - SWIPE MOVE"
            score.font = UIFont(name: "HelveticaNeue-Bold", size: 18*fontSizeMultiplier)
            isFirstPlay = false
        } else {
            scoreInt = 0
        }
        score.alpha = 1.0
        rotateMenu(angle: -CGFloat.pi)
        snakeHead.opacity = 1.0
        Global.delay(bySeconds: 2.0) {
            self.menuHinge.removeFromParentNode()
        }
        animation() {
            
            self.timer3 = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true, block: {_ in
                let _ = self.addMonster(type: .deer)})
        }
        self.timer2 = Timer.scheduledTimer(timeInterval: deerDuration, target: self, selector: #selector(ViewController.monsterFunc), userInfo: nil, repeats: true)
        self.timer1 = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(ViewController.followFunc), userInfo: nil, repeats: true)
        
        sceneView.removeGestureRecognizer(tapMenu)
        sceneView.addGestureRecognizer(tap)
        //add monster timer
        
        
        
    }
    private func animation(done: @escaping () -> Void ) {
        //        let action = SCNAction.move(to: snakeHead.position, duration: 2.0)
        //        for node in animationDots {
        //            node.actualNode.runAction(action)
        //        }
        //        Global.delay(bySeconds: 2.0) {
        //            for node in self.animationDots {
        //                node.removeFromParentNode()
        //            }
        //        }
        done()
    }
    
    private func gameCenter() {
        GCHelper.sharedInstance.showGameCenter(self, viewState: .leaderboards)
    }
    
    private func colorTheme() {
        
        switch myColor {
        case CustomColor.color1: myColor = CustomColor.color2
        UserDefaults.standard.set(1, forKey: "MuskratColorTheme")
        CustomColor.current = 1
        case CustomColor.color2: myColor = CustomColor.color3
        UserDefaults.standard.set(2, forKey: "MuskratColorTheme")
        CustomColor.current = 2
        case CustomColor.color3: myColor = CustomColor.color4
        UserDefaults.standard.set(3, forKey: "MuskratColorTheme")
        CustomColor.current = 3
        case CustomColor.color4: myColor = CustomColor.color5
        UserDefaults.standard.set(4, forKey: "MuskratColorTheme")
        CustomColor.current = 4
        case CustomColor.color5: myColor = CustomColor.color6
        UserDefaults.standard.set(5, forKey: "MuskratColorTheme")
        CustomColor.current = 5
        case CustomColor.color6: myColor = CustomColor.color7
        UserDefaults.standard.set(6, forKey: "MuskratColorTheme")
        CustomColor.current = 6
        case CustomColor.color7: myColor = CustomColor.color1
        UserDefaults.standard.set(0, forKey: "MuskratColorTheme")
        CustomColor.current = 0
            
        default:
            myColor = CustomColor.color2
            UserDefaults.standard.set(0, forKey: "MuskratColorTheme")
            CustomColor.current = 0
        }
        setColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    var once = true
    func gameOver() {
        if once {
            timer3.invalidate()
            DispatchQueue.main.async {
                self.sceneView.removeGestureRecognizer(self.tap)
                self.sceneView.addGestureRecognizer(self.tapMenu)
            }
            once = false
            GCHelper.sharedInstance.authenticateLocalUser()
            if Global.points > Global.topScore {
                Global.topScore = Global.points
                UserDefaults.standard.set(Global.points, forKey: "muskratTopScore")
                 GCHelper.sharedInstance.reportLeaderboardIdentifier("highscore1236544455", score: Global.topScore)
            }
            
            if let textGeometry = currentScore.geometry as? SCNText {
                textGeometry.string = "\(scoreInt)"
            }
            
            if let textGeometry = bestScore.geometry as? SCNText {
                textGeometry.string = "BEST \(Global.topScore)"
            }
            
            Global.delay(bySeconds: 0.5) {
                for node in self.snakeTail {
                    
                    node.removeFromParentNode()
                    
                }
                self.snakeHead.opacity = 1.0
                self.snakeHinge.eulerAngles.y = 0
                self.snakeHinge.position = SCNVector3(0,1,0)
                self.snakeHinge.removeAllActions()
                self.snakeTail.removeAll()
            }
            for (node,_) in monsters {
                
                node.removeFromParentNode()
                
            }
            
            wrapper.addChildNode(menuHinge)
            rotateMenu(angle: -CGFloat.pi)
            
            Global.delay(bySeconds: 5.0) {
                self.once = true
            }
            resetGame()
        }
    }
    
    private func addSphere() {
        
        let shape = SCNSphere(radius: Global.monsterRadius*1.3)
        
        let sphere = SCNNode(geometry: shape)
        sphere.position =  SCNVector3(x: 0, y: -2, z: 0)
        let physShape = SCNPhysicsShape(geometry: SCNSphere(radius: Global.monsterRadius*1.3), options: nil)
        
        let sphereBodys = SCNPhysicsBody(type: .kinematic, shape: physShape)
        
        sphere.physicsBody = sphereBodys
        
        sphere.physicsBody?.isAffectedByGravity = false
        sphere.physicsBody?.categoryBitMask = CollisionTypes.tail.rawValue
        sphere.physicsBody?.collisionBitMask = 0
        
        wrapper.addChildNode(sphere)
        snakeTail.append(sphere)
        
    }
    
    private func needToPayForTheme() {
    // Create the alert controller
    let alertController = UIAlertController(title: "Color Themes", message: "Unlock all for $0.99", preferredStyle: .alert)
    
    // Create the actions
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
    UIAlertAction in
    self.purchase()
    
    }
    let restoreAction = UIAlertAction(title: "Restore Purchase", style: UIAlertActionStyle.default) {
    UIAlertAction in
    
    SwiftyStoreKit.restorePurchases(atomically: true) { results in
    if results.restoreFailedPurchases.count > 0 {
    print("Restore Failed: \(results.restoreFailedPurchases)")
    }
    else if results.restoredPurchases.count > 0 {
    Global.isColorThemes = true
    UserDefaults.standard.set(true, forKey: "isColorThemesMuskrat")
    }
    else {
    print("Nothing to Restore")
    }
    }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
    UIAlertAction in
    print("Cancel Pressed")
    }
    
    // Add the actions
    alertController.addAction(okAction)
    alertController.addAction(restoreAction)
    alertController.addAction(cancelAction)
    
    // Present the controller
    self.present(alertController, animated: true, completion: nil)
    }
    
    var activityView = UIActivityIndicatorView()
    private func purchase(productId: String = "muskrat.IAP.colorTheme") {
    
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.center = self.view.center
        activityView.startAnimating()
        activityView.alpha = 0.0
        self.view.addSubview(activityView)
                SwiftyStoreKit.purchaseProduct(productId) { result in
                    switch result {
                    case .success( _):
                        Global.isColorThemes = true
                        UserDefaults.standard.set(true, forKey: "isColorThemesMuskrat")
                        self.activityView.removeFromSuperview()
                    case .error(let error):
        
                        print("error: \(error)")
                        print("Purchase Failed: \(error)")
                        self.activityView.removeFromSuperview()
                    }
                }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    let monsterDictionary : [Int:Monster] = [
        0:.zombie,
        1:.eagle,
        2:.butterfly,
        3:.tiger,
        4:.mouse,
        5:.deer
    ]

    var invalidated = false
    var isFirstTap = true
    let bulletSpeed: Float = 10
    @objc func fireFunc(_ tapOnScreen: UITapGestureRecognizer) {
        
//        if monsters.count > 150 {
//            timer3.invalidate()
//            invalidated = true
//        } else if invalidated && monsters.count < 5 {
//            timer3.fire()
//            invalidated = false
//        }
        
        var dissappearTime: Double = 0.0
    
        
        switch direction! {
        case .up:
            let bullet = Bullet(height: snakeHinge.position.y + Float(Global.monsterRadius*2), rotation: snakeHinge.rotation.y*snakeHinge.rotation.w + 0.01, rotate90: false)
            wrapper.addChildNode(bullet)
            let distance = 3-snakeHinge.position.y
            dissappearTime = Double(distance/bulletSpeed)
            let moveObject = SCNAction.move(by: SCNVector3(0,distance,0), duration: dissappearTime)
            bullet.runAction(moveObject)
            Global.delay(bySeconds: dissappearTime) {
                bullet.removeFromParentNode()
            }
        case .down:
            let bullet = Bullet(height: snakeHinge.position.y - Float(Global.monsterRadius*2), rotation: snakeHinge.rotation.y*snakeHinge.rotation.w + 0.01, rotate90: false)
            wrapper.addChildNode(bullet)
            let distance = -3 - snakeHinge.position.y
            dissappearTime = Double(abs(distance/bulletSpeed))
            let moveObject = SCNAction.move(by: SCNVector3(0,distance,0), duration: dissappearTime)
            bullet.runAction(moveObject)
            Global.delay(bySeconds: dissappearTime) {
                bullet.removeFromParentNode()
            }
        case .right:
            
            let bullet = Bullet(height: snakeHinge.position.y, rotation: snakeHinge.rotation.y*snakeHinge.rotation.w - 0.03, rotate90: true)
            wrapper.addChildNode(bullet)
            dissappearTime = Double(duration*3.14*1.5/20)
            let moveObject = SCNAction.rotateBy(x: 0, y: -CGFloat.pi/2, z: 0, duration: dissappearTime/2)
            bullet.runAction(moveObject)
            Global.delay(bySeconds: dissappearTime) {
                bullet.removeFromParentNode()
            }
        case .left:
            let bullet = Bullet(height: snakeHinge.position.y, rotation: snakeHinge.rotation.y*snakeHinge.rotation.w + 0.05, rotate90: true)
            wrapper.addChildNode(bullet)
            dissappearTime = Double(duration*3.14*1.5/20)
            let moveObject = SCNAction.rotateBy(x: 0, y: CGFloat.pi/2, z: 0, duration: dissappearTime/2)
            bullet.runAction(moveObject)
            Global.delay(bySeconds: dissappearTime) {
                bullet.removeFromParentNode()
            }
            
        }
    }
    
    let timeInterval = 0.05
    let trailTime = 0.13
    let snakeSpeed: Float = 1200
    let ballRadius: Float = 1
    @objc func followFunc() {
        guard snakeTail.count > 0 else {return}
        
        for i in 1..<snakeTail.count {
            
            let moveObject = SCNAction.move(to: snakeTail[i-1].position, duration: trailTime)
            snakeTail[i].runAction(moveObject)
        }
        
        let globalPositionOfSnakeHead = snakeHinge.convertPosition(snakeHead.position, to: wrapper)
        let moveObject = SCNAction.move(to: SCNVector3(x: globalPositionOfSnakeHead.x , y: globalPositionOfSnakeHead.y , z: globalPositionOfSnakeHead.z ), duration: trailTime + 0.08)
        snakeTail[0].runAction(moveObject)
        
        //change first few to fruits
        if monsters2.count < 5 {
            for i in 0..<monsters2.count {
                
                monsters2[i].geometry = SCNPlane(width: 3*Global.monsterRadius, height: 3*Global.monsterRadius)
                if isGold[i] {
                    monsters2[i].geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "grape")
                    monsters2[i].geometry?.firstMaterial?.selfIllumination.contents = #imageLiteral(resourceName: "grape")
                } else {
                    let fr = chooseRandomFruit()
                    monsters2[i].geometry?.firstMaterial?.diffuse.contents = fr
                    monsters2[i].geometry?.firstMaterial?.selfIllumination.contents = fr
                }
                monsters2[i].physicsBody?.categoryBitMask = CollisionTypes.food.rawValue
                monsters2[i].physicsBody?.contactTestBitMask = CollisionTypes.head.rawValue
                monsters2[i].geometry?.firstMaterial?.diffuse.intensity = 1.0
                monsters2[i].constraints = [SCNBillboardConstraint()]
                
            }
        }
        
    }
    
    enum Facing {
        case up,down,left,right
    }
    var direction: Facing? = .up
    var duration: Double = 5
    @objc private func goUp(_ swipe: UISwipeGestureRecognizer?) {
        guard canGoUp else {return}
        canGoDown = true
        snakeHinge.removeAllActions()
        let moveObject = SCNAction.move(by: SCNVector3(0,4,0), duration: duration)
        snakeHinge.runAction(moveObject)
        if direction == .down {
            snakeHinge.removeAllActions()
        }
        direction = .up
    }
    @objc private func goDown(_ swipe: UISwipeGestureRecognizer?) {
        
        guard canGoDown else {return}
        canGoUp = true
        snakeHinge.removeAllActions()
        let moveObject = SCNAction.move(by: SCNVector3(0,-4,-0), duration: duration)
        snakeHinge.runAction(moveObject)
        if direction == .up {
            snakeHinge.removeAllActions()
        }
        direction = .down
        
    }
    @objc private func goRight(_ swipe: UISwipeGestureRecognizer?) {
        
        snakeHinge.removeAllActions()
        let _moveObject = SCNAction.rotateBy(x: 0, y: -CGFloat.pi*2, z: 0, duration: duration*3.14*1.5)
        let moveObject = SCNAction.repeatForever(_moveObject)
        snakeHinge.runAction(moveObject)
        if direction == .left {
            snakeHinge.removeAllActions()
        }
        direction = .right
        
    }
    @objc private func goLeft(_ swipe: UISwipeGestureRecognizer?) {
        
        snakeHinge.removeAllActions()
        let _moveObject = SCNAction.rotateBy(x: 0, y: CGFloat.pi*2, z: 0, duration: duration*3.14*1.5)
        let moveObject = SCNAction.repeatForever(_moveObject)
        snakeHinge.runAction(moveObject)
        if direction == .right {
            snakeHinge.removeAllActions()
        }
        direction = .left
        
    }
    
    
    
    private func addTails(amount: Int) {
        
        for _ in 0..<amount {
            
            addSphere()
        }
        
    }
    
    enum Monster {
        case zombie, eagle, butterfly, tiger, mouse, deer
    }
    
    enum MonsterEnterance {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    var deerDuration = 5.0
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
                let distanceY = snakeHead.position.y - node.position.y
                let moveObject = SCNAction.move(by: SCNVector3(0,distanceY,0), duration: TimeInterval(abs(distanceY)/3))
                node.runAction(moveObject)
                let distanceAngle = snakeHinge.rotation.w - node.rotation.w
                let rotateObject = SCNAction.rotate(toAxisAngle: SCNVector4(x:0,y:1,z:0,w:snakeHinge.rotation.w), duration: TimeInterval(abs(distanceAngle/3)))
                node.runAction(rotateObject)
            case .eagle:
                
                let rotateObject = SCNAction.rotate(by: 1*sign, around: SCNVector3(0,1,0), duration: 5.0)
                node.runAction(rotateObject)
                
                if node.position.y > -2.8 && node.position.y < 2.8 {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(0.1*sign2),0), duration: 5.0)
                    node.runAction(moveObject)
                    
                } else if node.position.y > 2.7 {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(-0.1),0), duration: 5.0)
                    node.runAction(moveObject)
                } else {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(0.1),0), duration: 5.0)
                    node.runAction(moveObject)
                }
                
            case .butterfly:
                
                let rotateObject = SCNAction.rotate(by: 1*sign, around: SCNVector3(0,1,0), duration: 5.0)
                node.runAction(rotateObject)
                
                if node.position.y > -2.8 && node.position.y < 2.8 {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(0.1*sign2),0), duration: 5.0)
                    node.runAction(moveObject)
                    
                } else if node.position.y > 2.7 {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(-0.1),0), duration: 10.0)
                    node.runAction(moveObject)
                } else {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(0.1),0), duration: 10.0)
                    node.runAction(moveObject)
                }
                
            case .tiger:
                let distanceY = snakeHead.position.y - node.position.y
                let moveObject = SCNAction.move(by: SCNVector3(0,distanceY,0), duration: TimeInterval(abs(distanceY)/25))
                node.runAction(moveObject)
                let distanceAngle = snakeHinge.rotation.w - node.rotation.w
                let rotateObject = SCNAction.rotate(toAxisAngle: SCNVector4(x:0,y:1,z:0,w:snakeHinge.rotation.w), duration: TimeInterval(abs(distanceAngle/25)))
                node.runAction(rotateObject)
                node.runAction(moveObject)
            case .mouse:
                break
                //start mouse at the beginning to just move around circle quickly
                
            case .deer:
                let rotateObject = SCNAction.rotate(by: 0.2*sign, around: SCNVector3(0,1,0), duration: deerDuration)
                node.runAction(rotateObject)
                
                if node.position.y > -2.5 && node.position.y < 2.5 {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(0.3*sign2),0), duration: deerDuration)
                    node.runAction(moveObject)
                    
                } else if node.position.y > 2.4 {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(-0.3),0), duration: 10.0)
                    node.runAction(moveObject)
                } else {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(0.3),0), duration: 10.0)
                    node.runAction(moveObject)
                }
            }
        }
    }
    func chooseRandomFruit() -> UIImage {
        return fruit.image[Int(arc4random_uniform(5))]
    }
    
    func chooseRandomEnterance() -> (y:Float,rotation:Float) {
        let random = arc4random_uniform(8)
        var y = Float()
        var rotation = Float()
        
        switch random {
        case 0:
            rotation = 0.7
            y = 1
        case 1:
            rotation = 1.4
            y = 2
        case 2:
            rotation = 2.1
            y = 2.5
        case 3:
            rotation = 2.8
            y = 1
        case 4:
            rotation = 3.5
            y = -1
        case 5:
            rotation = 4.2
            y = -2.5
        case 6:
            rotation = 4.9
            y = -0.5
        default:
            rotation = 5.6
            y = 0
            
        }
        
        var headRotation = Float()
        if snakeHinge.eulerAngles.y <= 0 {
            headRotation = snakeHinge.eulerAngles.y + 6.28
        } else {
            headRotation = snakeHinge.eulerAngles.y
        }
        
        if (rotation - 0.8)...(rotation + 0.8) ~= headRotation {
            rotation += 1.0
        }
        return (y,rotation)
    }
    var gold = 1
    var monsters = [(SCNNode,Monster)]()
    var monsters2 = [SCNNode]()
    var isGold = [Bool]()
    func addMonster(type: Monster) -> Enemy {
        let (enteranceLocationY,enteranceLocationTheta) = chooseRandomEnterance()
        switch type {
        case .zombie:
            let zombie = Enemy(height: enteranceLocationY, rotation: enteranceLocationTheta)
            monsters.append((zombie,.zombie))
            isGold.append(false)
            wrapper.addChildNode(zombie)
            return zombie
        case .eagle:
            let eagle = Enemy(height: enteranceLocationY, rotation: enteranceLocationTheta)
            monsters.append((eagle,.eagle))
            isGold.append(false)
            wrapper.addChildNode(eagle)
            return eagle
        case .butterfly:
            let butterfly = Enemy(height: enteranceLocationY, rotation: enteranceLocationTheta)
            monsters.append((butterfly,.butterfly))
            isGold.append(false)
            wrapper.addChildNode(butterfly)
            return butterfly
        case .tiger:
            let tiger = Enemy(height: enteranceLocationY, rotation: enteranceLocationTheta)
            monsters.append((tiger,.tiger))
            isGold.append(false)
            wrapper.addChildNode(tiger)
            return tiger
        case .mouse:
            let mouse = Enemy(height: enteranceLocationY, rotation: enteranceLocationTheta)
            monsters.append((mouse,.mouse))
            isGold.append(false)
            wrapper.addChildNode(mouse)
            return mouse
        case .deer:
            let deer = Enemy(height: enteranceLocationY, rotation: enteranceLocationTheta)
            gold += 1
            
            monsters.append((deer,.deer))
            monsters2.append(deer.actualNode)
            wrapper.addChildNode(deer)
            if gold%40 == 0 {
                deer.actualNode.geometry?.firstMaterial?.diffuse.contents = CustomColor.color9
                isGold.append(true)
            } else {
                isGold.append(false)
            }
            return deer
        }
        
    }
    
    private func resetGame() {
        DispatchQueue.main.async {
            self.score.alpha = 0
        }
        
        timer1.invalidate()
        timer2.invalidate()
        invalidated = false
        
        monsters.removeAll()
        monsters2.removeAll()
        isGold.removeAll()
        //currentScore
    }
    
    var canGoDown : Bool = true
    var canGoUp : Bool = true
    let fruit = Fruit()
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {

        if contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.head.rawValue && contact.nodeB.physicsBody!.categoryBitMask == CollisionTypes.food.rawValue {
            // ate food
            
            let item = contact.nodeB
            item.removeFromParentNode()
            addTails(amount: 1)
            changeScore(amount: 1)
            if item.geometry?.firstMaterial?.diffuse.contents as? UIImage == #imageLiteral(resourceName: "grape") {
                addTails(amount: 9)
                for i in 0...8 {
                    Global.delay(bySeconds: 0.2*Double(i)) {
                        self.changeScore(amount: 1)
                    }
                }
            }
            loop: for i in 0..<monsters.count {
                if item == monsters[i].0 {
                    
                    monsters.remove(at: i)
                    
                    break loop
                }
            }
            
            
        } else if contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.head.rawValue && contact.nodeB.physicsBody!.categoryBitMask == CollisionTypes.wallTop.rawValue && canGoDown && canGoUp {
            //hit wall
            
            if direction == .up {
                
                goDown(nil)
                canGoUp = false
            }
            
        } else if contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.head.rawValue && contact.nodeB.physicsBody!.categoryBitMask == CollisionTypes.wallBottom.rawValue && canGoUp && canGoDown {
            //hit wall
            
            if direction == .down {
                
                goUp(nil)
                canGoDown = false
            }
            
        } else if (contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.tail.rawValue && contact.nodeB.physicsBody!.categoryBitMask == CollisionTypes.monster.rawValue) || (contact.nodeB.physicsBody!.categoryBitMask == CollisionTypes.tail.rawValue && contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.monster.rawValue) {
            // monster gotchya
            
            gameOver()
            
            
        } else if contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.monster.rawValue && contact.nodeB.physicsBody!.categoryBitMask == CollisionTypes.bullet.rawValue {
            // shot monster
            
            let item = contact.nodeA
            
            loop: for i in 0..<monsters2.count {
                if item == monsters2[i] {
                    item.geometry = SCNPlane(width: 3*Global.monsterRadius, height: 3*Global.monsterRadius)
                    if isGold[i] {
                        item.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "grape")
                        item.geometry?.firstMaterial?.selfIllumination.contents = #imageLiteral(resourceName: "grape")
                    } else {
                        let fr = chooseRandomFruit()
                        item.geometry?.firstMaterial?.diffuse.contents = fr
                        item.geometry?.firstMaterial?.selfIllumination.contents = fr
                    }
                    item.physicsBody?.categoryBitMask = CollisionTypes.food.rawValue
                    item.physicsBody?.contactTestBitMask = CollisionTypes.head.rawValue
                    item.geometry?.firstMaterial?.diffuse.intensity = 1.0
                    item.constraints = [SCNBillboardConstraint()]
                    break loop
                }
            }
        }
    }
}


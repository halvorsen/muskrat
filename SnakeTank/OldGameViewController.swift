//
//  ViewController.swift
//  Snake
//
//  Created by Jenn Halvorsen on 8/22/17.
//  Copyright © 2017 Right Brothers. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class GameViewController: UIViewController, refreshDelegate, BrothersUIAutoLayout, UIGestureRecognizerDelegate, ARSCNViewDelegate, SKViewDelegate {

    let cover = UIView()
    var spriteScene = GameScene(size: CGSize(width: 375, height: 667)) //skScene
    var score = UILabel()
    var scoreInt = Int() {didSet{score.text = String(scoreInt); Global.points = scoreInt}}
    let view3 = SKView()
    let instructionLabel = UILabel()
    var timer = Timer()
    var tap = UITapGestureRecognizer()
    var myScheme: ColorScheme?
    
    @IBOutlet var sceneView: ARSCNView!
    
    var scene = SCNScene()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myScheme = ColorScheme(rawValue: UserDefaults.standard.integer(forKey: "colorScheme"))
        CustomColor.changeCustomColor(colorScheme: myScheme!)
        
        
//
        
     //   spriteScene = GameScene(size: CGSize(width: view.bounds.width, height: view.bounds.height))
        
      //  spriteScene.delegateRefresh = self
        spriteScene.scaleMode = .aspectFit
        
        // Set the view's delegate
        sceneView.delegate = self
     //   spriteScene.tap.delegate = self
      //  spriteScene.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        scene = SCNScene(named: "art.scnassets/snake.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
       // sceneView.antialiasingMode = SCNAntialiasingMode(rawValue: 4)!
        view3.frame = self.view.bounds
        view3.delegate = self
       // view.addSubview(view3)
       
    
        
        score.frame = CGRect(x: 0, y: 20*sh, width: 375*sw, height: 86*sh)
        score.font = UIFont(name: "HelveticaNeue-Bold", size: 72*fontSizeMultiplier)
        score.textColor = CustomColor.color3
        score.alpha = 1.0
        score.textAlignment = .center
        score.text = String(Global.points)
        view3.addSubview(score)
        
        
        instructionLabel.frame = CGRect(x: 0,y: 617*sh,width: 375*sw,height: 50*sh)
        instructionLabel.textColor = .green
        instructionLabel.textAlignment = .center
        instructionLabel.alpha = 0.1
        instructionLabel.text = "touch screen to aim"
        
  //      tap = UITapGestureRecognizer(target: self, action: #selector(GameViewController.tapFunc(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        wrapper = scene.rootNode.childNode(withName: "wrapper", recursively: false)!
        plane = wrapper.childNode(withName: "plane", recursively: false)! 
        
        
    }
    var wrapper = SCNNode()
    var planeGeometry = SCNPlane()
    var plane = SCNNode()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        
        
        
        
       
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        let plane = SCNPlane(width: 2, height: 3.4)
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = spriteScene
        plane.materials = [material]
        let node = SCNNode(geometry: plane)
        wrapper.addChildNode(node)
        
        let snakeHead = SKShapeNode(circleOfRadius: 10 )
        snakeHead.position = CGPoint(x: 10, y: 20)
        snakeHead.fillColor = .red
        
      //  spriteScene.addChild(snakeHead)
        let myView = UIView(frame: view.bounds)
        view.addSubview(myView)
        myView.layer.zPosition = 100000
        
        sceneView.addGestureRecognizer(spriteScene.swipeUp)
        sceneView.addGestureRecognizer(spriteScene.swipeDown)
        sceneView.addGestureRecognizer(spriteScene.swipeRight)
        sceneView.addGestureRecognizer(spriteScene.swipeLeft)
        myView.addGestureRecognizer(spriteScene.tap)
        
        
        
   //     view3.presentScene(spriteScene)
        
//        let gameMaterial = SCNMaterial()
//   
//        gameMaterial.diffuse.contents = view3
//        plane.geometry?.firstMaterial = gameMaterial
        
   //     view3.presentScene(spriteScene)
        
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        
        sceneView.session.pause()
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
    
//    @objc private func tapFunc(_ gesture: UITapGestureRecognizer) {
//        spriteScene.tapTouch()
//    }
    
    func changeScore(amount: Int) {
        
        scoreInt += amount
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    var myGameOverView = GameOverView()
    var once = true
    func gameOver() {
        if once {
            once = false
            if Global.points > Global.topScore {
                Global.topScore = Global.points
                UserDefaults.standard.set(Global.points, forKey: "snakeTopScore")
                // GCHelper.sharedInstance.reportLeaderboardIdentifier("highscore123654", score: Global.points)
            }
            
            myGameOverView = GameOverView(backgroundColor: .black, buttonsColor: .white, bestScore: Global.topScore, thisScore: Global.points, colorScheme: myScheme!, vc: self)
    //        myGameOverView.replay.addTarget(self, action: #selector(GameViewController.replayFunc(_:)), for: .touchUpInside)
            //        myGameOverView.menu.addTarget(self, action: #selector(GameViewController.menuFunc(_:)), for: .touchUpInside)
    //        myGameOverView.gameCenter.addTarget(self, action: #selector(GameViewController.gameCenterFunc(_:)), for: .touchUpInside)
     //       myGameOverView.extraLife.addTarget(self, action: #selector(GameViewController.extraLifeFunc(_:)), for: .touchUpInside)
         //   spriteScene.touchOnce = false
            view.addSubview(myGameOverView)
            Global.delay(bySeconds: 5.0) {
                self.once = true
            }
            
            
            
        }
    }
    
//    @objc private func replayFunc(_ button: UIButton) {
//        myGameOverView.removeFromSuperview()
//        scoreInt = 0
//        spriteScene.restartGame()
//    }
//
//    @objc private func gameCenterFunc(_ button: UIButton) {
//        spriteScene.touchOnce = true
//        //   GCHelper.sharedInstance.showGameCenter(self, viewState: .leaderboards)
//    }
//
//    @objc private func extraLifeFunc(_ button: UIButton) {
//        // if Global.isPremium {
//        spriteScene.on = true
//        spriteScene.touchOnce = true
//        UIView.animate(withDuration: 0.7) {
//            // self.myGameOverView.alpha = 0.0
//            self.myGameOverView.frame.origin.x = 375*self.sw
//        }
//        Global.delay(bySeconds: 0.8) {
//
//            self.myGameOverView.removeFromSuperview()
//        }
//        // } else {
//        //  advertisementForExtraLife()
//        // }
//        Global.gaveBonusLife = true
//    }
    
    var activityView = UIActivityIndicatorView()
    private func purchase(productId: String = "plinkerPool.iap.premium") {
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.center = self.view.center
        activityView.startAnimating()
        activityView.alpha = 0.0
        self.view.addSubview(activityView)
        //        SwiftyStoreKit.purchaseProduct(productId) { result in
        //            switch result {
        //            case .success( _):
        //                Global.isPremium = true
        //                UserDefaults.standard.set(true, forKey: "isPremiumMember")
        //                self.activityView.removeFromSuperview()
        //            case .error(let error):
        //
        //                print("error: \(error)")
        //                print("Purchase Failed: \(error)")
        //                self.activityView.removeFromSuperview()
        //            }
        //        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    

    
    // MARK: - ARSKViewDelegate
    
//    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
//        // Create and configure a node for the anchor added to the view's session.
//        let anchorNode = SKNode()
//        
//        
//        anchorNode.addChild(scene.wrapper)
//        
//        view3.addGestureRecognizer(scene.swipeUp)
//        view3.addGestureRecognizer(scene.swipeDown)
//        view3.addGestureRecognizer(scene.swipeRight)
//        view3.addGestureRecognizer(scene.swipeLeft)
//        view3.addGestureRecognizer(scene.tap)
//        
//        return anchorNode;
//        
//        //        let labelNode = SKLabelNode(text: "👾")
//        //        labelNode.horizontalAlignmentMode = .center
//        //        labelNode.verticalAlignmentMode = .center
//        //        return labelNode;
//    }

}

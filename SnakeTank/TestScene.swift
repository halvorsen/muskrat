//
//  TestScene.swift
//  Snake
//
//  Created by Jenn Halvorsen on 8/23/17.
//  Copyright © 2017 Right Brothers. All rights reserved.
//

import Foundation

import SpriteKit
import GameplayKit

class TestScene: SKScene, BrothersUIAutoLayout {

    override func didMove(to view: SKView) {
        
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
        skView.backgroundColor = .clear
        let snakeHead = SKShapeNode(circleOfRadius: 10 )
        snakeHead.position = CGPoint(x: 10, y: 20)
        snakeHead.fillColor = .red
        print(snakeHead)
        snakeHead.zPosition = 10001
        
        addChild(snakeHead)
        
    
    }
}

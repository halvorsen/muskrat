//
//  Deer.swift
//  Snake Gladiator
//
//  Created by Aaron Halvorsen on 8/4/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import SpriteKit
import GameplayKit

class Deer: SKShapeNode, BrothersUIAutoLayout {

    var movementSpeed = Int()
    var color: UIColor = .green
    
    init(origin: CGPoint, circleOfRadius: CGFloat = 7) {
        super.init()
        let diameter = circleOfRadius * 2
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        self.path = CGPath(ellipseIn: rect, transform: nil)
        self.physicsBody = SKPhysicsBody(circleOfRadius: 7, center: CGPoint(x: self.frame.midX, y: self.frame.midY))
        self.position = origin
        self.fillColor = color
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = 666
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = 5 | 25
        self.zPosition = 20000
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

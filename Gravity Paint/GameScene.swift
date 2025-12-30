//
//  GameScene.swift
//  Gravity Paint
//
//  Created by Jaden Wright on 12/29/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var isPainting = false
    private var lastSpawnPoint: CGPoint?
    private var spawnSpacing: CGFloat = 12
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.friction = 0.2

    }
    
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return } 
        isPainting = true

        let p = touch.location(in: self)
        lastSpawnPoint = p
        spawnParticles(at: p)
    }

    private func spawnParticles(at position: CGPoint) {
        let radius: CGFloat = 10
        let node = SKShapeNode(circleOfRadius: radius)

        node.position = position
        node.fillColor = .blue
        node.strokeColor = .clear
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        node.physicsBody?.restitution = 0.8
        node.physicsBody?.friction = 0.05
        node.physicsBody?.linearDamping = 0.05
        node.physicsBody?.angularDamping = 0.05
        
        addChild(node)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPainting, let touch = touches.first else { return } 

        let p = touch.location(in: self)

        if let last = lastSpawnPoint {
            let dx = p.x - last.x
            let dy = p.y - last.y
            let dist = sqrt(dx*dx + dy*dy)

            if dist >= spawnSpacing {
               let steps = Int(dist / spawnSpacing)
               if steps > 0 {
                  for i in 1...steps {
                     let t = CGFloat(i) / CGFloat(steps)
                     let x = last.x + dx * t
                     let y = last.y + dy * t
                     spawnParticles(at: CGPoint(x: x, y: y))
                  
                  }
                  lastSpawnPoint = p
               }
            }
        }
        else {
            lastSpawnPoint = p
            spawnParticles(at: p)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPainting = false
        lastSpawnPoint = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPainting = false
        lastSpawnPoint = nil
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

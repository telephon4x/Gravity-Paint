//
//  GameScene.swift
//  Gravity Paint
//
//  Created by Jaden Wright on 12/29/25.
//

import SpriteKit
import GameplayKit
import SpriteKit
import CoreMotion

class GameScene: SKScene {

    private var paintEmitter: SKEmitterNode?
    private var lastDropletTime: TimeInterval = 0
    private let dropletInterval: TimeInterval = 0.05   // 20 droplets per second

    override func didMove(to view: SKView) {
        backgroundColor = .black

        // Physics world (still useful later if you mix modes)
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)

        setupEmitter()
    }

    private func spawnDroplet(at position: CGPoint) {
        let radius: CGFloat = CGFloat.random(in: 6...12)

        let node = SKShapeNode(circleOfRadius: radius)
        node.position = position
        node.fillColor = .white.withAlphaComponent(0.9)
        node.strokeColor = .clear

        node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        node.physicsBody?.restitution = 0.7
        node.physicsBody?.friction = 0.05
        node.physicsBody?.linearDamping = 0.08
        node.physicsBody?.angularDamping = 0.1

        addChild(node)

        // Optional fade out so the scene does not fill forever
        node.run(.sequence([
            .wait(forDuration: 6.0),
            .fadeOut(withDuration: 1.0),
            .removeFromParent()
        ]))
    }

    // MARK: - Emitter setup

    private func setupEmitter() {
        let emitter = SKEmitterNode()

        emitter.particleTexture = makeCircleTexture(diameter: 20)

        emitter.particleBirthRate = 0
        emitter.numParticlesToEmit = 0

        emitter.particleLifetime = 2.2
        emitter.particleLifetimeRange = 0.6

        emitter.particlePositionRange = CGVector(dx: 6, dy: 6)

        emitter.particleSpeed = 10
        emitter.particleSpeedRange = 30
        emitter.emissionAngleRange = .pi * 2

        emitter.particleAlpha = 0.85
        emitter.particleAlphaRange = 0.15
        emitter.particleAlphaSpeed = -0.45

        emitter.particleScale = 0.18
        emitter.particleScaleRange = 0.12
        emitter.particleScaleSpeed = -0.08

        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1.0

        emitter.particleRotationRange = .pi
        emitter.particleRotationSpeed = 2.0

        addChild(emitter)
        paintEmitter = emitter
    }

    private func makeCircleTexture(diameter: CGFloat) -> SKTexture {
        let size = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fillEllipse(in: rect)
        }

        return SKTexture(image: image)
    }

    // MARK: - Touch handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let p = touch.location(in: self)

        paintEmitter?.position = p
        paintEmitter?.particleBirthRate = 220

        spawnDroplet(at: p)
        lastDropletTime = CACurrentMediaTime()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let p = touch.location(in: self)

        paintEmitter?.position = p

        let now = CACurrentMediaTime()
        if now - lastDropletTime >= dropletInterval {
            spawnDroplet(at: p)
            lastDropletTime = now
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        paintEmitter?.particleBirthRate = 0
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        paintEmitter?.particleBirthRate = 0
    }
}

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

    private enum PaintMode {
        case marbles
        case ink
    }


    private var mode: PaintMode = .marbles

    private var paintEmitter: SKEmitterNode?
    private var lastDropletTime: TimeInterval = 0
    private let dropletInterval: TimeInterval = 0.05   // 20 droplets per second

    private var modeSprite: SKSpriteNode?
    private let cameraNode = SKCameraNode()

    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        setupEmitter()
        applyMode()

        // Camera
        self.camera = cameraNode
        addChild(cameraNode)

        let texture = makeOutlinedTextTexture(
            text: "Mode: Marbles",
            fontName: "AvenirNext-Heavy",
            fontSize: 50,
            fillColor: .blue,
            strokeColor: .white,
            strokeWidth: 3
        )

        let modeNode = SKSpriteNode(texture: texture)
        modeNode.name = "modeToggle"
        modeNode.zPosition = 1000
        modeNode.position = CGPoint(x: 0, y: size.height * 0.35)

        cameraNode.addChild(modeNode)
        self.modeSprite = modeNode

        updateModeLabel()
    }

    private func makeOutlinedTextTexture(
    text: String,
    fontName: String,
    fontSize: CGFloat,
    fillColor: UIColor,
    strokeColor: UIColor,
    strokeWidth: CGFloat
    ) -> SKTexture {
        let font = UIFont(name: fontName, size: fontSize)!

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: fillColor,
            .strokeColor: strokeColor,
            .strokeWidth: -strokeWidth
        ]

        let size = text.size(withAttributes: attributes)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { _ in
            text.draw(at: .zero, withAttributes: attributes)
        }
    return SKTexture(image: image)
    }

    private func updateModeLabel() {
        let text = (mode == .marbles) ? "MODE: MARBLE" : "MODE: INK"

        let texture = makeOutlinedTextTexture(
            text: text,
            fontName: "AvenirNext-Heavy",
            fontSize: 50,
            fillColor: .blue, 
            strokeColor: .white, 
            strokeWidth: 3
        )
        modeSprite?.texture = texture
    }

    private func toggleMode() {
        mode = (mode == .marbles) ? .ink : .marbles
        applyMode()
        updateModeLabel()
    }

    private func applyMode() {
        switch mode {
        case .marbles:
            paintEmitter?.particleBirthRate = 0
            paintEmitter?.isHidden = true

        case .ink:
            paintEmitter?.particleBirthRate = 0
            paintEmitter?.isHidden = false
        }
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

        emitter.particleScale = 0.72
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

        let hit = nodes(at: p)
        if hit.contains(where: { $0.name == "modeToggle" || $0.parent?.name == "modeToggle"}) {
            mode = (mode == .marbles) ? .ink: .marbles
            applyMode()
            updateModeLabel()
            return
        }

        switch mode {
        case .marbles:
            spawnDroplet(at: p)
        case .ink:
            paintEmitter?.position = p
            paintEmitter?.particleBirthRate = 220
            spawnDroplet(at: p)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let p = touch.location(in: self)

        switch mode {
        case .marbles:
            // Paint marbles as you drag
            spawnDroplet(at: p)

        case .ink:
            paintEmitter?.position = p
            // optional hybrid droplets while dragging:
            spawnDroplet(at: p)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mode == .ink {
            paintEmitter?.particleBirthRate = 0
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mode == .ink {
            paintEmitter?.particleBirthRate = 0
        }
    }
}

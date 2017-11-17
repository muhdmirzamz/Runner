//
//  GameScene.swift
//  Runner
//
//  Created by Muhd Mirza on 4/9/17.
//  Copyright © 2017 muhdmirzamz. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreData

class GameScene: SKScene, SKPhysicsContactDelegate {

	let backgroundImage = SKSpriteNode.init(imageNamed: "building")
	let backgroundImage2 = SKSpriteNode.init(imageNamed: "building")
	
	let player = SKSpriteNode.init(imageNamed: "player")
	
	var score = 0
	var scoreLabel: SKLabelNode? = nil
	
	// a way to keep track of spawned blocks
	// spawned blocks are declared locally in a method
	// inefficient to declare them globally in case we need more blocks to increase difficulty
	var shapeArr = [SKShapeNode]()
	
	var topCollisionBlock: SKShapeNode?
	var bottomCollisionBlock: SKShapeNode?
	
	// interesting to note:
	// https://stackoverflow.com/questions/21505660/physics-bodies-not-responding-to-bitmask-settings#comment60916704_21508132
	// do not use 0 or UInt32.max
	// comparing with 0's will give a zero value
	// only non-zero values cause collision
	struct Collision {
		let None: UInt32 = 0
		let All: UInt32 = UInt32.max
		let Border: UInt32 = 0b1 // 1
		let Player: UInt32 = 0b10 // 2
		let Block: UInt32 = 0b11 // 3
		let TopBlock: UInt32 = 0b100 // 4
		let BottomBlock: UInt32 = 0b1000 // 8
	}
	
    override func didMove(to view: SKView) {
		self.physicsWorld.contactDelegate = self
		self.physicsWorld.gravity = .zero
		
		self.physicsBody = SKPhysicsBody.init(edgeLoopFrom: self.frame)
		self.physicsBody?.categoryBitMask = Collision().Border
		self.physicsBody?.collisionBitMask = Collision().Player
		
		self.scoreLabel = SKLabelNode.init(text: "Score: \(score)")
		self.scoreLabel?.fontColor = UIColor.red
		self.scoreLabel?.position = CGPoint.init(x: self.size.width - 200, y: 10)
		self.scoreLabel?.zPosition = 3
		self.addChild(self.scoreLabel!)
	
		self.backgroundImage.size = CGSize.init(width: self.size.width, height: self.size.height)
		self.backgroundImage.position = CGPoint.init(x: self.size.width / 2, y: self.size.height / 2)
		self.addChild(self.backgroundImage)
		
		self.backgroundImage2.size = CGSize.init(width: self.size.width, height: self.size.height)
		self.backgroundImage2.position = CGPoint.init(x: (self.size.width / 2) + self.size.width , y: self.size.height / 2)
		self.addChild(self.backgroundImage2)
	
		self.player.position = CGPoint.init(x: 80, y: 50)
		self.player.size = CGSize.init(width: 100, height: 100)
		self.player.zPosition = 3
		
		self.addChild(self.player)
		
		self.player.physicsBody = SKPhysicsBody.init(rectangleOf: self.player.size)
		self.player.physicsBody?.categoryBitMask = Collision().Player
		self.player.physicsBody?.contactTestBitMask = Collision().Block
		self.player.physicsBody?.collisionBitMask = Collision().Border
		
		let actionBlock = SKAction.run { 
			self.spawnBlock()
		}
		
		let wait = SKAction.wait(forDuration: 4)
		let sequence = SKAction.sequence([actionBlock, wait])
		let forever = SKAction.repeatForever(sequence)
		
		run(forever)
		
		// same size as blocks
		self.topCollisionBlock = SKShapeNode.init(rectOf: CGSize.init(width: 50, height: 50))
		self.topCollisionBlock?.isHidden = true
		// point of origin is center
		// collision block is 50, 50 so 50 / 2 is 25
		self.topCollisionBlock?.position = CGPoint.init(x: 25, y: self.size.height - 25)
		self.topCollisionBlock?.zPosition = 3
		self.addChild(self.topCollisionBlock!)
		
		self.topCollisionBlock?.physicsBody = SKPhysicsBody.init(rectangleOf: (self.topCollisionBlock?.frame.size)!)
		self.topCollisionBlock?.physicsBody?.categoryBitMask = Collision().TopBlock
		self.topCollisionBlock?.physicsBody?.collisionBitMask = 0
		self.topCollisionBlock?.physicsBody?.contactTestBitMask = Collision().Block
		
		self.bottomCollisionBlock = SKShapeNode.init(rectOf: CGSize.init(width: 50, height: 50))
		self.bottomCollisionBlock?.isHidden = true
		self.bottomCollisionBlock?.position = CGPoint.init(x: 25, y: 25)
		self.bottomCollisionBlock?.zPosition = 3
		self.addChild(self.bottomCollisionBlock!)

		self.bottomCollisionBlock?.physicsBody = SKPhysicsBody.init(rectangleOf: (self.bottomCollisionBlock?.frame.size)!)
		self.bottomCollisionBlock?.physicsBody?.categoryBitMask = Collision().BottomBlock
		self.bottomCollisionBlock?.physicsBody?.collisionBitMask = 0
		self.bottomCollisionBlock?.physicsBody?.contactTestBitMask = Collision().Block
    }
	
	func spawnBlock() {
		let block = SKShapeNode.init(rectOf: CGSize.init(width: 100, height: 150))
		
		let n = arc4random_uniform(UInt32(2))
		print("Rand number: \(n)")
		
		var spawnHeight: CGFloat = 0
		
		if n == 0 {
			spawnHeight = 150 / 2
		} else if n == 1 {
			spawnHeight = self.size.height - (150 / 2)
		}
		
		block.position = CGPoint.init(x: self.size.width, y: spawnHeight)
		block.fillColor = UIColor.green
		block.zPosition = 3
		
		self.addChild(block)
		self.shapeArr.append(block)
		
		block.physicsBody = SKPhysicsBody.init(rectangleOf: block.frame.size)
		block.physicsBody?.categoryBitMask = Collision().Block
		block.physicsBody?.collisionBitMask = 0
		block.physicsBody?.contactTestBitMask = Collision().Player | Collision().TopBlock | Collision().BottomBlock
		
		let action = SKAction.move(to: CGPoint.init(x: -100, y: block.position.y), duration: 3)
		let remove = SKAction.removeFromParent()
		let removeFromArray = SKAction.run {
			self.shapeArr.remove(at: self.shapeArr.startIndex)
		}

		let sequence = SKAction.sequence([action, remove, removeFromArray])
		
		block.run(sequence)
	}
	
	public func didBegin(_ contact: SKPhysicsContact) {
		// player and block
		if (contact.bodyA.categoryBitMask == Collision().Player && contact.bodyB.categoryBitMask == Collision().Block) || (contact.bodyA.categoryBitMask == Collision().Block && contact.bodyB.categoryBitMask == Collision().Player) {
			let remove = SKAction.removeFromParent()
		
			contact.bodyA.node?.run(remove)
			contact.bodyB.node?.run(remove)
			
			self.shapeArr.remove(at: self.shapeArr.startIndex)
			
			let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
			let fetchReq = NSFetchRequest<Record>.init(entityName: "Record")
			do {
				let items = try context.fetch(fetchReq)
				
				print("Number of entries: \(items.count)")
				
				if let score = items.first?.score {
					// if it is a new high score
					let score = Int.init(NSNumber.init(value: score))

					print("Current score: \(self.score)")
					print("Score: \(score)")

					if self.score > score {
						// delete current score
						context.delete(items.first!)

						do {
							try context.save()
						} catch {
							print("Deleting failed!")
						}

						// add new high score
						let highestScore = NSEntityDescription.insertNewObject(forEntityName: "Record", into: context)
						highestScore.setValue(self.score, forKey: "score")

						do {
							try context.save()
						} catch {
							print("Save failed!")
						}
					}
				} else {
					let highestScore = NSEntityDescription.insertNewObject(forEntityName: "Record", into: context)
					highestScore.setValue(self.score, forKey: "score")
					
					do {
						try context.save()
					} catch {
						print("Save failed!")
					}
				}
			} catch {
				print("Fetch fail!")
			}
			
			
			
			let transition = SKTransition.flipHorizontal(withDuration: 2)
			let gameOverScene = GameOverScene.init(size: self.size)
			self.view?.presentScene(gameOverScene, transition: transition)
		}
		
		// top block and block
		if (contact.bodyA.categoryBitMask == Collision().TopBlock && contact.bodyB.categoryBitMask == Collision().Block) || (contact.bodyA.categoryBitMask == Collision().Block && contact.bodyB.categoryBitMask == Collision().TopBlock) {
			self.score += 1
			self.scoreLabel?.text = "Score: \(score)"
		}
		
		// bottom block and block
		if (contact.bodyA.categoryBitMask == Collision().BottomBlock && contact.bodyB.categoryBitMask == Collision().Block) || (contact.bodyA.categoryBitMask == Collision().Block && contact.bodyB.categoryBitMask == Collision().BottomBlock) {
			self.score += 1
			self.scoreLabel?.text = "Score: \(score)"
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touchLocation = touches.first?.location(in: self)

		let moveAction = SKAction.moveTo(y: (touchLocation?.y)!, duration: 1)
//		let moveAction = SKAction.move(to: CGPoint.init(x: (touchLocation?.x)!, y: (touchLocation?.y)!), duration: 1)
		
		self.player.run(moveAction)
	}
	
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
		
		self.backgroundImage.position.x -= 1
		self.backgroundImage2.position.x -= 1
		
		if self.backgroundImage.position.x + self.backgroundImage.size.width <= (self.size.width / 2) {
			self.backgroundImage.position.x = self.size.width / 2
			self.backgroundImage2.position.x = (self.size.width / 2) + self.size.width
		}
    }
}

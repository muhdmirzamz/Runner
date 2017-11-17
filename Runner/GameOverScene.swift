//
//  GameOverScene.swift
//  Runner
//
//  Created by Muhd Mirza on 12/11/17.
//  Copyright © 2017 muhdmirzamz. All rights reserved.
//

import UIKit
import SpriteKit
import CoreData

class GameOverScene: SKScene {
	
	var retryButton: SKSpriteNode?
	var mainMenuButton: SKSpriteNode?
	
	override func didMove(to view: SKView) {
		self.backgroundColor = UIColor.blue
		
		let text = SKLabelNode.init(text: "Game Over")
		text.fontColor = SKColor.white
		text.fontSize = 50
		text.position = CGPoint.init(x: self.size.width / 2, y: 300)
		self.addChild(text)
		
		var highestScore = 0
		
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		let fetchReq = NSFetchRequest<Record>.init(entityName: "Record")
		do {
			let items = try context.fetch(fetchReq)
			
			if let score = items.first?.score {
				highestScore = Int.init(NSNumber.init(value: score))
			}
		} catch {
			print("Fetch fail!")
		}
		
		let highestScoreText = SKLabelNode.init(text: "Highest Score: \(highestScore)")
		highestScoreText.fontColor = SKColor.white
		highestScoreText.fontSize = 50
		highestScoreText.position = CGPoint.init(x: self.size.width / 2, y: 200)
		self.addChild(highestScoreText)
		
		self.retryButton = SKSpriteNode.init(color: UIColor.black, size: CGSize.init(width: 200, height: 50))
		self.retryButton?.position = CGPoint.init(x: highestScoreText.position.x, y: 120)
		self.addChild(self.retryButton!)
		
		let retryButtonLabel = SKLabelNode.init(text: "Retry")
		retryButtonLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
		retryButtonLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
		self.retryButton?.addChild(retryButtonLabel)
		
		self.mainMenuButton = SKSpriteNode.init(color: UIColor.black, size: CGSize.init(width: 200, height: 50))
		self.mainMenuButton?.position = CGPoint.init(x: highestScoreText.position.x, y: 60)
		self.addChild(self.mainMenuButton!)
		
		let mainMenuButtonLabel = SKLabelNode.init(text: "Main Menu")
		mainMenuButtonLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
		mainMenuButtonLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
		self.mainMenuButton?.addChild(mainMenuButtonLabel)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first?.location(in: self) {
			if (self.retryButton?.contains(touch))! {
				let transition = SKTransition.fade(withDuration: 1)
				let gameScene = GameScene.init(size: self.size)
				
				self.view?.presentScene(gameScene, transition: transition)
			}
			
			if (self.mainMenuButton?.contains(touch))! {
				let transition = SKTransition.fade(withDuration: 1)
				let mainMenuScene = MainMenuScene.init(size: self.size)
				
				self.view?.presentScene(mainMenuScene, transition: transition)
			}
		}
	}
}

//
//  GameScene.swift
//  Macro_InternalShocase
//
//  Created by 원주연 on 10/18/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var mainViewBG : SKSpriteNode?
    private var levelBG : SKSpriteNode?
    private var setting : SKSpriteNode?
    private var book : SKSpriteNode?
    private var blueberryBG : SKSpriteNode?
    private var blueberry : SKSpriteNode?
    private var hale : SKSpriteNode?
    private var textBox: SKSpriteNode?
    // 상태 추적 변수 (0: 텍스트박스 없음, 1: 텍스트박스1, 2: 텍스트박스2)
    private var textBoxState = 0
    
    // 뷰 전체 폭 길이
    let screenWidth = UIScreen.main.bounds.size.width
    // 뷰 전체 높이 길이
    let screenHeight = UIScreen.main.bounds.size.height
    
    override func didMove(to view: SKView) {
        mainViewBG = childNode(withName: "MainViewBG") as? SKSpriteNode
        mainViewBG?.size = CGSize(width: screenWidth, height: screenHeight)
        mainViewBG?.position = CGPoint(x: 0, y: 0)
        
        hale = childNode(withName: "Hale") as? SKSpriteNode
        hale?.name = "hale"
        hale?.anchorPoint = CGPoint(x: 1, y: 1)
        hale?.position = CGPoint(x: screenWidth/2 - 2, y: screenHeight/2 - 288)
        
        levelBG = childNode(withName: "LevelBG") as? SKSpriteNode
        levelBG?.anchorPoint = CGPoint(x: 0, y: 1)
        levelBG?.position = CGPoint(x: -screenWidth/2 + 20, y: screenHeight/2 - 60)
        
        setting = childNode(withName: "SettingImg") as? SKSpriteNode
        setting?.anchorPoint = CGPoint(x: 1, y: 1)
        setting?.position = CGPoint(x: screenWidth/2 - 20, y: screenHeight/2 - 60)
        
        book = childNode(withName: "BookImg") as? SKSpriteNode
        book?.anchorPoint = CGPoint(x: 1, y: 1)
        book?.position = CGPoint(x: screenWidth/2 - 20, y: screenHeight/2 - 122)
        
        blueberryBG = childNode(withName: "BlueberryBGImg") as? SKSpriteNode
        blueberryBG?.anchorPoint = CGPoint(x: 0, y: 0)
        blueberryBG?.position = CGPoint(x: -screenWidth/2 + 140, y: -screenHeight/2 + 60)
        
        blueberry = childNode(withName: "Blueberry") as? SKSpriteNode
        blueberry?.name = "blueberry"
        blueberry?.anchorPoint = CGPoint(x: 0, y: 0)
        blueberry?.position = CGPoint(x: -screenWidth/2 + 141, y: -screenHeight/2 + 79)
        //        let eatAnimation = SKAction.move(to: CGPoint(x: 60, y: -130), duration: 0.7)
        
    }
    
    func eatingHale() {
        let hale1 = SKTexture(imageNamed: "Hale")
        let hale2 = SKTexture(imageNamed: "EatingHale")
        
        let eatingHaleTexture = [hale1, hale2]
        let eatingHaleAnimation = SKAction.animate(with: eatingHaleTexture, timePerFrame: 0.2, resize: false, restore: true)
        let runTime = SKAction.repeat(eatingHaleAnimation, count: 3)
        hale?.run(runTime)
        
    }
    
    func eatBlueberry() {
        let newBlueberry = blueberry?.copy() as! SKSpriteNode
        newBlueberry.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        newBlueberry.position = CGPoint(x: -screenWidth/2 + 191, y: -screenHeight/2 + 129)
        addChild(newBlueberry)
        let eatAnimation = SKAction.move(to: CGPoint(x: screenWidth/2 - 135, y: -20), duration: 0.7)
        let sizeDownAnimation = SKAction.resize(toWidth: 0, height: 0, duration: 0.7)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([eatAnimation, sizeDownAnimation, removeAction])
        newBlueberry.run(sequence)
    }
    
    func viewTextBox() {
        switch textBoxState {
        case 0:
            // 텍스트박스1 표시
            textBox = SKSpriteNode(imageNamed: "TextBox1")
            textBox?.zPosition = 3
            textBox?.anchorPoint = CGPoint(x: 0, y: 0.5)
            textBox?.position = CGPoint(x: -screenWidth/2 + 30, y: -140)
            addChild(textBox!)
            textBoxState = 1
            
        case 1:
            // 텍스트박스1 제거, 텍스트박스2 표시
            textBox?.texture = SKTexture(imageNamed: "TextBox2")
            textBoxState = 2
            
        case 2:
            // 텍스트박스2 제거
            textBox?.removeFromParent()
            textBox = nil
            textBoxState = 0
            
        default:
            break
        }
        //        if textBox == nil {
        //            textBox = SKSpriteNode(imageNamed: "TextBox1")
        //            textBox?.zPosition = 3
        //            textBox?.anchorPoint = CGPoint(x: 0, y: 0.5)
        //            textBox?.position = CGPoint(x: -screenWidth/2 + 30, y: -140)
        //            addChild(textBox!)
        //        } else {
        //            // 이미 텍스트 박스가 있으면 제거
        //            textBox?.removeFromParent()
        //            textBox = nil
        //        }
        
        
        //        let textBox = SKSpriteNode(imageNamed: "TextBox1")
        //        textBox.zPosition = 3
        //        textBox.anchorPoint = CGPoint(x: 0, y: 0.5)
        //        textBox.position = CGPoint(x: -screenWidth/2 + 30, y: -140)
        //        addChild(textBox)
        //        let textBox1 = SKTexture(imageNamed: "TextBox1")
        //        let textBox2 = SKTexture(imageNamed: "TextBox2")
        //        let textBoxTexture = [textBox1, textBox2]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let touchedNode = self.atPoint(location)
            
            if touchedNode.name == "blueberry" {
                eatBlueberry()
                eatingHale()
            }
            
            if touchedNode.name == "hale" {
                viewTextBox()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

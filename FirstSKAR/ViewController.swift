//
//  ViewController.swift
//  SceneKitApp
//
//  Created by 井手翔平 on 2023/12/06.
//

import UIKit
import SceneKit
import ARKit
import RealityKit

class ViewController: UIViewController, ARSCNViewDelegate, ARCoachingOverlayViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        //sceneView.debugOptions = [ARSCNDebugOptions.showWireframe]
        
        // Set up ARCoachingOverlayView
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = sceneView.session
        coachingOverlay.delegate = self
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(coachingOverlay)

        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        coachingOverlay.activatesAutomatically = true
        coachingOverlay.goal = .horizontalPlane

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
       

        // Run the view's session
        sceneView.session.run(configuration)
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //3個以上押したらクリアにする
        
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    func addDot(at hitResult: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.0005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y,hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate () {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print(start.position)
        print(end.position)
        
        let distance = sqrt(
            pow(end.position.x - start.position.x,2) +
            pow(end.position.y - start.position.y,2) +
            pow(end.position.z - start.position.z,2)
        )
        //distance = √((x2-x2)2 + (y2-y1)2 + (z2-z1)2)
        
        //絶対値にへんかん。符号興味ない
        updateText(text: "\(abs(distance))", atPosition: end.position)
    }
    
    
    func updateText(text: String, atPosition position: SCNVector3) {
        
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(position.x,position.y + 0.01,position.z)
        
        textNode.scale = SCNVector3(0.01, 0.01,0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }

}

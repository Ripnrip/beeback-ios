/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController, Storyboarded {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    
    // The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = StatusViewController()
    
    /// The tab bar the controls the transition
    lazy var tabBarViewController: PTTabBarViewController = {
        return children.lazy.compactMap({ $0 as? PTTabBarViewController }).first!
    }()
    
    var focusPlaneSelector: FocusPlaneSelector = FocusPlaneSelector()
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession { return sceneView.session }
    
    // ARCoachOverlay
    let guidanceOverlay = ARCoachingOverlayView()

    // Session Properties
    /// Prevents restarting the session while a restart is in progress.
    var isRestartAvailable = true
    
    /// Used to determine if detect plane is needed
    var didDectectPlane = false
    
    /// used to specify if game has started
    var didGameStart = false
    
    //Box node
    var arTrackingBox: SCNNode = {
        let node = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.1/2))
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "BeeBackAR.png")!
        return node
    }()
    
    // container
    var container: SCNNode = {
        let scene = SCNScene(named: "art.scnassets/game.scn")!
         let gameNode = scene.rootNode.childNode(withName: "container", recursively: false)!
         return gameNode
     }()
    
    var directionalLightNode: SCNNode?
    var ambientLightNode: SCNNode?
    
    var ballNodes : [SCNNode] = {
        let scene = SCNScene(named: "art.scnassets/game.scn")!
        let ballsParentNode = scene.rootNode.childNode(withName: "balls", recursively: false)!
        return ballsParentNode.childNodes
    }()
    
    var ballCount : Int = 0
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/scene4.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGestureRecognizer.delegate = self
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        

        setStatusViewController()
        
        sceneView.scene.rootNode.addChildNode(focusPlaneSelector)
        self.setOverlay()
        

    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed to avoid interuppting the AR experience.
		UIApplication.shared.isIdleTimerDisabled = true

        // Start the AR experience
        resetTracking()
        sceneView.debugOptions = [
//            .showWorldOrigin,
//            .showSkeletons,
//            .showWireframe,
//            .showFeaturePoints,
//            .showBoundingBoxes
        ]
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
        
        session.pause()
	}

    func setStatusViewController() {
        addChild(statusViewController)
        statusViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.sceneView.addSubview(statusViewController.view)
        
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        
        NSLayoutConstraint.activate([
            statusViewController.view.heightAnchor.constraint(equalToConstant: 85),
            statusViewController.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statusViewController.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            statusViewController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])
    }
    
    func updateFocusPlaneSelector(isObjectVisible: Bool){

        if isObjectVisible || guidanceOverlay.isActive {
            focusPlaneSelector.hide()
        } else {
            focusPlaneSelector.unhide()
        }
        
        // Perform ray casting only when ARKitTracking is in a good state.
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
           let query = sceneView.getRaycastQuery(),
           let result = sceneView.castRay(for: query).first {
            
            updateQueue.async {
//                self.sceneView.scene.rootNode.addChildNode(self.focusPlaneSelector)
                self.focusPlaneSelector.state = .detecting(raycastResult: result, camera: camera)
            }
        }
    }
    
    func setScene3Dlocation(_ object: SCNNode) {
        guard let raycastQuery = sceneView.getRaycastQuery(for: .horizontal),
           let result = sceneView.castRay(for: raycastQuery).first else {
            self.statusViewController.showMessage("CANNOT PLACE OBJECT\nTry moving left or right.")
            print("CANNOT PLACE OBJECT\nTry moving left or right.")
            return
        }
        
        object.simdWorldTransform = result.worldTransform
        
        session.trackedRaycast(raycastQuery) { (results) in
            guard let result = results.first else {
                fatalError("Unexpected case: the update handler is always supposed to return at least one result.")
            }
            object.simdWorldTransform = result.worldTransform
            self.updateQueue.async {
                let newAnchor = ARAnchor(transform: object.simdWorldTransform)
                self.session.add(anchor: newAnchor)
            }
            
            self.sceneView.scene.rootNode.addChildNode(object)
//            if object.parent == nil {
//                print("scnnNode Parent is NIL")
//                self.sceneView.scene.rootNode.addChildNode(arObject)
//            }
        }
    }
    
}

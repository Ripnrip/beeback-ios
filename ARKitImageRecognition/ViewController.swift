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
//    lazy var statusViewController?: StatusViewController = {
//        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
//    }()
    lazy var statusViewController: StatusViewController = StatusViewController()
    
    /// The tab bar the controls the transition
    lazy var tabBarViewController: PTTabBarViewController = {
        return children.lazy.compactMap({ $0 as? PTTabBarViewController }).first!
    }()
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    // ARCoachOverlay
    
    
    //Box node
    var box: SCNNode? = nil
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        sceneView.delegate = self
        sceneView.session.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        // Hook up status view controller callback(s).
        setStatusViewController()
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        
        
//        self.sceneView.addSubview(children[0].view)
        
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed to avoid interuppting the AR experience.
		UIApplication.shared.isIdleTimerDisabled = true

        // Start the AR experience
        resetTracking()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

        session.pause()
	}

    // MARK: - Session management (Image detection setup)
    
    /// Prevents restarting the session while a restart is in progress.
    var isRestartAvailable = true

    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
	func resetTracking() {
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        
        statusViewController.scheduleMessage("Look around to discover nearby items", inSeconds: 5.5, messageType: .contentPlacement)
        if box == nil {
            delayWithSeconds(7) { [weak self] in
                self?.addNode()
            }
        }
        
	}

    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if hitTest.isEmpty {
            print("didn't touch anything")
        } else {
            if sceneViewTappedOn.tag == 1 {
                //show youtube ad
                UIApplication.shared.openURL(URL(string: "https://www.youtube.com/watch?v=k6UF2uZprYQ")!)
                return
            }
            let results = hitTest.first!
            let geometry = results.node.geometry
            print(geometry)
            let distanceFromBox = distance(from: results.node.position)
            print("the distance from the box is \(distanceFromBox)")
            
            if distanceFromBox < 2 {
                let alert = UIAlertController(title: "Alert", message: "Tapped the mystery box", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Open", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Alert", message: "You are too far from the mystery box", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Open", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }

        }
    }
    
    func distance(from vector: SCNVector3) -> Float {
        let distanceX = (sceneView.pointOfView?.position.x)! - vector.x
        let distanceY = (sceneView.pointOfView?.position.y)! - vector.y
        let distanceZ = (sceneView.pointOfView?.position.z)! - vector.z
        return sqrtf((distanceX * distanceX) + (distanceY * distanceY) + (distanceZ * distanceZ))
    }
    
    func setStatusViewController() {
        addChild(statusViewController)
        statusViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusViewController.view)
        
        NSLayoutConstraint.activate([
            statusViewController.view.heightAnchor.constraint(equalToConstant: 85),
            statusViewController.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statusViewController.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            statusViewController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])
    }
    
}

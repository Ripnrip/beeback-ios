/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility class for showing messages above the AR view.
*/

import Foundation
import ARKit

/**
 Displayed at the top of the main interface of the app that allows users to see
 the status of the AR experience, as well as the ability to control restarting
 the experience altogether.
*/
class StatusViewController: UIViewController {

    enum MessageType {
        case trackingStateEscalation
        case contentPlacement

        static var all: [MessageType] = [
            .trackingStateEscalation,
            .contentPlacement
        ]
    }

    // MARK: - IBOutlets
    var messagePanel : MessagePanelView = MessagePanelView(frame: .zero)
//    var messageLabel : UILabel = UILabel()
    var restartExperienceButton: UIButton = UIButton(type: .custom)
    var stackView : UIStackView = UIStackView()

    // MARK: - Properties
    
    /// Trigerred when the "Restart Experience" button is tapped.
    var restartExperienceHandler: () -> Void = {}
    
    /// Seconds before the timer message should fade out. Adjust if the app needs longer transient messages.
    private let displayDuration: TimeInterval = 6
    
    // Timer for hiding messages.
    private var messageHideTimer: Timer?
    
    private var timers: [MessageType: Timer] = [:]
    
    // MARK: - Message Handling
	
	func showMessage(_ text: String, autoHide: Bool = true) {
        // Cancel any previous hide timer.
        messageHideTimer?.invalidate()
        messagePanel.setMessage(text)

        // Make sure status is showing.
        setMessageHidden(false, animated: true)

        if autoHide {
            messageHideTimer = Timer.scheduledTimer(withTimeInterval: displayDuration, repeats: false, block: { [weak self] _ in
                self?.setMessageHidden(true, animated: true)
            })
        }
	}
    
	func scheduleMessage(_ text: String, inSeconds seconds: TimeInterval, messageType: MessageType) {
        cancelScheduledMessage(for: messageType)

        let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [weak self] timer in
            self?.showMessage(text)
            timer.invalidate()
		})

        timers[messageType] = timer
	}
    
    func cancelScheduledMessage(for messageType: MessageType) {
        timers[messageType]?.invalidate()
        timers[messageType] = nil
    }

    func cancelAllScheduledMessages() {
        for messageType in MessageType.all {
            cancelScheduledMessage(for: messageType)
        }
    }
    
    // MARK: - ARKit
    
	func showTrackingQualityInfo(for trackingState: ARCamera.TrackingState, autoHide: Bool) {
		showMessage(trackingState.presentationString, autoHide: autoHide)
	}
	
	func escalateFeedback(for trackingState: ARCamera.TrackingState, inSeconds seconds: TimeInterval) {
        cancelScheduledMessage(for: .trackingStateEscalation)

		let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [unowned self] _ in
            self.cancelScheduledMessage(for: .trackingStateEscalation)

            var message = trackingState.presentationString
            if let recommendation = trackingState.recommendation {
                message.append(": \(recommendation)")
            }

            self.showMessage(message, autoHide: false)
		})

        timers[.trackingStateEscalation] = timer
    }
    
    // MARK: - Panel Visibility
    
	private func setMessageHidden(_ hide: Bool, animated: Bool) {
        // The panel starts out hidden, so show it before animating opacity.
        messagePanel.isHidden = false
        
        guard animated else {
            messagePanel.alpha = hide ? 0 : 1
            return
        }

        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.messagePanel.alpha = hide ? 0 : 1
        }, completion: nil)
	}
    
}

// MARK: - Lifecyle
extension StatusViewController {
    override func viewDidLoad() {
        self.setMessageHidden(true, animated: false)
        setRestartExperienceButton()
        setStackView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        stackView.frame = view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    

    func statusViewLayout(){
        messagePanel.translatesAutoresizingMaskIntoConstraints = false
        restartExperienceButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            restartExperienceButton.widthAnchor.constraint(equalToConstant: 44),
            restartExperienceButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            restartExperienceButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            messagePanel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            messagePanel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            messagePanel.trailingAnchor.constraint(lessThanOrEqualTo: restartExperienceButton.leadingAnchor, constant: -8)

        ])
    }
    
    func setStackView() {
        messagePanel.translatesAutoresizingMaskIntoConstraints = false
        restartExperienceButton.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
        
        stackView.addArrangedSubview(messagePanel)
        stackView.addArrangedSubview(restartExperienceButton)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setRestartExperienceButton(){
        let imageSize: CGSize = CGSize(width: 60, height: 60)
        restartExperienceButton.setImage(UIImage(named: "restart"), for: .normal)
        restartExperienceButton.setImage(UIImage(named: "restartPressed"), for: .selected)
        restartExperienceButton.imageView?.contentMode = .scaleAspectFill
        
        restartExperienceButton.imageEdgeInsets = UIEdgeInsets(
            top: (restartExperienceButton.frame.size.height - imageSize.height) / 2,
            left: (restartExperienceButton.frame.size.width - imageSize.width) / 2,
            bottom: (restartExperienceButton.frame.size.height - imageSize.height) / 2,
            right: (restartExperienceButton.frame.size.width - imageSize.width) / 2
        )
        
        restartExperienceButton.addTarget(self, action: #selector(restartExperience), for: .touchUpInside)
    }
    
    @objc func restartExperience(){
        restartExperienceHandler()
    }
}

extension ARCamera.TrackingState {
    var presentationString: String {
        switch self {
        case .notAvailable:
            return "TRACKING UNAVAILABLE"
        case .normal:
            return "TRACKING NORMAL"
        case .limited(.excessiveMotion):
            return "TRACKING LIMITED\nExcessive motion"
        case .limited(.insufficientFeatures):
            return "TRACKING LIMITED\nLow detail"
        case .limited(.initializing):
            return "Initializing"
        case .limited(.relocalizing):
            return "Recovering from session interruption"
        }
    }

    var recommendation: String? {
        switch self {
        case .limited(.excessiveMotion):
            return "Try slowing down your movement, or reset the session."
        case .limited(.insufficientFeatures):
            return "Try pointing at a flat surface, or reset the session."
        case .limited(.relocalizing):
            return "Try returning to where you were when the interruption began, or reset the session."
        default:
            return nil
        }
    }
}



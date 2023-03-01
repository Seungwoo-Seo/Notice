//
//  ViewController.swift
//  Notice
//
//  Created by 서승우 on 2023/02/24.
//

import UIKit
import FirebaseRemoteConfig
import FirebaseAnalytics

class ViewController: UIViewController {
    
    var remoteConfig: RemoteConfig?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        remoteConfig = RemoteConfig.remoteConfig()
        
        let setting = RemoteConfigSettings()
        setting.minimumFetchInterval = 0
        
        remoteConfig?.configSettings = setting
        remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefaults")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getNotice()
    }
    
}

// remoteConfig
extension ViewController {
    
    func getNotice() {
        guard let remoteConfig = self.remoteConfig else {return}
        
        remoteConfig.fetch { [weak self] status, error in
            if status == .success {
                remoteConfig.activate(completion: nil)
            } else {
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            
            
            guard let self = self else {return}
            
            if !self.isNoticeHidden(remoteConfig) {
                let noticeVC = NoticeViewController(nibName: "NoticeViewController", bundle: nil)
                noticeVC.modalPresentationStyle = .custom
                noticeVC.modalTransitionStyle = .crossDissolve
                
                let title = (remoteConfig["title"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                let detail = (remoteConfig["detail"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                let date = (remoteConfig["date"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                
                noticeVC.noticeContents = (title: title, detail: detail, date: date)
                self.present(noticeVC, animated: true)
            } else {
                self.showEventAlert()
            }
        }
    }
    
    func isNoticeHidden(_ remoteConfig: RemoteConfig) -> Bool {
        return remoteConfig["isHidden"].boolValue
    }
    
}

// a/b testing
extension ViewController {
    
    func showEventAlert() {
        guard let remoteConfig = self.remoteConfig else {return}
        
        remoteConfig.fetch { [weak self] status, error in
            if status == .success {
                remoteConfig.activate(completion: nil)
            } else {
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            
            guard let self = self else {return}
            
            let message = remoteConfig["message"].stringValue ?? ""
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            
            let confirmAction = UIAlertAction(title: "확인하기", style: .default) { _ in
                // google Analytics
                Analytics.logEvent("promotion_alert", parameters: nil)
            }
            
            let alert = UIAlertController(title: "깜짝이벤트", message: message, preferredStyle: .alert)
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            
            self.present(alert, animated: true)
        }
    }
    
}

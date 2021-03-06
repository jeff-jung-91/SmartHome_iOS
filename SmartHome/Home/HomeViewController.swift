//
//  HomeViewController.swift
//  SmartHome
//
//  Created by jeff on 2020/06/04.
//  Copyright © 2020 TakHyun Jung. All rights reserved.
//

import UIKit
import SwiftyJSON
import AWSIoT
import UserNotifications


class HomeViewController: UIViewController {
    
    @IBOutlet weak var airSwitch: UISwitch!
    @IBOutlet weak var roomSwitch: UISwitch!
    @IBOutlet weak var bedSwitch: UISwitch!
    @IBOutlet var airButton: [UIButton]!
    @IBOutlet weak var tempertureLabel: UILabel!
    @IBOutlet weak var humidtyLabel: UILabel!
    
    var topic = "$aws/things/MyMKRWiFi1010/shadow/update"
    var awsiot = AwsIotConnect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Switch resize
        airSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        roomSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        bedSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        // Aws connect
        awsiot.awsConnect()
        
        // Notificaton permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (result, Error) in
            print(result)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        registerSubscriptions()
        
    }
    // Make toggle Button`
    @IBAction func touchAirButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        
    }
    
    @IBAction func doorOpenBtn(_ sender: UIButton) {
        
        let content = UNMutableNotificationContent()
        content.title = "알림"
        content.body = "손님이 왔습니다"
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        // Request Notification
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    
    // Subscribe temp & humidity
    func registerSubscriptions() {
        func messageReceived(payload: Data) {
            let payloadDictionary = JSON(payload)
            // Handle message event here...
            let temp = payloadDictionary["state"]["reported"]["temperature"].string
            let hum = payloadDictionary["state"]["reported"]["humidity"].string
            let visit = payloadDictionary["state"]["reported"]["switch"].string
            print(payloadDictionary)
            DispatchQueue.main.async {
                do {
                    self.tempertureLabel.text = "현재 온도 \(temp ?? "30.0") ˚"
                    self.humidtyLabel.text = "현재 습도 \(hum ?? "35" )%"
                    
                } catch {
                    print("Error, failed to connect to device gateway => \(error)")
                }
            }
            
            print(visit)
            if let visit = visit {
                // visitor come
                if visit == "ON" {
                    let content = UNMutableNotificationContent()
                    content.title = "알림"
                    content.body = "손님이 왔습니다"
                    content.badge = 1
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
                    // Request Notification
                    let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                }
            }
            
            
            
        }
        let dataManager = AWSIoTDataManager(forKey: "kDataManager")
        
        dataManager.subscribe(toTopic: topic,
                              qoS: .messageDeliveryAttemptedAtLeastOnce,  // Set according to use case
            messageCallback: messageReceived)
    }
    
}

////View에 Border 추가
//extension CALayer {
//    func addBorder(arrEdge: [UIRectEdge], color: UIColor, width: CGFloat) {
//        for edge in arrEdge {
//            let border = CALayer()
//            switch edge {
//            case UIRectEdge.top:
//                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
//            case UIRectEdge.bottom:
//                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
//            case UIRectEdge.left:
//                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
//            case UIRectEdge.right:
//                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
//            default:
//                break
//            }
//            border.backgroundColor = color.cgColor
//            self.addSublayer(border)
//        }
//    }
//}

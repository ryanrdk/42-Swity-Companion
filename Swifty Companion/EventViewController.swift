//
//  ViewController.swift
//  42Events
//
//  Created by Samantha HILLEBRAND on 2019/10/12.
//  Copyright © 2019 Rush00Team. All rights reserved.
//

import UIKit

class AlertInfo {
//    ALERT_MESSAGE
    func showAlert(fromController controller: UIViewController, messages: String) {
        let alert = UIAlertController(title: "Info", message: messages, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "FeelsBadMan", style: .cancel, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
}

class EventViewController: UIViewController {

    @IBOutlet var name: UILabel!
    @IBOutlet var nSub: UITextField!
    @IBOutlet var mSub: UITextField!
    @IBOutlet var desc: UITextView!
    @IBOutlet var date: UITextField!
    @IBOutlet var bTim: UITextField!
    @IBOutlet var eTim: UITextField!
    @IBOutlet var dura: UITextField!
    @IBOutlet var locn: UITextField!
    @IBOutlet var kind: UITextField!
    @IBOutlet weak var subS: UIButton!
    @IBAction func subSButtonPress(_ sender: Any) {
        let alert = AlertInfo()
        alert.showAlert(fromController: self, messages: "Would be able to subscribe if possible.")
    }
    
    var data: EventData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Proof of correlating campus id? Un-comment line below
        //  print("Campus ID = \(String(describing: data?.campus_ids[0]))")
        
        name.text = data?.name
        name.isUserInteractionEnabled = false
        if let nbr = data?.nbr_subs {
            nSub.text = String(nbr)
        } else {
            nSub.text = "0"
        }
        nSub.isUserInteractionEnabled = false
        if let max = data?.max_subs {
            mSub.text = String(max)
        } else {
            mSub.text = "120"
        }
        mSub.isUserInteractionEnabled = false
        desc.text = data?.desc
        date.text = formatDate(date: data!.begin_at)
        date.isUserInteractionEnabled = false
        bTim.text = formatTime(date: data!.begin_at)
        bTim.isUserInteractionEnabled = false
        eTim.text = formatTime(date: data!.end_at)
        eTim.isUserInteractionEnabled = false
        dura.text = "\(formatDuration(dateStart: data!.begin_at, dateEnd: data!.end_at)) hours"
        dura.isUserInteractionEnabled = false
        locn.text = data?.location
        locn.isUserInteractionEnabled = false
        kind.text = data?.kind
        kind.isUserInteractionEnabled = false
    }

    func formatDate(date: String) -> String{
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        //format.locale = Locale(identifier: "en_US_POSIX")
        let newDate = format.date(from: date)
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: newDate ?? Date())
    }
    func formatTime(date: String) -> String{
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        //format.locale = Locale(identifier: "en_US_POSIX")
        let newDate = format.date(from: date)
        format.dateFormat = "MM-dd'T'HH:mm"
        return format.string(from: newDate ?? Date())
    }
    func formatDuration(dateStart: String, dateEnd: String) -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        //format.locale = Locale(identifier: "en_US_POSIX")
        let newStartDate = format.date(from: dateStart)
        let newEndDate = format.date(from: dateEnd)
        let duration = newEndDate?.timeIntervalSince(newStartDate!)
        return String((duration ?? 128000) / 3600)
    }
}


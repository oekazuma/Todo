//
//  AddTaskViewController.swift
//  Todo
//
//  Created by 大江和摩 on 2017/06/08.
//  Copyright © 2017年 HAL. All rights reserved.
//

import UIKit
import UserNotifications

class AddTaskViewController: UIViewController, UITextFieldDelegate, UNUserNotificationCenterDelegate {
    
    // MARK: - Properties
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var task: Task?
    
    @IBOutlet weak var taskTextField: UITextField!
    
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var datepicker: UIDatePicker!
    
    var flg: Int = 0

    
    let uuid = NSUUID().uuidString
    
    @IBAction func switchChange(_ sender: UISwitch) {
       
        self.flg = sender.isOn ? 1:0
        if sender.isOn {
             datepicker.isHidden = !sender.isOn
        }
        else{
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["uuid: \(uuid)"])
            let switchButton = self.view.viewWithTag(1) as! UISwitch
            switchButton.isOn = false
            self.datepicker.isHidden = true
        }
    }
    
     private var isNotificationAuthed: Bool = false
    
    // MARK: -
    
    var taskCategory = "ToDo"
    
     // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categorySegmentedControl.layer.cornerRadius = 5
        
        self.datepicker.isHidden = true
       
        
        // taskに値が代入されていたら、textFieldとsegmentedControlにそれを表示
        if let task = task {
            taskTextField.text = task.name
            taskCategory = task.category!
            switch task.category! {
            case "ToDo":
                categorySegmentedControl.selectedSegmentIndex = 0
            case "Shopping":
                categorySegmentedControl.selectedSegmentIndex = 1
            case "Job":
                categorySegmentedControl.selectedSegmentIndex = 2
            case "School":
                categorySegmentedControl.selectedSegmentIndex = 3
            default:
                categorySegmentedControl.selectedSegmentIndex = 0
            }
            
            datepicker.date = task.date! as Date
        let nowDate: Date = Date()
        if nowDate.timeIntervalSince1970 <= datepicker.date.timeIntervalSince1970 {
           //switchをonにする
            let switchButton = self.view.viewWithTag(1) as! UISwitch
            switchButton.isOn = true
            self.datepicker.isHidden = false
        }
            
            
        }
        
        // Do any additional setup after loading the view.
        
        self.taskTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
            if error != nil {
                return
            }
            
            if granted {
                self.isNotificationAuthed = true
                debugPrint("通知許可")
            } else {
                self.isNotificationAuthed = false
                debugPrint("通知拒否")
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_
        textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
     // MARK: - Actions of Buttons
    
    @IBAction func categoryChosen(_ sender: Any) {
        // choose category of task
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            taskCategory = "ToDo"
        case 1:
            taskCategory = "Shopping"
        case 2:
            taskCategory = "Job"
        case 3:
            taskCategory = "School"
        default:
            taskCategory = "ToDo"
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func plusButtonTapped(_ sender: Any) {
        
        let taskName = taskTextField.text
        
        if taskName == "" {
            let alert: UIAlertController = UIAlertController(title: "エラー", message: "タスク名が入力されていません！", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.show(alert, sender: nil)
            return
        }
        
        if self.flg == 1 {
        
            if !self.isNotificationAuthed {
                // 許可なしの場合は弾く
                let alert: UIAlertController = UIAlertController(title: "エラー", message: "通知が許可されていません。設定アプリより許可をしてください。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.show(alert, sender: nil)
                return
            }
            let nowDate: Date = Date()
        
            let pickerDate: Date = self.datepicker.date
        
            if pickerDate.timeIntervalSince1970 <= nowDate.timeIntervalSince1970 {
                // 現在時刻より前の通知は設定できないので弾く
                let alert: UIAlertController = UIAlertController(title: "エラー", message: "通知時刻は現在時刻より後の時刻を指定してください", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.show(alert, sender: nil)
                return
            }
        
            let yearFormatter: DateFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
        
            let monthFormatter: DateFormatter = DateFormatter()
            monthFormatter.dateFormat = "MM"
        
            let dayFormatter: DateFormatter = DateFormatter()
            dayFormatter.dateFormat = "dd"
        
            let hourFormatter: DateFormatter = DateFormatter()
            hourFormatter.dateFormat = "HH"
        
            let minFormatter: DateFormatter = DateFormatter()
            minFormatter.dateFormat = "mm"
        
            // 通知時刻の指定
            var dateComponents: DateComponents = DateComponents()
            dateComponents.setValue(Int(yearFormatter.string(from: pickerDate)), for: .year)
            dateComponents.setValue(Int(monthFormatter.string(from: pickerDate)), for: .month)
            dateComponents.setValue(Int(dayFormatter.string(from: pickerDate)), for: .day)
            dateComponents.setValue(Int(hourFormatter.string(from: pickerDate)), for: .hour)
            dateComponents.setValue(Int(minFormatter.string(from: pickerDate)), for: .minute)
            let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
            // 通知の内容指定
            let content = UNMutableNotificationContent()
            content.title = taskName!
            content.body = taskCategory
            content.sound = UNNotificationSound.default()
            
            
            // 通知の設定
            
            let calendarRequest = UNNotificationRequest(identifier: "uuid: \(uuid)",
                                                        content: content,
                                                        trigger: calendarTrigger)
            UNUserNotificationCenter.current().add(calendarRequest, withCompletionHandler: nil)
        
            debugPrint(dateComponents)
        }
        

        
        // 受け取った値が空であれば、新しいTask型オブジェクトを作成する
        if task == nil {
            task = Task(context: context)
        }
        
        if let task = task {
            task.name = taskName
            task.category = taskCategory
            task.date = self.datepicker.date as NSDate
        }
        
        // 変更内容を保存する
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        dismiss(animated: true, completion: nil)
        
       
        }
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // アプリ内で通知を受信した時の処理
        debugPrint("通知受信")
    }
    



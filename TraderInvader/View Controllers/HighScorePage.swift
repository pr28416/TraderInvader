//
//  HighScorePage.swift
//  TraderInvader
//
//  Created by Pranav Ramesh on 4/3/19.
//  Copyright © 2019 Pranav Ramesh. All rights reserved.
//

import UIKit

var highScores = [[Any]]()
// Format: [ [Player Name, Time(min) ]

class HighScorePage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var highScoreLabel: UILabel!
    @IBOutlet var highScoreTable: UITableView!
    @IBOutlet var toolbar: UIToolbar!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if highScores.count > 99 {
            return 99
        } else {
            return highScores.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scoreCell", for: indexPath) as! scoreCell
        cell.numPlace.text = String(describing: indexPath.row+1)
        cell.playerName.text = highScores[indexPath.row][0] as? String ?? "Unnamed"
        cell.timeTaken.text = "Score: \(highScores[indexPath.row][2])"
        cell.numPlace.layer.masksToBounds = true
        cell.numPlace.layer.cornerRadius = 26.75
        switch (indexPath.row+1) % 5 {
        case 0:
            cell.numPlace.backgroundColor = UIColor(red: 145/255, green: 48/255, blue: 145/255, alpha: 1)
        case 1:
            cell.numPlace.backgroundColor = UIColor(red: 255/255, green: 105/255, blue: 96/255, alpha: 1)
        case 2:
            cell.numPlace.backgroundColor = UIColor(red: 74/255, green: 165/255, blue: 225/255, alpha: 1)
        case 3:
            cell.numPlace.backgroundColor = UIColor(red: 95/255, green: 197/255, blue: 98/255, alpha: 1)
        case 4:
            cell.numPlace.backgroundColor = UIColor(red: 240/255, green: 205/255, blue: 70/255, alpha: 1)
        default:
            cell.numPlace.backgroundColor = UIColor(red: 255/255, green: 105/255, blue: 96/255, alpha: 1)
        }
        return cell
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if highScores.count > 1 {
            var x = highScores
            let n = highScores.count - 2
            var swap = false
            var temp: [Any] = []
            repeat {
                swap = false
                for i in 0 ... n {
                    if (x[i][2] as! Int) < (x[i+1][2] as! Int) {
                        temp = x[i]
                        x[i] = x[i+1]
                        x[i+1] = temp
                        swap = true
                    }
                }
                highScores = x
            } while swap == true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            highScores.remove(at: indexPath.row)
            UIView.animate(withDuration: 0.25, animations: {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }) { (completion) in
                tableView.reloadData()
                let userDefaults = UserDefaults.standard
                userDefaults.set(highScores, forKey: "highScores")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        highScoreTable.layer.masksToBounds = true
        highScoreTable.layer.cornerRadius = 20
        highScoreTable.layer.borderWidth = 1
        highScoreLabel.layer.masksToBounds = true
        highScoreLabel.layer.cornerRadius = 20
        highScoreLabel.layer.borderWidth = 1
        toolbar.layer.masksToBounds = true
        toolbar.layer.cornerRadius = toolbar.frame.height/2
        toolbar.layer.borderWidth = 1

    }
    
    @IBAction func returnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

class scoreCell: UITableViewCell {
    @IBOutlet var numPlace: UILabel!
    @IBOutlet var playerName: UILabel!
    @IBOutlet var timeTaken: UILabel!
    
}

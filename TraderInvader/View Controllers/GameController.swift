//
//  GameController.swift
//  TraderInvader
//
//  Created by Pranav Ramesh on 3/15/19.
//  Copyright © 2019 Pranav Ramesh. All rights reserved.
//

import UIKit

class GameController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        traderShipStatus.text = "Click New Game to start a new game"
        traderIsMoving = false
        
        weaponStack.isHidden = true
        coinStack.isHidden = true
        coinsLabel.text = String(describing: coins)
        
        downButton.isEnabled = false
        rightButton.isEnabled = false
        
        motionStack.isHidden = true
        moveShipLabel.isHidden = true
        
        targetGraph.isHidden = true
        errorNotification.text = ""
        traderLife.isHidden = true
        traderLifeLabel.isHidden = true
        traderLife.transform = traderLife.transform.scaledBy(x: 1, y: 2)
        traderLife.layer.masksToBounds = true
        traderLife.layer.cornerRadius = 3
        
        traderShip.alpha = 1
        
        newGameButton.isHidden = false
        newGameButton.layer.masksToBounds = true
        newGameButton.layer.cornerRadius = 10
        

        NotificationCenter.default.addObserver(self, selector: #selector(startGame), name: NSNotification.Name("startGame"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endGame), name: NSNotification.Name("endGame"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(returnToHome), name: NSNotification.Name("returnHome"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func startGame() {
        gameShipTop.constant = 0
        gameShipLeading.constant = 0
        
        checkCoins()
        setTimer(isRunning: true, movingTimer: 1, stationaryTimer: 4)
        
        weaponStack.isHidden = false
        coinStack.isHidden = false
        motionStack.isHidden = false
        moveShipLabel.isHidden = false
        errorNotification.text = ""
        counter = 0
        coins = 0
        coinsLabel.text = "0"
        traderHitCount = 100
        traderLife.isHidden = false
        traderLife.setProgress(1, animated: true)
        traderLife.progressTintColor = UIColor(red: 20/255, green: 126/255, blue: 251/255, alpha: 1)
        traderLifeLabel.isHidden = false
        traderLifeLabel.text = "Trader Life: \(traderHitCount)"
        newGameButton.isHidden = true
        scoreTick = 0
        cumulativeScore = 0
        
        UIView.animate(withDuration: 0.5) {
            self.traderShip.alpha = 0.01
        }
        
        scoreTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
            self.scoreTick += 1
        })
    }
    
    @objc func endGame() {
        setTimer(isRunning: false, movingTimer: 1, stationaryTimer: 3)
        weaponStack.isHidden = true
        coinStack.isHidden = true
        motionStack.isHidden = true
        moveShipLabel.isHidden = true
        targetGraph.isHidden = true
        traderShipStatus.text = "Click New Game to start a new game"
        pirateShipTop.constant = 336
        pirateShipLeading.constant = 336
        gameShipTop.constant = 0
        gameShipLeading.constant = 0
        traderLife.isHidden = true
        traderLifeLabel.isHidden = true
        newGameButton.isHidden = false
        traderShip.alpha = 1
        scoreTimer.invalidate()
        
        self.view.layoutIfNeeded()
    }
    
    @objc func returnToHome() {
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideBar"), object: nil)
        performSegue(withIdentifier: "returnHome", sender: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endGame()
    }
    
    enum directionType: Int {
        case top = 0,
        leading
    }
    enum weaponType: Int {
        case torpedo = 0,
        missile,
        sonar
    }
    enum myShipDirection: Int {
        case up = 0,
        down,
        right,
        left
    }
    
    @IBOutlet var motionStack: UIStackView!
    @IBOutlet var moveShipLabel: UILabel!
    
    @IBOutlet var gameShipTop: NSLayoutConstraint!
    @IBOutlet var gameShipLeading: NSLayoutConstraint!
    @IBOutlet var pirateShipLeading: NSLayoutConstraint!
    @IBOutlet var pirateShipTop: NSLayoutConstraint!
    
    @IBOutlet var gameMap: UIImageView!
    @IBOutlet var traderShip: UIImageView!
    @IBOutlet var traderShipStatus: UILabel!
    @IBOutlet var pirateShip: UIImageView!
    
    @IBOutlet var coinStack: UIStackView!
    @IBOutlet var weaponStack: UIStackView!
    @IBOutlet var coinsLabel: UILabel!
    
    @IBOutlet var torpedoButton: UIButton!
    @IBOutlet var missileButton: UIButton!
    @IBOutlet var sonarButton: UIButton!
    
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var upButton: UIButton!
    @IBOutlet var downButton: UIButton!
    
    @IBOutlet var targetGraph: UICollectionView!
    @IBOutlet var errorNotification: UILabel!
    var selectedWeapon: weaponType? = nil
    @IBOutlet var traderLife: UIProgressView!
    @IBOutlet var traderLifeLabel: UILabel!
    @IBOutlet var newGameButton: UIButton!
    
    var timer = Timer()
    var counter = 0
    var coins: Int = 0
    var traderHitCount = 100
    var scoreTimer = Timer()
    var scoreTick = 0
    var cumulativeScore = 0
    
    @IBAction func newGamePressed(_ sender: UIButton) {
        startGame()
    }
    
    var traderIsMoving = Bool()
    
    func setTimer(isRunning: Bool, movingTimer: Int, stationaryTimer: Int) {
        switch isRunning {
        case true:
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
                self.traderLifeLabel.text = "Trader Life: \(self.traderHitCount)"
                self.counter += 1
                
                self.coins += 1
                self.coinsLabel.text = String(describing: self.coins)
                
                self.checkCoins()
                
                switch self.traderIsMoving {
                case true:
                    self.traderShipStatus.text = "The trader ship is moving..."
                    if self.counter == movingTimer {
                        self.counter = 0
                        self.traderIsMoving = !self.traderIsMoving
                        
                        if self.gameShipTop.constant == 336 && self.gameShipLeading.constant == 336 {
                            
                            var messageDuration = 0.0
                            _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (Timer) in
                                messageDuration += 0.5
                                self.traderShipStatus.text = "You lose! Click New Game to start a new game"
                                self.traderShip.alpha = 1
                                if messageDuration > 1.5 {
                                    Timer.invalidate()
                                }
                            })
                            
                            self.endGame()
                            
                        } else {
                            let random = Int.random(in: 0...1)
                            if random == 0 { // Move right
                                if self.gameShipLeading.constant < 336 { // If ship on right edge
                                    self.moveTrader(inDirection: .leading)
                                } else {
                                    self.moveTrader(inDirection: .top)
                                }
                            } else { // Move left
                                if self.gameShipTop.constant < 336 { // If ship on bottom edge
                                    self.moveTrader(inDirection: .top)
                                } else {
                                    self.moveTrader(inDirection: .leading)
                                }
                            }
                            
                            
                        }
                    }
                case false:
                    self.traderShipStatus.text = "The trader ship is stationary."
                    if self.counter == stationaryTimer {
                        self.counter = 0
                        self.traderIsMoving = !self.traderIsMoving
                    }
                }
            })
        case false:
            timer.invalidate()
            traderIsMoving = false
        }
        
    }
    
    
    func moveTrader(inDirection direction: directionType) {
        
        switch direction {
        case .top:
            gameShipTop.constant += 24
        case .leading:
            gameShipLeading.constant += 24
        }
        
        print("Trader Position: X: \(gameShipTop.constant), Y: \(gameShipLeading.constant)")
        
        UIView.animate(withDuration: 1, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func checkCoins() {
        if coins < 3 {
            torpedoButton.isEnabled = false
        } else {
            torpedoButton.isEnabled = true
        }
        
        if coins < 5 {
            missileButton.isEnabled = false
        } else {
            missileButton.isEnabled = true
        }
        
        if coins < 6 {
            sonarButton.isEnabled = false
        } else {
            sonarButton.isEnabled = true
        }
    }
    
    func useWeapon(ofType weaponType: weaponType) {
        switch weaponType {
        case .torpedo:
            targetGraph.isHidden = false
            coins -= 3
            selectedWeapon = .torpedo
        case .missile:
            targetGraph.isHidden = false
            coins -= 5
            selectedWeapon = .missile
        case .sonar:
            coins -= 6
            
            UIView.animate(withDuration: 0.5, animations: {
                self.traderShip.alpha = 1
                self.view.layoutIfNeeded()
            }) { (completion) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.traderShip.alpha = 0.01
                    self.view.layoutIfNeeded()
                })
            }
            
            let pirateX = pirateShipLeading.constant
            let pirateY = pirateShipTop.constant
            let traderX = gameShipLeading.constant
            let traderY = gameShipTop.constant
            var traderPos = "" // Sector #
            var piratePos = "" // Sector #
            var message = ""
            
            // The following determines the sector in which the pirate (player) resides
            switch pirateX {
            case 0...111:
                switch pirateY {
                case 0...111: piratePos = "Sector 1"
                case 112...223: piratePos = "Sector 4"
                case 224...336: piratePos = "Sector 7"
                default: break
                }
            case 112...223:
                switch pirateY {
                case 0...111: piratePos = "Sector 2"
                case 112...223: piratePos = "Sector 5"
                case 224...336: piratePos = "Sector 8"
                default: break
                }
            case 224...336:
                switch pirateY {
                case 0...111: piratePos = "Sector 3"
                case 112...223: piratePos = "Sector 6"
                case 224...336: piratePos = "Sector 9"
                default: break
                }
            default: break
            }
            
            // The following determines the sector in which the trader (computer opponent) resides
            switch traderX {
            case 0...111:
                switch traderY {
                case 0...111: traderPos = "Sector 1"
                case 112...223: traderPos = "Sector 4"
                case 224...336: traderPos = "Sector 7"
                default: break
                }
            case 112...223:
                switch traderY {
                case 0...111: traderPos = "Sector 2"
                case 112...223: traderPos = "Sector 5"
                case 224...336: traderPos = "Sector 8"
                default: break
                }
            case 224...336:
                switch traderY {
                case 0...111: traderPos = "Sector 3"
                case 112...223: traderPos = "Sector 6"
                case 224...336: traderPos = "Sector 9"
                default: break
                }
            default: break
            }
            
            // Checks to see if the pirate's sector matches the trader's sector
            if piratePos == traderPos {
                message = "Trader ship is in your sector - \(piratePos)."
            } else {
                message = "Trader ship is not in your sector."
            }
            
            giveErrorNotification(withError: message)
        }
        coinsLabel.text = String(describing: coins)
        checkCoins()
    }
    
    @IBAction func useTorpedo(_ sender: UIButton) {
        useWeapon(ofType: .torpedo)
    }
    
    @IBAction func useMissile(_ sender: UIButton) {
        useWeapon(ofType: .missile)
    }
    
    @IBAction func useSonar(_ sender: UIButton) {
        useWeapon(ofType: .sonar)
    }
    
    func moveMyShip(direction: myShipDirection) {
        switch direction {
        case .up:
            if pirateShipTop.constant > 0 {
                pirateShipTop.constant -= 24
            }
        case .down:
            if pirateShipTop.constant < 336 {
                pirateShipTop.constant += 24
            }
        case .right:
            if pirateShipLeading.constant < 336 {
                pirateShipLeading.constant += 24
            }
        case .left:
            if pirateShipLeading.constant > 0 {
                pirateShipLeading.constant -= 24
            }
        }
        
        if self.pirateShipTop.constant == 0 {
            self.upButton.isEnabled = false
        } else {
            self.upButton.isEnabled = true
        }
        if self.pirateShipTop.constant == 336 {
            self.downButton.isEnabled = false
        } else {
            self.downButton.isEnabled = true
        }
        if self.pirateShipLeading.constant == 0 {
            self.leftButton.isEnabled = false
        } else {
            self.leftButton.isEnabled = true
        }
        if self.pirateShipLeading.constant == 336 {
            self.rightButton.isEnabled = false
        } else {
            self.rightButton.isEnabled = true
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
        
        
    }
    
    @IBAction func moveLeft(_ sender: UIButton) {
        moveMyShip(direction: .left)
    }
    @IBAction func moveRight(_ sender: UIButton) {
        moveMyShip(direction: .right)
    }
    @IBAction func moveUp(_ sender: UIButton) {
        moveMyShip(direction: .up)
    }
    @IBAction func moveDown(_ sender: UIButton) {
        moveMyShip(direction: .down)
    }
    
    @IBAction func toggleSideBar(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideBar"), object: nil)
    }
}

extension GameController: UICollectionViewDelegate, UICollectionViewDataSource { // provides protocols for the target grid to fire weapons
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "targetGraphCell", for: indexPath) as! targetGraphCollectionView
        if indexPath.row == 12 {
            cell.imageView.image = UIImage(named: "pirate.png")
        }
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.green.cgColor
        return cell
    }
    
    func giveErrorNotification(withError message: String) {
        errorNotification.isHidden = false
        errorNotification.text = message
        print(message)
        var tick = 0
        
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            tick += 1
            if tick == 2 {
                Timer.invalidate()
                self.errorNotification.text = ""
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Determines the x-position at which the player wishes to fire on the map, relative to the target grid
        let xpos = { (pirateX: Int) -> Int in
            var xdir = 0
            switch indexPath.row % 5 {
            case 0: xdir = -48
            case 1: xdir = -24
            case 2: xdir = 0
            case 3: xdir = 24
            case 4: xdir = 48
            default: break
            }
            return pirateX + xdir
        }
        // Determines the y-position at which the player wishes to fire on the map, relative to the target grid
        let ypos = { (pirateY: Int) -> Int in
            var ydir = 0
            switch indexPath.row {
            case 0...4: ydir = -48
            case 5...9: ydir = -24
            case 10...14: ydir = 0
            case 15...19: ydir = 24
            case 20...24: ydir = 48
            default: break
            }
            return pirateY + ydir
        }
        let startX = Int(pirateShipLeading.constant)
        let startY = Int(pirateShipTop.constant)
        let endX = xpos(Int(pirateShipLeading!.constant))
        let endY = ypos(Int(pirateShipTop!.constant))
        
        if endX <= 336 && endY <= 336 && endX >= 0 && endY >= 0 {
            print("Preparing to fire at:", endX, endY)
            
            if let type = selectedWeapon {
                switch type {
                case .torpedo, .missile:
                    // Initiating weapon launch
                    var weaponImage = UIImage()
                    
                    if type == .torpedo {
                        weaponImage = UIImage(named: "torpedo.png")!
                    } else if type == .missile {
                        weaponImage = UIImage(named: "missile.png")!
                    }
                    
                    let animatedWeapon = UIImageView(image: weaponImage)
                    animatedWeapon.frame = CGRect(x: startX, y: startY, width: 24, height: 24)
                    animatedWeapon.tag = 432
                    
                    // Showing the starting position of the weapon
                    gameMap.addSubview(animatedWeapon)
                    
                    // Animates the weapon traveling towards the selected position.
                    UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
                        animatedWeapon.frame = CGRect(x: endX, y: endY, width: 24, height: 24)
                        self.view.layoutIfNeeded()
                        self.gameMap.layoutIfNeeded()
                    }) { (completion) in
                        if let taggedTorpedo = self.view.viewWithTag(432) {
                            taggedTorpedo.removeFromSuperview()
                            
                            let explosion = UIImageView(image: UIImage(named: "explosion.png"))
                            explosion.frame = CGRect(x: endX, y: endY, width: 12, height: 12)
                            explosion.tag = 202
                            self.gameMap.addSubview(explosion)
                            
                            UIView.animate(withDuration: 0.5, animations: {
                                explosion.frame = CGRect(x: endX, y: endY, width: 30, height: 30)
                            }, completion: { (completion) in
                                UIView.animate(withDuration: 0.5, animations: {
                                    explosion.frame = CGRect(x: endX, y: endY, width: 12, height: 12)
                                }, completion: { (subCompletion) in
                                    if let taggedExplosion = self.view.viewWithTag(202) {
                                        taggedExplosion.removeFromSuperview()
                                    }
                                })
                            })
                            
                            
                            if endX == Int(self.gameShipLeading.constant) && endY == Int(self.gameShipTop.constant) { // If the weapon collided with the trader
                                if type == .torpedo {
                                    self.traderHitCount -= 15
                                    self.cumulativeScore += 3
                                } else if type == .missile {
                                    self.traderHitCount -= 30
                                    self.cumulativeScore += 5
                                }
                                print("Score: \(self.cumulativeScore)")
                                
                                self.giveErrorNotification(withError: "You hit the ship!")
                                
                                if self.traderHitCount <= 0 { // If the trader's health is at 0 (or below)
                                    self.endGame()
                                    self.giveErrorNotification(withError: "You sunk the trader! You win!")
                                    
                                    // Gives notification to add player to leaderboard
                                    let winAlert = UIAlertController(title: "New High Score of \(self.cumulativeScore)!", message: "Enter your player name", preferredStyle: .alert)
                                    winAlert.addTextField(configurationHandler: { (textfield) in
                                        textfield.placeholder = "Enter name"
                                    })
                                    
                                    winAlert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
                                        let totalTime = Double(round(Double(10*self.scoreTick/60))/10)
                                        highScores.append([winAlert.textFields![0].text ?? "Unnamed", totalTime, self.cumulativeScore])
                                        let userDefaults = UserDefaults.standard
                                        userDefaults.set(highScores, forKey: "highScores")
                                    }))
                                    self.present(winAlert, animated: true, completion: nil)
                                }
                            } else { // If the weapon did not collide with the trader
                                self.giveErrorNotification(withError: "You missed!")
                            }
                            self.traderLife.setProgress(Float(self.traderHitCount)/100, animated: true)
                            
                            switch self.traderHitCount {
                            case 76...100: self.traderLife.progressTintColor = UIColor(red: 20/255, green: 126/255, blue: 251/255, alpha: 1)
                            case 51...75: self.traderLife.progressTintColor = UIColor.green
                            case 26...50: self.traderLife.progressTintColor = UIColor(red: 254/255, green: 203/255, blue: 46/255, alpha: 1)
                            case 0...25: self.traderLife.progressTintColor = UIColor(red: 252/255, green: 61/255, blue: 57/255, alpha: 1)
                            default: self.traderLife.progressTintColor = UIColor(red: 20/255, green: 126/255, blue: 251/255, alpha: 1)
                            }
                            self.traderLife.trackTintColor = UIColor.lightGray
                            
                        }
                        self.selectedWeapon = nil // Clearing the selected weapon
                        
                    }
                default: print("Didn't successfully launch a valid weapon")
                }
            } else {
                print("Didn't successfully launch a valid weapon")
            }
        } else { // The player fired on a coordinate which doesn't exist
            let message = "Coordinate doesn't exist"
            giveErrorNotification(withError: message)
            print(message)
        }
        
        collectionView.isHidden = true
    }
    
}

class targetGraphCollectionView: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
}

class sideBar: UITableViewController { // The drawer/side bar that can be used to start a new game, end the game, or return to the main menu.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            NotificationCenter.default.post(name: NSNotification.Name("toggleSideBar"), object: nil)
        case 1:
            NotificationCenter.default.post(name: NSNotification.Name("startGame"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("toggleSideBar"), object: nil)
        case 2:
            NotificationCenter.default.post(name: NSNotification.Name("endGame"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("toggleSideBar"), object: nil)
        case 3:
            NotificationCenter.default.post(name: NSNotification.Name("returnHome"), object: nil)
        default: break
        }
    }
}

class GameContainer: UIViewController { // The container view that holds the game view
    @IBOutlet var sideBar: UIView!
    @IBOutlet var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleSideBar), name: NSNotification.Name("toggleSideBar"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBOutlet var sideBarConstraint: NSLayoutConstraint!
    
    var sideMenuVisible = false
    
    
    @objc func toggleSideBar() {
        if sideMenuVisible {
            sideBarConstraint.constant = -240
            sideMenuVisible = false
            mainView.isUserInteractionEnabled = true
        } else {
            sideBarConstraint.constant = 0
            sideMenuVisible = true
            mainView.isUserInteractionEnabled = false
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            if self.sideMenuVisible {
                self.mainView.alpha = 0.5
            } else {
                self.mainView.alpha = 1
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
}


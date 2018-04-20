//
//  ViewController.swift
//  Coinmarketcap
//
//  Created by Nikodem Strawa on 14/04/2018.
//  Copyright © 2018 Nikodem Strawa. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var coinImage = [String: String]()
    var coins = [Coin]()
    var filtredCoins = [Coin]()
    
    let baseImageUrl = "https://s2.coinmarketcap.com/static/img/coins/64x64/"
    let sparklinesUrl = "https://s2.coinmarketcap.com/generated/sparklines/web/7d/usd/"
    let globalUrl = "https://api.coinmarketcap.com/v1/global/"
    
    

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var coinTableView: UITableView!
    @IBOutlet weak var marketCap: UILabel!
    @IBOutlet weak var btcDominance: UILabel!
    var refreshController = UIRefreshControl()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtredCoins.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filterCoins(serchText: searchText)
        coinTableView.reloadData()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell", for: indexPath) as! coinTableViewCell
        let coin = filtredCoins[indexPath.row]
        let cellId = coin.id
        cell.coinName?.text = coin.name
        cell.coinRank?.text = coin.rank
        cell.coinPrice?.text = coin.price
        
        if let doublePercent = coin.percentChange24Double {
            if doublePercent < 0 {
                cell.coinChange.textColor = UIColor.red
                cell.coinChange?.text = coin.percentChange24h! + "% ▼"
            } else {
                cell.coinChange.textColor =  UIColor.green
                cell.coinChange?.text = coin.percentChange24h! + "% ▲"
            }
        }
        
        if let imgId = coinImage[cellId] {
            let imgUrl = String(baseImageUrl + imgId).trimmingCharacters(in: .whitespaces)
            let sparklineUrl = String(sparklinesUrl + imgId).trimmingCharacters(in: .whitespaces)
            if let urlImg = URL(string: imgUrl), let sparkUrl = URL(string: sparklineUrl) {

                    cell.coinImage?.downloadedFrom(url: urlImg, contentMode: .scaleAspectFill)
                    cell.sparklines?.downloadedFrom(url: sparkUrl)
                    cell.sparklines?.layer.borderWidth = 1
                    cell.sparklines?.layer.borderColor = UIColor.lightGray.cgColor
                
                }
            }
        
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //let fs = FileManager.default
        searchBar.isHidden = true;
        readImagesFile()
        loadCoins()
        loadGlobal()
        initRefreschController()
        //coins.forEach {print($0)}
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func readImagesFile() {
        guard let url = Bundle.main.url(forResource: "images", withExtension: "txt") else {
            print("There is no such file")
            return
        }
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let contentArray = content.components(separatedBy: .newlines)
            
            for line in contentArray {
                if(line != "") {
                    //line example: bitcoin;1.png
                    let splitLine = line.components(separatedBy: ";")
                    coinImage[splitLine[0]] = splitLine[1]
                }
            }
        }
        catch {
            print(error)
            return
        }
    }
    
    func loadCoins() {
        guard let url = URL(string: "https://api.coinmarketcap.com/v1/ticker/?limit=0") else {
            print("wrong url")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Error ", err)
                    return
                }
                
                guard let data = data else {
                    print("bad data")
                    return
                }
                
               
                do {
                    let decoder = JSONDecoder()
                    self.coins = try decoder.decode([Coin].self, from: data)
                    self.filterCoins(serchText: self.searchBar.text)
                    self.coinTableView.reloadData()
                } catch let jsonError {
                    print("Failed to decode ", jsonError)
                }
            }
        }.resume()
    }
    
    func loadGlobal() {
        guard let url = URL(string: globalUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print(err)
                    return
                }
                
                guard let data = data else {
                    print("wrong data")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let global = try decoder.decode(Global.self, from: data)
                    self.marketCap?.text = global.marketCapUsd
                    self.btcDominance?.text = global.btcDominance
                } catch let jsonError {
                    print(jsonError)
                }
                
                
            }
        }.resume()
    }
    
    func initRefreschController() {
        
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshController.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        coinTableView.addSubview(refreshController)
    }
    
    @objc
    func refresh() {
        print("refreshing")
        loadCoins()
        loadGlobal()
        refreshController.endRefreshing()
        coinTableView.reloadData()
    }
    
    func filterCoins(serchText: String?) {
        guard let search = serchText else {
            self.filtredCoins = self.coins
            return
        }
        
        if(search.isEmpty)  {
            self.filtredCoins = self.coins
        } else {
            self.filtredCoins = self.coins.filter({coin -> Bool in
                return coin.name.lowercased().contains(search.lowercased()) ? true : coin.symbol.lowercased() == search.lowercased()
            })
        }
    }
    
    @IBAction func triggerSearchBar(_ sender: Any) {
        
        
        if(searchBar.isHidden) {
            UIView.animate(withDuration: 0.5, delay: 0, options: .showHideTransitionViews, animations: {
                self.searchBar.isHidden = false;
            }) { (complete) in
                self.searchButton.setTitle("✖︎", for: .normal)
            }
            
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .showHideTransitionViews, animations: {
                self.searchBar.isHidden = true;
            }) { (complete) in
                self.searchButton.setTitle("🔎", for: .normal)
            }

        }
        
        
    }
}



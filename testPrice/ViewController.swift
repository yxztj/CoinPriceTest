//
//  ViewController.swift
//  testPrice
//
//  Created by Jason Yu on 11/29/17.
//  Copyright © 2017 Jike. All rights reserved.
//

import UIKit

enum Currency: String {
    case bitshares
    case bitcoin
    case litecoin
    case eos
    case ethereum
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var observer: Any?
    var currencies: [Currency] = [.bitcoin, .bitshares, .litecoin, .eos, .ethereum]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.observer = NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillEnterForeground, object: nil, queue: nil) { (_) in
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let priceCell = tableView.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as? PriceCell else {
            return UITableViewCell()
        }
        
        let c = self.currencies[indexPath.row]
        priceCell.nameLabel.text = c.rawValue
        
        self.getPrice(for: c) { price in
            DispatchQueue.main.async {
                let doublePrice = Double(price) ?? 0
                let rounded = Double(Int(doublePrice * 100)) / 100
                priceCell.priceLabel.text = "\(rounded)"
            }
            
        }
        return priceCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currencies.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func getPrice(for currency: Currency, completion: @escaping (String) -> Void) {
        let priceCur = "CNY"
        let url = URL(string: "https://api.coinmarketcap.com/v1/ticker/\(currency.rawValue)/?convert=\(priceCur)")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                if let arr = json as? [Any], let dict = arr[0] as? [String: Any],
                    let price = dict["price_\(priceCur.lowercased())"] as? String {
                    completion(price)
                }
                //                print(json)
            }
            //            print(data)
            }.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class PriceCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}

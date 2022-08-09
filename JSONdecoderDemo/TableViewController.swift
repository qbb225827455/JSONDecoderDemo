//
//  TableViewController.swift
//  JSONdecoderDemo
//
//  Created by 陳鈺翔 on 2022/8/9.
//

import UIKit

class TableViewController: UITableViewController {
    
    enum Section {
        case all
    }
    
    lazy var dataSource = configureDataSource()
    
    private let kivaLoanURL = "https://api.kivaws.org/v1/loans/newest.json"
    private var loans = [Loan]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(getLoans), for: UIControl.Event.valueChanged)
        
        getLoans()
    }
    
    @objc func getLoans() {
        
        guard let loanURL = URL(string: kivaLoanURL) else {
            return
        }
        
        let request = URLRequest(url: loanURL)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            if let error = error {
                print(error)
                return
            }
            
            if let data = data {
                self.loans = self.parseJSONData(data: data)
                
                OperationQueue.main.addOperation({
                    self.updateSnapshot()
                    if let refreshControl = self.refreshControl {
                        if refreshControl.isRefreshing {
                            refreshControl.endRefreshing()
                        }
                    }
                })
            }
        })
        
        task.resume()
    }
    
    func parseJSONData(data: Data) -> [Loan] {
        
        var loans = [Loan]()
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
            let jsonLoans = jsonResult?["loans"] as! [AnyObject]
            for jsonLoan in jsonLoans {
                
                var loan = Loan()
                
                loan.name = jsonLoan["name"] as! String
                loan.use = jsonLoan["use"] as! String
                loan.amount = jsonLoan["loan_amount"] as! Int
                
                let location = jsonLoan["location"] as! [String:AnyObject]
                loan.country = location["country"] as! String
                
                loans.append(loan)
            }
            
        } catch {
            print(error)
        }
        
        return loans
    }
    
    func configureDataSource() -> UITableViewDiffableDataSource<Section, Loan> {
        
        let cellID = "datacell"
        
        let dataSource = UITableViewDiffableDataSource<Section, Loan>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, loan in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TableViewCell
                
                cell.nameLabel.text = loan.name
                cell.countryLabel.text = loan.country
                cell.useLabel.text = loan.use
                cell.amountLabel.text = "$\(loan.amount)"
                
                return cell
        })
        
        return dataSource
    }
    
    func updateSnapshot() {
        
        var snapShot = NSDiffableDataSourceSnapshot<Section, Loan>()
        snapShot.appendSections([.all])
        snapShot.appendItems(loans, toSection: .all)
        
        dataSource.apply(snapShot, animatingDifferences: false, completion: nil)
    }
}

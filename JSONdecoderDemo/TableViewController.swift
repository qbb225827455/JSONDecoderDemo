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
    
    private let apiURL = "https://api.kivaws.org/v1/loans/newest.json"
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
        
        guard let URL = URL(string: apiURL) else {
            return
        }
        
        let request = URLRequest(url: URL)
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
        
        let decoder = JSONDecoder()
        
        do {
            let loanDataStore = try decoder.decode(LoanDataStore.self, from: data)
            loans = loanDataStore.loans
            
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
                cell.countryLabel.text = loan.location.country
                cell.useLabel.text = loan.use
                cell.amountLabel.text = "$\(loan.amount)"
                print("pairs:\(loan.location.geo.pairs) & level:\(loan.location.geo.level)")
                
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

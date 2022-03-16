//
//  ViewController.swift
//  AsyncAwait
//
//  Created by Aaryaman Saini on 14/03/22.
//

import UIKit

//MARK: - struct

struct User: Codable{
    let name: String
}

//MARK: - class

class ViewController: UIViewController, UITableViewDataSource {
    
    //MARK: - variables
    
    let url = URL(string: "https://jsonplaceholder.typicode.com/users")
    
    private var users = [User]()
    
    //MARK: - views
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    //MARK: - functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        
        async{
            let result = await fetchUser()
            switch result {
            case .success(let users):
                self.users = users
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    enum MyError: Error {
        case failedToGetUsers
    }
    
    private func fetchUser () async -> Result<[User], Error>{
        
        guard let url = url else{
            return .failure(MyError.failedToGetUsers)
        }
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            let users = try JSONDecoder().decode([User].self, from: data)
            return .success(users)
        } catch {
            return .failure(error)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }


}


//
//  FollowerListVC.swift
//  GitFollowers
//
//  Created by Daniel Priestley on 24/02/2023.
//

import UIKit

protocol FollowerListVCDelegate: AnyObject {
    func didRequestFollowers(for username: String)
}

class FollowerListVC: UIViewController {
    
    enum Section {
        case main
    }
    
    var username: String!
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    var followers: [Follower] = []
    var filteredFollowers: [Follower] = []
    var page = 1
    var hasMoreFollowers = true
    var isSearching = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureCollectionView()
        getFollowers(username: username, page: page)
        configureDataSource()
        configureSearchController()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: Configuration Functions
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnLayoutFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a username"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: {(collectionView, indexPath, follower) -> UICollectionViewCell? in
            // We create our cell, and then we cast it as a FollowerCell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            // We utilise the .set function we defined in FollowerCell to expect a follower, we can add additional config to this function, such as styling
            // and that way, we only need 1 line of code at the callsite here.
            cell.set(follower: follower)
            return cell
        })
    }
    
    // MARK: getFollowers Logic
    func getFollowers(username: String, page: Int) {
        showLoadingView()
        // The [weak self] here declares that any use of self inside the network manager must be weak
        NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
            
            guard let self = self else {return} // to avoid repeating optionals we can use guard on self here
            
            self.dismissLoadingView()
            
            switch result {
                // If it was successful, do everything in the success case
            case .success(let followers):
                if followers.count < 100 {self.hasMoreFollowers = false}
                // everytime we running this, we are appending up to 100 more followers
                self.followers.append(contentsOf: followers)
                if self.followers.isEmpty {
                    let message = "This user doesn't have any followers. Go follow them! 👀"
                    
                    DispatchQueue.main.async {
                        self.showEmptyStateView(with: message, in: self.view)
                    }
                    
                    return // if the user has no followers, we don't want to run updateData() again
                }
                
                self.updateData(on: followers)
                
                // If it failed, show the error in the alert
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Bad stuff happened", message: error.rawValue, buttonTitle: "Okay")
            }
        }
    }
    
    // We are going to call this function whenever we want the data to reload
    func updateData(on followers: [Follower]) {
        // We have to pass in the section, and the items, and these then get hashed, which is how they are tracked
        // it then takes a snapshot of the data, and then a snapshot of the new data, and merges them
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    @objc func addButtonTapped() {
        print("Add Button Tapped")
    }
}

extension FollowerListVC: UICollectionViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // This is waiting for us to end dragging, THEN it acts.
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        // If the offset is greater than the total height of the scroll view, minus the height of the view that the user can see
        if offsetY > contentHeight - height {
            guard hasMoreFollowers else { return }
            page += 1
            getFollowers(username: username, page: page)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? filteredFollowers : followers
        let follower = activeArray[indexPath.item]
        
        let destVC = UserInfoVC()
        destVC.username = follower.login
        destVC.delegate = self
        let navController = UINavigationController(rootViewController: destVC)
        present(navController, animated: true)
    }
}

extension FollowerListVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        // If our filter can equal the text in our search bar, and check that the filter is empty before proceeding
        guard let filter = searchController.searchBar.text, !filter.isEmpty else { return }
        isSearching = true
        // $0 just represents the item that's being filtered currently
        // We are going through our array, filtering based on the filter var declared above, checking the login name, and lowercasing it all
        // if the login name contains the value of filter, then put that value in the filterd fvollowers array
        filteredFollowers = followers.filter { $0.login.lowercased().contains(filter.lowercased())}
        updateData(on: filteredFollowers)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateData(on: followers)
    }
    
    
}

extension FollowerListVC: FollowerListVCDelegate {
    func didRequestFollowers(for username: String) {
        self.username = username
        title = username
        page = 1
        followers.removeAll()
        filteredFollowers.removeAll()
        
        getFollowers(username: username, page: page)
        
        DispatchQueue.main.async {
            self.collectionView.setContentOffset(.zero, animated: true)
            self.collectionView.reloadData()
        }
    }
    
    
}

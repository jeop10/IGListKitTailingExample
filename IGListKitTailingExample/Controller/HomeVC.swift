//
//  HomeVC.swift
//  IGListKitTailingExample
//
//  Created by Jesus Ortega on 10/5/17.
//  Copyright © 2017 Jesus Ortega. All rights reserved.
//

import UIKit
import IGListKit

final class HomeVC: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    lazy var items = [String]()
    var loading = false
    let spinToken = "spinner"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //This is important to avoid transparency xD
        collectionView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        //First time loading data
        loading = true
        adapter.performUpdates(animated: true, completion: nil)
        DispatchQueue.global(qos: .default).async {
            PokeService.instance.callPokeAPI { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.loading = false
                        self.items.append(contentsOf: PokeService.instance.pokemons)
                        self.adapter.performUpdates(animated: true, completion: nil)
                    }
                }
            }
            
        }
        
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        
    }
    
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var objects = items as [ListDiffable]
        
        if loading {
            objects.append(spinToken as ListDiffable)
        }
        
        return objects
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let obj = object as? String, obj == spinToken {
            return spinnerSectionController()
        } else {
            return LabelSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if !loading && distance < 200 {
            loading = true
            adapter.performUpdates(animated: true, completion: nil)
            DispatchQueue.global(qos: .default).async {
                PokeService.instance.callPokeAPI { (success) in
                    if success {
                        DispatchQueue.main.async {
                            self.loading = false
                            self.items.append(contentsOf: PokeService.instance.pokemons)
                            self.adapter.performUpdates(animated: true, completion: nil)
                        }
                    }
                }
                
            }
        }
    }
    
}

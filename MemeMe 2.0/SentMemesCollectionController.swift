//
//  SentMemesCollectionController.swift
//  MemeMe 2.0
//
//  Created by Ahmed yasser on 4/23/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit

// Collection cell resuse Identifier
private let reuseIdentifier = "CollectionCell"

class SentMemesCollectionController: UICollectionViewController {
    
    // MARK: Outlets
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    // MARK: Memes Array
    // Create a meme array and copy the shared array elements to it
    var memes: [MemeModel]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    // Mark: View did load
    // create a right add button and set the title
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem (image: UIImage(named: "add"), style: .plain
            , target: self, action: #selector(addMeme))
        navigationItem.title = "Sent Memes"
        
        // Set Collection Spacing
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    // MARK: View did appear
    // Reloads the collection view data every time the view appears on the screen
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    // MARK: Add Meme
    // Fires when the user clicks on the add sign and launches the meme editor controller modally
    @objc func addMeme(){
        var controller = MemeEditorController()
        controller = storyboard?.instantiateViewController(withIdentifier: "EditorController") as! MemeEditorController
        present(controller,animated: true,completion: nil)
    }

    // MARK: Number of collections sections
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    // Mark: Number of collection items in sections
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return memes.count
    }

    // create and configure a meme collection item for the given index path
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for:indexPath) as! MemeCollectionCell
     CollectionCell.memeCollectionImage.image = memes[indexPath.row].memedImage
     return CollectionCell
    }

    // MARK: Collection item selected
    /* When a user selects a meme , the meme is displayed in the detail view
     */
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailView = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailView.selectedMeme = memes[indexPath.row]
        navigationController!.pushViewController(detailView, animated: true)
    }
}

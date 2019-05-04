//
//  DetailViewController.swift
//  MemeMe 2.0
//
//  Created by Ahmed yasser on 4/24/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var selectedMemeImage: UIImageView!
    
    // The selected Meme passed from the sent memes table controller
    var selectedMeme: MemeModel!

    // MARK: View will appear
    // Sets the detail controller meme image to the selected image
    override func viewWillAppear(_ animated: Bool) {
       selectedMemeImage.image = selectedMeme.memedImage
    }
}

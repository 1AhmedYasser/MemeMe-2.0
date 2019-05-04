//
//  SentMemesTableController.swift
//  MemeMe 2.0
//
//  Created by Ahmed yasser on 4/23/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit

class SentMemesTableController: UITableViewController {
    
    // MARK: Memes Array
    // Create a meme array and copy the shared array elements to it
    var memes: [MemeModel]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    // Mark: View did load
    // create a right add button and a left edit button and set the title
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem (image: UIImage(named: "add"), style: .plain
            , target: self, action: #selector(addMeme))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editMeme))
        navigationItem.title = "Sent Memes"
    }
    
    // MARK: Add Meme
    // Fires when the user clicks on the add sign and launches the meme editor controller modally
    @objc func addMeme(){
        var controller = MemeEditorController()
        controller = storyboard?.instantiateViewController(withIdentifier: "EditorController") as! MemeEditorController
        present(controller,animated: true,completion: nil)
    }
    
    // MARK: View did appear
    // Reloads the table view data every time the view appears on the screen
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: Edit Meme
    // Enable / Disable editing mode on the table view
    @objc func editMeme(){
        if(self.tableView.isEditing == true)
        {
            changeTableEditingState(state: false, title: "Done")
        }
        else
        {
            changeTableEditingState(state: true, title: "Edit")
        }
    }
    
    // helper method: changes the table view editing state and the right bar button title
    func changeTableEditingState(state: Bool,title: String){
        self.tableView.isEditing = state
        self.navigationItem.rightBarButtonItem?.title = title
    }
    
    // MARK: Number of table sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Mark: Number of table rows in sections
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    // create and configure a meme table cell for the given index path
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let memeCell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            as! MemeTableCell
        memeCell.memeTableImage.image = memes[indexPath.row].memedImage
        memeCell.memeTableText.text = "\(memes[indexPath.row].topText) ... \(memes[indexPath.row].bottomText)"
        return memeCell
    }
    
    // The method permits the data source to exclude individual rows from being treated as editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // This method sets events when a user deletes a table row
    /* when a table row is deleted , the meme is deleted from the shared meme array and
     the table data is reloaded
     */
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            (UIApplication.shared.delegate as! AppDelegate).memes.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    // MARK: Table row selected
    /* When a user selects a meme , this method checks if the table editing mode is on , if it is open the
     meme editor controller and allows the user to edit the meme , if not open the meme in the detail view
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true {
            var controller = MemeEditorController()
            controller = storyboard?.instantiateViewController(withIdentifier: "EditorController") as! MemeEditorController
            controller.memeToEdit = memes[indexPath.row]
            controller.memeToEditIndex = indexPath.row
            present(controller,animated: true,completion: nil)
        } else {
            let detailView = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            detailView.selectedMeme = memes[indexPath.row]
            navigationController!.pushViewController(detailView, animated: true)
        }
    }
}

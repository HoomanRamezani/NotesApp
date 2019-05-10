//
//  noteTableViewController.swift
//  Notes
//
//  Created by Hooman Ramezani on 2019-04-26.
//  Copyright © 2019 Hooman Ramezani. All rights reserved.
//

import UIKit
import CoreData

class noteTableViewController: UITableViewController {

    var notes = [Note]() // array of Note, Note is our data model
    
    var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveNotes()
        
        // Styles
        self.tableView.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        // Called whenever tableview will appear on the screen
        super.viewWillAppear(true)
        
        retrieveNotes() // function will retrieve notes our notes from data model
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
        // e.g number of notes in the note array is the rows
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Builds each cell of table view
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteTableViewCell", for: indexPath) as! noteTableViewCell

        // code that puts information into the cell
        let note: Note = notes[indexPath.row] // current note is the note from current index
        cell.configureCell(note: note)
        cell.backgroundColor = UIColor.clear
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return true meanings all rows are editable no matter indexpath
        return true
        
    }

    // Asks the data source to commit the insertion or deletion of a specified row in the receiver.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // delete functionality for a cell
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    
        // make sure table view is updated after edits
        tableView.reloadData()
        
    }
    
    // Asks the delegate for the actions to display in response to a swipe in the specified row.
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "                    ") { (action, indexPath) in
            
            let note = self.notes[indexPath.row] // select current note
            context.delete(note) // delete object from CoreData
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext() // commit deletion
            
            do {
                // update notes attribute in tableviewcontroller
                self.notes = try context.fetch(Note.fetchRequest())
            }
            catch {
                print("Failed to delete note.")
            }
            
            // delete from users screen
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
        
        delete.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "trashIcon"))
        
        return [delete]
    }
    
    // MARK: NSCoding
    func retrieveNotes() {
        managedObjectContext?.perform {
            // here is where we are fetching notes from core data
            
            self.fetchNotesFromCoreData { (notes) in
                if let notes = notes {
                    self.notes = notes
                    self.tableView.reloadData()
                    // want to reload our data everytime data is updated/lists changed
                }
            }
        }
    }
    
    func fetchNotesFromCoreData(completion: @escaping ([Note]?)->Void){
        managedObjectContext?.perform {
            var notes = [Note]() // array of note
            let request: NSFetchRequest<Note> = Note.fetchRequest()
            
            do {
                notes = try self.managedObjectContext!.fetch(request)
                completion(notes) // notes escapes scope of function to be used in retrieve notes
            }
            catch {
                print("Could not fetch notes from CoreData:\(error.localizedDescription)")
            }
        }
    }
    
    // Notifies the view controller that a segue is about to be performed.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetails" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let noteDetailsViewController = segue.destination as! noteViewController
                let selectedNote: Note = notes[indexPath.row]
                
                // initialize viewcontroller to display selected note
                noteDetailsViewController.indexPath = indexPath.row
                noteDetailsViewController.isExisting = false
                noteDetailsViewController.note = selectedNote
                
            }
        }
            
        else if segue.identifier == "addItem" {
            print("User added a new note.")
            
        }
    }
}

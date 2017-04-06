//
//  ViewController.swift
//  Notes
//
//  Created by Lakshmi on 4/6/17.
//  Copyright © 2017 com.arunsivakumar. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
    
    let segueAddNoteViewController = "SegueAddNoteviewController"
    
    
    var notes:[Note]?{
        didSet{
            updateView()
        }
    }
    
    
    private let estimatedRowHeight = CGFloat(44.0)

    
    fileprivate let coreDataManager = CoreDataManager(modelName: "Notes")

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet var notesView: UIView!
    @IBOutlet var tableView: UITableView!
    
    fileprivate lazy var updatedAtDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, HH:mm"
        return dateFormatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()

        // Do any additional setup after loading the view, typically from a nib.
        
//        print(coreDataManager.managedObjectContext)
//        
//        let note = Note(context: coreDataManager.managedObjectContext)
//        note.title = "My Note"
//        
//        let entityDescription = NSEntityDescription.entity(forEntityName: "Note", in: coreDataManager.managedObjectContext)
//        let note = NSManagedObject(entity: entityDescription!, insertInto: coreDataManager.managedObjectContext)
//        note.setValue("My first note",forKey: "title")
//        note.setValue(NSDate(), forKey: "createdAt")
//        note.setValue(NSDate(), forKey: "updatedAt")
//        print(note)
//
//        do{
//            try coreDataManager.managedObjectContext.save()
//        }catch{
//            print(error.localizedDescription)
//        }
//        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchNotes()
    }

    
    // MARK: - View Methods
    
    fileprivate func setupView() {
        setupMessageLabel()
        setupTableView()
    }
    
    fileprivate func updateView() {
        tableView.isHidden = !hasNotes
        messageLabel.isHidden = hasNotes
    }
    fileprivate var hasNotes:Bool{
        guard let notes = notes else{ return false}
        return notes.count > 0
    }
    // MARK: -
    
    private func setupMessageLabel() {
        messageLabel.text = "You don't have any notes yet."
    }
    
    private func fetchNotes(){
        let fetchRequest:NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:#keyPath(Note.updatedAt),ascending:false)]
        coreDataManager.managedObjectContext.performAndWait {
            do{
                let notes = try fetchRequest.execute()
                self.notes = notes
                self.tableView.reloadData()
            }catch{
                print("error")
            }
        }
    }
    
    // MARK: -
    
    private func setupTableView() {
        tableView.isHidden = true
        tableView.separatorInset = .zero
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueAddNoteViewController{
            if let vc = segue.destination as? AddNoteViewController{
                vc.managedObjectContext = coreDataManager.managedObjectContext
            }
        }
    }

}


extension NotesViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return hasNotes ? 1:0

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let count = self.notes?.count else {return 0}
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let note = notes?[indexPath.row]else{fatalError("no note")}
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as? NoteTableViewCell else{ fatalError("error")}
        
        cell.titleLabel.text = note.title
        cell.contentsLabel.text = note.contents
        cell.updatedAtLabel.text = updatedAtDateFormatter.string(from: note.updatedAtAsDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
}

//
//  noteTableViewCell.swift
//  Notes
//
//  Created by Irina on 8/2/17.
//  Copyright © 2017 Apple Developer. All rights reserved.
//

import UIKit

class noteTableViewCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var noteNameLabel: UILabel!
    @IBOutlet weak var noteDescriptionLabel: UILabel!
    @IBOutlet weak var noteImageView: UIImageView!

    override func awakeFromNib() {
        // Similar to view did load in view controller.
        // Called when the screen is shown to the user.
        super.awakeFromNib()

        // Styles for cell shadow and image radius
        shadowView.layer.shadowColor =  UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0.75, height: 3.0)
        shadowView.layer.shadowRadius = 1.5
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.cornerRadius = 2
        
        noteImageView.layer.cornerRadius = 8
    }

    // Function called set up what is inside each element of cell given a Note class
    func configureCell(note: Note) {
        
        self.noteNameLabel.text = note.noteName?.uppercased()
        self.noteDescriptionLabel.text = note.noteDescription
        
        self.noteImageView.image = UIImage(data: note.noteImage! as Data)
    }
}

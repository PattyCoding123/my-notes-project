import 'package:flutter/material.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/utilities/dialogs/delete_dialog.dart';

// typedef function that will be called if user decides to delete note or tap it.
// The function definition will be defined as a parameter in the call
// to NotesListView (this is the beauty of typedef functions!).
typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    Key? key,
    required this.notes, // Need an Iterable of CloudNotes for ListView widget
    required this.onDeleteNote, // Widget utilizing this view must handle onDeleteNote
    required this.onTap, // Widget utilizing this view must handle onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        // Individual note in the Iterable of CloudNotes
        final note = notes.elementAt(index);
        return ListTile(
          onTap: () {
            // Call onTap with parameter definition, passing whatever note was tapped.
            onTap(note);
          },
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              // First, wait for user confirmation from Dialog
              final shouldDelete = await showDeleteDialog(context);
              // If user wants to delete, call onDeleteNote with parameter definition
              // passing whatever note was selected for onDeleteNote.
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}

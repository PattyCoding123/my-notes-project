import 'package:flutter/material.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService; // Cloud services
  late final TextEditingController _textController;

  // Will return either an existing cloud note or create a new one depending on
  // the arguments that were passed to the BuildContext.
  Future<CloudNote> _createOrGetExistingNote(BuildContext context) async {
    // Get the argument that was passed to BuildContext using our own function.
    final widgetNote = context.getArgument<CloudNote>();

    // If a note was passed as a BuildContext argument, update the textController
    // to hold the current text of that note and return it.
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    // If the _note member is already initalized, return it.
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    // Expecting a user. Even though it may crash if there is no current user,
    // we should never end up in this situation.
    final currentUser = AuthService.firebase().currentUser!;
    // Get userId (uid from Firebase)
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    // It is mandatory that _note be assigned to the new note that was created,
    // or else it will not be saved and will get an error.
    _note = newNote;
    return newNote;
  }

  // Notices changes made to the text and will update the note in Cloud Firestore
  // database based on those changes.
  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }

    final text = _textController.text;
    await _notesService.updateNote(
      documentId: note.documentId,
      text: text,
    );
  }

  // Removes the previous textControllerListener and adds in a new one.
  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  // Deletes the note from the Cloud Firestore database if there is no text.
  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  // Saves note in Cloud Firestore database
  // as along as there is text in the exisiting note.
  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (text.isNotEmpty && note != null) {
      await _notesService.updateNote(
        documentId: note.documentId,
        text: text,
      );
    }
  }

  @override
  void initState() {
    _notesService = FirebaseCloudStorage(); // Singleton instance
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.loc.note,
        ),
        actions: [
          // Icons that will allow users to share the selected note
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                // Call Share plugin's .share() method
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        // call create or get note function
        future: _createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: context.loc.start_typing_your_note,
                ),
              );

            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

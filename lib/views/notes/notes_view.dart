import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/route.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  // Declare a FirebaseCloudStorage variable
  late final FirebaseCloudStorage _notesService;

  // Force expose the current user's id (uid)
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    // Use the FirebaseCloudStorage singleton
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          // IconButton action to create a new cloud note
          IconButton(
            onPressed: () {
              // Call createOrUpdateRoute without passing a cloud note argument
              // to the build context.
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          // PopupMenuBotton action that currently contains logout option
          PopupMenuButton<MenuAction>(
            // On selected deals with whataever PopupMenuItem was selected!
            onSelected: (value) async {
              // Use a switch to deal with the PopupMenuItems!
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    if (!mounted) return;
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
        // Gets all the current user's notes from the Cloud Firestore database.
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                // The snapshot data for StreamBuilder contains all the notes
                // from the Cloud Firestore database that were placed in the
                // stream via the allNotes method in FirebaseCloudStorage.
                final allNotes = snapshot.data as Iterable<CloudNote>;
                // Return our NotesListView widget with allNotes as the
                // notes parameter.
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(documentId: note.documentId);
                  },
                  // On onTap, pass the current note as an argument
                  // to the BuildContext of createOrUpdateNoteView
                  onTap: (note) {
                    Navigator.of(context)
                        .pushNamed(createOrUpdateNoteRoute, arguments: note);
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }

            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mynotes/constants/route.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  // Declare a NotesService variable
  late final NotesService _notesService;

  // Force expose the current user's email to NoteView for getOrCreateUser
  String get userEmail => AuthService.firebase().currentUser!.email!;

  // We need to input 2 life cycles events:
  // 1. Open database once NotesView is created
  // 2. Close database once NotesView is disposed
  @override
  void initState() {
    // Make an instance of NotesService to use inside NotesView
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          // IconButton action to create note
          IconButton(
            onPressed: () {
              // Call createOrUpdateRoute without passing a note argument
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
                    await AuthService.firebase().logOut(); // log user out

                    // Check mounted property for BuildContext across async gaps
                    if (!mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
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
      body: FutureBuilder(
        // Get or create current user
        future: _notesService.getOrCreateUser(email: userEmail),
        // Builder, during the done connection state, returns a Stream Builder
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                // Gets all notes from the database
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        // The snapshot data for StreamBuilder contains all the notes in the database
                        // which we get from the NotesService stream controller
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        // Return our NotesListView widget with allNotes as the
                        // notes parameter.
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async {
                            await _notesService.deleteNote(id: note.id);
                          },
                          // On onTap, pass the current note as an argument
                          // to the BuildContext of createOrUpdateNoteView
                          onTap: (note) {
                            Navigator.of(context).pushNamed(
                                createOrUpdateNoteRoute,
                                arguments: note);
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }

                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );

            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  // Database member that is initialized via Firebase Cloud Firestore
  // collection method. The collection's name is passed as the argument.
  final notes = FirebaseFirestore.instance.collection('notes');

  // Method to delete a specific note
  Future<void> deleteNote({required String documentId}) async {
    try {
      // notes.doc(documentId) is the path towards the specific note document
      // that is in the "notes" collection
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  // Method to update a specific note
  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      // notes.doc(documentId) is the path towards the specific note document
      // that is in the "notes" collection
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  // Method to get all the notes for a specified user
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      // "snapshot" subscribes us to all the changes happening to the firestore
      // data, and we will map these changes to the stream (since snapshots
      // is a stream of QuerySnapshots). We will be inserting an Iterable of
      // CloudNotes to the stream.
      notes.snapshots().map((event) => event.docs // Get documents from snapshot
          // Return an Iterable of CloudNotes. These notes are constructed
          // by the documents from firestore.
          .map((doc) => CloudNote.fromSnapshot(doc))
          // The "where" indicates the notes
          // that are being converted into CloudNotes belong to the current user.
          .where((note) => note.ownerUserId == ownerUserId));

  // Method to get notes by the user's id
  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get() // Return query snapshot which has a list of documents.
          .then(
            // Return a list of CloudNotes constructed from the list of documents
            // provided by the query snapshot.
            // Remember, documents are represented as a QueryDocumentSnapshot.
            (value) => value.docs.map(
              (doc) {
                return CloudNote(
                  documentId: doc.id,
                  ownerUserId: doc.data()[ownerUserIdFieldName] as String,
                  text: doc.data()[textFieldName] as String,
                );
              },
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  // Method to create new notes and store them into the Cloud Firestore database.
  // Use cloud_storage_constants to fill in field name requirements.
  void createNewNote({required String ownerUserId}) async {
    // Cloud Firestore's add method returns a Future document reference, so we must
    // await on it.
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  // Instance that calls to private factory constructor
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  // Private factory constructor
  FirebaseCloudStorage._sharedInstance();

  // Singleton constructor that calls to the _shared instance
  factory FirebaseCloudStorage() => _shared;
}

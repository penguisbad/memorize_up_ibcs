import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memorize_up/model/folders.dart';
import 'package:memorize_up/model/sets.dart';
import 'package:memorize_up/model/calendar.dart';

Future<void> saveSet({required Set set}) async {
  await FirebaseFunctions.instance.httpsCallable('save_set').call({
    'set_id': set.id,
    'set_data': set.toMap()
  });
}

Future<void> addSet({required Set set}) async {
  await FirebaseFunctions.instance.httpsCallable('add_set').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid,
    'set_id': set.id,
    'set_data': set.toMap()
  });
}

Future<void> deleteSet({required Set set}) async {
  await FirebaseFunctions.instance.httpsCallable('delete_set').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid,
    'set_id': set.id,
    'in_folder': set.inFolder,
    'folder_id': set.folderId
  });
}

Future<Set> loadSet({required String setId}) async {
  final setData = (await FirebaseFunctions.instance.httpsCallable('load_set').call({
    'set_id': setId
  })).data;
  return Set.fromMap(setData);
}

Future<List<Set>> loadSets() async {
  final setsData = (await FirebaseFunctions.instance.httpsCallable('load_sets').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid
  })).data['sets'];
  final sets = <Set>[];
  for (final setData in setsData) {
    sets.add(Set.fromMap(setData));
  }
  return sets;
}

Future<List<Set>> loadSetIds({required List<String> setIds}) async {
  final setsData = (await FirebaseFunctions.instance.httpsCallable('load_set_ids').call({
    'set_ids': setIds
  })).data['sets'];
  
  final sets = <Set>[];
  for (final setData in setsData) {
    sets.add(Set.fromMap(setData));
  }
  return sets;
}

Future<List<Set>> loadSharedSets() async {
  final data = (await FirebaseFunctions.instance.httpsCallable('load_shared_sets').call({
    'email': FirebaseAuth.instance.currentUser!.email
  })).data;
  final setsData = data['shared_sets'];
  final sharedBy = data['shared_by'];
  final sets = <Set>[];

  for (var i = 0; i < setsData.length; i++) {
    final set = Set.fromMap(setsData[i]);
    set.sharedBy = sharedBy[i];
    set.readonly = true;
    sets.add(set);
  }
  return sets;
}

Future<List<Set>> browseSets({required String search}) async {
  final setsData = (await FirebaseFunctions.instance.httpsCallable('browse_sets').call({
    'search': search
  })).data['sets'];
  final sets = <Set>[];
  for (final setData in setsData) {
    final set = Set.fromMap(setData);
    set.readonly = true;
    sets.add(set);
  }
  return sets;
}

Future<void> saveFolder({required Folder folder}) async {
  await FirebaseFunctions.instance.httpsCallable('save_folder').call({
    'folder_id': folder.id,
    'folder_data': folder.toMap()
  });
}

Future<void> addFolder({required Folder folder}) async {
  
  await FirebaseFunctions.instance.httpsCallable('add_folder').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid,
    'folder_id': folder.id,
    'folder_data': folder.toMap()
  });
}

Future<void> deleteFolder({required Folder folder}) async {
  
  await FirebaseFunctions.instance.httpsCallable('delete_folder').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid,
    'folder_id': folder.id
  });
}

Future<Folder> loadFolder({required String folderId}) async {
  final folderData = (await FirebaseFunctions.instance.httpsCallable('load_folder').call({
    'folder_id': folderId
  })).data;
  return Folder.fromMap(folderData);
}

Future<List<Folder>> loadFolders() async {
  final foldersData = (await FirebaseFunctions.instance.httpsCallable('load_folders').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid
  })).data['folders'];
  final folders = <Folder>[];
  for (final folderData in foldersData) {
    folders.add(Folder.fromMap(folderData));
  }
  return folders;
}

Future<void> createUser({required String email}) async {
  await FirebaseFunctions.instance.httpsCallable('create_user').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid,
    'email': email
  });
}

Future<void> updateUserEmail({required String email}) async {
  await FirebaseFunctions.instance.httpsCallable('update_user_email').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid,
    'email': email
  });
}

Future<void> deleteUser() async {
  await FirebaseFunctions.instance.httpsCallable('delete_user').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid
  });
}

Future<bool> checkUserInDatabase() async {
  final response = await FirebaseFunctions.instance.httpsCallable('check_user').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid
  });

  if (!response.data['user_exists']) {
    await FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
    return false;
  }
  return true;
}

Future<Map<String, dynamic>> loadUser() async {
  final response = await FirebaseFunctions.instance.httpsCallable('load_user').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid
  });
  return response.data;  
}

Future<bool> checkIfEmailExists({required String email}) async {
  final response = await FirebaseFunctions.instance.httpsCallable('check_email').call({
    'email': email
  });
  return response.data['email_exists'];
}

Future<void> saveEvent({required Event event}) async {
  await FirebaseFunctions.instance.httpsCallable('save_event').call({
    'event_id': event.id,
    'event_data': event.toMap()
  });
}

Future<void> addEvent({required Event event}) async {
  await FirebaseFunctions.instance.httpsCallable('add_event').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid,
    'event_id': event.id,
    'event_data': event.toMap()
  });
}

Future<void> deleteEvent({required String eventId}) async {
  await FirebaseFunctions.instance.httpsCallable('delete_event').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid,
    'event_id': eventId
  });
}

Future<void> removeEventsForSetId({required String setId}) async {
  await FirebaseFunctions.instance.httpsCallable('remove_events_for_set_id').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid,
    'set_id': setId
  });
}

Future<List<Event>> loadEvents() async {
  final eventsData = (await FirebaseFunctions.instance.httpsCallable('load_events').call({
    'user_id': FirebaseAuth.instance.currentUser!.uid
  })).data['events'];
  final events = <Event>[];
  for (final eventData in eventsData) {
    events.add(Event.fromMap(eventData));
  }
  return events;
}
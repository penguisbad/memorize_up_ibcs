import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class Set {
  String name;
  String description;
  String id;
  List<String> sharedWith;
  bool readonly = false;
  bool inFolder;
  bool isPublic;
  String? folderId;
  DateTime? dueDate;
  String? sharedBy;

  Set({required this.name, required this.description, required this.id, required this.sharedWith, 
      this.dueDate, this.isPublic = true, this.inFolder = false, this.folderId, this.sharedBy});

  bool canStudy();
  
  factory Set.fromMap(Map data) {
    return FlashcardSet.fromMap(data);
  }

  Map<String, dynamic> toMap();
}

class Flashcard {
  String front;
  String back;
  bool starred;

  Flashcard({required this.front, required this.back, required this.starred});
}

class FlashcardSet extends Set {
  List<Flashcard> flashcards;

  FlashcardSet({required super.id, required super.name, required super.description, required this.flashcards, 
  required super.sharedWith, super.isPublic, super.dueDate, super.inFolder, super.folderId});
  
  @override
  bool canStudy() => flashcards.length >= 4;

  @override
  factory FlashcardSet.fromMap(Map data) {
    final flashcardsToAdd = <Flashcard>[];

    for (var i = 0; i < data['flashcards'].length; i++) {
      flashcardsToAdd.add(Flashcard(
        front: data['flashcards'][i]['front'], 
        back: data['flashcards'][i]['back'],
        starred: data['flashcards'][i]['starred']
      ));
    }


    final emailsToAdd = <String>[];

    for (var i = 0; i < data['sharedWith'].length; i++) {
      emailsToAdd.add(data['sharedWith'][i]);
    }

    DateTime? dueDate;

    if (data['dueDate'] != null) {
      final dueDateSplit = data['dueDate'].split(' ');
      dueDate = DateTime(int.parse(dueDateSplit[0]), int.parse(dueDateSplit[1]), int.parse(dueDateSplit[2]));
    }

    return FlashcardSet(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      sharedWith: emailsToAdd,
      isPublic: data['isPublic'],
      flashcards: flashcardsToAdd,
      dueDate: dueDate,
      inFolder: data['inFolder'],
      folderId: data['folderId']
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final flashcardsToAdd = <Map<String, dynamic>>[];

    for (final flashcard in flashcards) {
      flashcardsToAdd.add({
        'front': flashcard.front,
        'back': flashcard.back,
        'starred': flashcard.starred,
      });
    }

    return {
      'id': id,
      'setType': 'flashcards',
      'name': name,
      'description': description,
      'sharedWith': sharedWith,
      'isPublic': isPublic,
      'flashcards': flashcardsToAdd,
      'dueDate': dueDate != null ? '${dueDate!.year} ${dueDate!.month} ${dueDate!.day}' : null,
      'inFolder': inFolder,
      'folderId': folderId
    };
  }
}

class SetsNotifier extends ChangeNotifier {
  final List<Set> _sets = [];

  List<Set> get sets => _sets;

  void addSet(Set set) {
    _sets.add(set);
    notifyListeners();
  }

  void removeAt(int index) {
    _sets.removeAt(index);
    notifyListeners();
  }

  void remove(Set set) {
    _sets.remove(set);
    notifyListeners();
  }

  void insert(int index, Set set) {
    _sets.insert(index, set);
    notifyListeners();
  }

  void addAll(List<Set> sets) {
    _sets.addAll(sets);
    notifyListeners();
  }
}
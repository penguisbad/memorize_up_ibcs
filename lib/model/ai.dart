import 'package:image_picker/image_picker.dart';
import 'package:memorize_up/model/sets.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

Future<FlashcardSet> createFlashcardsFromAI({
  required String name,
  required String description,
  required bool fromNotes,
  String? notes,
  XFile? photo,
}) async {

  final model = FirebaseVertexAI.instance.generativeModel(
    model: 'gemini-1.5-flash',
    generationConfig: GenerationConfig(
      temperature: 0.0,
      responseMimeType: 'application/json',
      responseSchema: Schema.array(
        items: Schema.object(
          properties: {
            'front': Schema.string(),
            'back': Schema.string()
          }
        )
      ),
    ),
  );
  
  late List<Content> prompt;
  if (fromNotes) {
    prompt = [Content.text('Create a list of flashcards from the following text: $notes')];
  } else {
    prompt = [Content.multi([TextPart('Create a list of flashcards from the following image:'), InlineDataPart(photo!.mimeType ?? 'image/heic', await photo.readAsBytes())])];
  }
  final response = await model.generateContent(prompt);
  final flashcardsJson = jsonDecode(response.text!);

  final flashcards = <Flashcard>[];
  
  for (final flashcardJson in flashcardsJson) {
    flashcards.add(Flashcard(
      front: flashcardJson['front'],
      back: flashcardJson['back'], 
      starred: false
    ));
  }

  return FlashcardSet(
    id: const Uuid().v6(),
    name: name,
    description: description, 
    flashcards: flashcards,
    sharedWith: []
  );
}
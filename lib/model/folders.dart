
class Folder {

  String id;
  String name;
  List<String> setIds;

  Folder({required this.id, required this.name, required this.setIds});

  factory Folder.fromMap(Map data) {
    final setIdsToAdd = <String>[];

    for (final setId in data['setIds']) {
      setIdsToAdd.add(setId);
    }

    return Folder(
      id: data['id'], 
      name: data['name'], 
      setIds: setIdsToAdd
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'setIds': setIds
    };
  }
}
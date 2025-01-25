def _save_set(client, set_id, set_data):
    client.collection('sets').document(set_id).set(set_data)

def _load_set(client, set_id):
    set_data = client.collection('sets').document(set_id).get().to_dict()
    set_data['id'] = set_id

    return set_data

def _save_folder(client, folder_id, folder_data):
    client.collection('folders').document(folder_id).set(folder_data)

def _load_folder(client, folder_id):
    folder = client.collection('folders').document(folder_id).get().to_dict()
    folder['id'] = folder_id

    return folder

def _save_event(client, event_id, event_data):
    client.collection('events').document(event_id).set(event_data)
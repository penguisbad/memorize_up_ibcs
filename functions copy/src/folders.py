from firebase_functions import https_fn, options
from firebase_admin import firestore
from src.save_load_util import _save_folder, _load_folder, _save_set, _load_set
from src.calendar import remove_events_for_set_id

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def save_folder(req: https_fn.CallableRequest):
    client = firestore.client()

    _save_folder(client, req.data['folder_id'], req.data['folder_data'])
    return {}

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def add_folder(req: https_fn.CallableRequest):
    client = firestore.client()

    client.collection('folders').document(req.data['folder_id']).set(req.data['folder_data'])

    user_doc = client.collection('users').document(req.data['user_id'])
    folder_ids = user_doc.get().to_dict()['folders']
    folder_ids.append(req.data['folder_id'])
    user_doc.update({
        'folders': folder_ids
    })

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def delete_folder(req: https_fn.CallableRequest):
    client = firestore.client()

    folder = _load_folder(client, req.data['folder_id'])

    for set_id in folder['setIds']:
        set_data = _load_set(client, set_id)
        set_data['inFolder'] = False
        set_data['folderId'] = None
        _save_set(client, set_id, set_data)

    client.collection('folders').document(req.data['folder_id']).delete()

    user_doc = client.collection('users').document(req.data['user_id'])
    folder_ids = user_doc.get().to_dict()['folders']
    folder_ids.remove(req.data['folder_id'])
    user_doc.update({
        'folders': folder_ids
    })

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def load_folder(req: https_fn.CallableRequest):
    client = firestore.client()

    return _load_folder(client, req.data['folder_id'])

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def load_folders(req: https_fn.CallableRequest):
    client = firestore.client()

    folder_ids = client.collection('users').document(req.data['user_id']).get().to_dict()['folders']

    return {
        'folders': [_load_folder(client, folder_id) for folder_id in folder_ids]
    }
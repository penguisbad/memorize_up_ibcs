from __future__ import annotations
from firebase_functions import https_fn, options
from firebase_admin import firestore
from src.save_load_util import _save_set, _load_set, _save_folder, _load_folder
from src.calendar import _remove_events_for_set_id

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def save_set(req: https_fn.CallableRequest):
    client = firestore.client()
    _save_set(client, req.data['set_id'], req.data['set_data'])

    return {}

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def add_set(req: https_fn.CallableRequest):
    client = firestore.client()

    _save_set(client, req.data['set_id'], req.data['set_data'])
    
    user_doc = client.collection('users').document(req.data['user_id'])
    set_ids = user_doc.get().to_dict()['sets']
    set_ids.append(req.data['set_id'])
    user_doc.update({
        'sets': set_ids
    })

    return {}

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def delete_set(req: https_fn.CallableRequest):
    client = firestore.client()

    if req.data['in_folder']:
        folder = _load_folder(client, req.data['folder_id'])
        folder['setIds'].remove(req.data['set_id'])
        _save_folder(client, folder['id'], folder)
    
    _remove_events_for_set_id(client, req.data['user_id'], req.data['set_id'])

    user_doc = client.collection('users').document(req.data['user_id'])
    set_ids = user_doc.get().to_dict()['sets']
    set_ids.remove(req.data['set_id'])
    user_doc.update({
        'sets': set_ids
    })

    return {}

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def load_set(req: https_fn.CallableRequest):
    client = firestore.client()
    return _load_set(client, req.data['set_id'])

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def load_sets(req: https_fn.CallableRequest):
    client = firestore.client()
    set_ids = client.collection('users').document(req.data['user_id']).get().to_dict()['sets']

    return {
        'sets': [_load_set(client, set_id) for set_id in set_ids]
    }

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def load_set_ids(req: https_fn.CallableRequest):
    client = firestore.client()

    return {
        'sets': [_load_set(client, set_id) for set_id in req.data['set_ids']]
    }

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def load_shared_sets(req: https_fn.CallableRequest):
    client = firestore.client()

    user_docs = client.collection('users').list_documents()
    sets = []
    shared_by = []

    for user_doc in user_docs:
        user_data = user_doc.get().to_dict()

        if user_data['email'] == req.data['email']:
            continue

        for set_id in user_data['sets']:
            set_data = _load_set(client, set_id)

            if req.data['email'] in set_data['sharedWith']:
                sets.append(set_data)
                shared_by.append(user_data['email'])
    
    return {
        'shared_sets': sets,
        'shared_by': shared_by
    }

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def browse_sets(req: https_fn.CallableRequest):
    client = firestore.client()

    sets = []
    user_docs = client.collection('users').list_documents()

    for user_doc in user_docs:
        user_data = user_doc.get().to_dict()

        for set_id in user_data['sets']:
            set_data = _load_set(client, set_id)

            if set_data['isPublic'] and (
                req.data['search'].lower() in set_data['name'].lower() or req.data['search'].lower() in set_data['description'].lower()
            ):
                sets.append(set_data)
            
        if len(sets) > 100:
            break
    
    return {
        'sets': sets
    }
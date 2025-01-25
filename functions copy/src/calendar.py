from firebase_functions import https_fn, options
from firebase_admin import firestore
from src.save_load_util import _save_event

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def save_event(req: https_fn.CallableRequest):
    client = firestore.client()

    _save_event(client, req.data['event_id'], req.data['event_data'])

    return {}

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def add_event(req: https_fn.CallableRequest):
    client = firestore.client()

    _save_event(client, req.data['event_id'], req.data['event_data'])

    user_doc = client.collection('users').document(req.data['user_id'])
    event_ids = user_doc.get().to_dict()['events']
    event_ids.append(req.data['event_id'])
    user_doc.update({
        'events': event_ids
    })

    return {}

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def delete_event(req: https_fn.CallableRequest):
    client = firestore.client()

    client.collection('events').document(req.data['event_id']).delete()

    user_doc = client.collection('users').document(req.data['user_id'])
    event_ids = user_doc.get().to_dict()['events']
    event_ids.remove(req.data['event_id'])
    user_doc.update({
        'events': event_ids
    })

    return {}

def _remove_events_for_set_id(client, user_id, set_id):
    user_doc = client.collection('users').document(user_id)
    event_ids = user_doc.get().to_dict()['events']

    event_docs = client.collection('events').where('setId', '==', set_id).get()

    for event_id in [event_doc.id for event_doc in event_docs]:
        if event_id in event_ids:
            event_ids.remove(event_id)
        client.collection('events').document(event_id).delete()

    user_doc.update({
        'events': event_ids
    })

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def remove_events_for_set_id(req: https_fn.CallableRequest):
    client = firestore.client()
    _remove_events_for_set_id(client, req.data['user_id'], req.data['set_id'])

    return {}

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def load_events(req: https_fn.CallableRequest):
    client = firestore.client()

    event_ids = client.collection('users').document(req.data['user_id']).get().to_dict()['events']

    events = []
    for event_id in event_ids:
        event = client.collection('events').document(event_id).get().to_dict()
        event['id'] = event_id
        events.append(event)
    
    return {
        'events': events
    }
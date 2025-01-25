from firebase_functions import https_fn, options
from firebase_admin import firestore

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def load_user(req: https_fn.CallableRequest):
    client = firestore.client()

    user_doc = client.collection('users').document(req.data['user_id'])

    return user_doc.get().to_dict()

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def check_email(req: https_fn.CallableRequest):
    client = firestore.client()

    email_exists = False
    for doc in client.collection('users').list_documents():
        if doc.get().to_dict()['email'] == req.data['email']:
            email_exists = True
            break

    return {
        'email_exists': email_exists
    }

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def check_user(req: https_fn.CallableRequest):
    client = firestore.client()

    user_exists = client.collection('users').document(req.data['user_id']).get().exists

    return {
        'user_exists': user_exists
    }

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def create_user(req: https_fn.CallableRequest):
    client = firestore.client()
    
    client.collection('users').document(req.data['user_id']).set({
        'email': req.data['email'],
        'sets': [],
        'folders': [],
        'events': []
    })

    return {}

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def update_user_email(req: https_fn.CallableRequest):
    client = firestore.client()

    client.collection('users').document(req.data['user_id']).update({
        'email': req.data['email']
    })

    return {}

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def delete_user(req: https_fn.CallableRequest):
    client = firestore.client()

    user_doc = client.collection('users').document(req.data['user_id'])
    user_data = user_doc.get().to_dict()

    for set_id in user_data['sets']:
        client.collection('sets').document(set_id).delete()
    
    for event_id in user_data['events']:
        client.collection('events').document(event_id).delete()
    
    for folder_id in user_data['folders']:
        client.collection('folders').document(folder_id).delete()

    user_doc.delete()

    return {}

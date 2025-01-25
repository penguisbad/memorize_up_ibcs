from firebase_admin import firestore, initialize_app
from firebase_functions import https_fn, options
from src.users import *
from src.sets import *
from src.folders import *
from src.calendar import *

initialize_app()

@https_fn.on_call(cors=options.CorsOptions(
        cors_origins='*',
        cors_methods='*'
))
def submit_feedback(req: https_fn.CallableRequest):
    client = firestore.client()

    client.collection('feedback').add({
        'email': req.data['email'],
        'feedback': req.data['feedback']
    })

    return {}
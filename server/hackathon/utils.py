import requests

def send_message(api_key, registration_id, data=None, notification=None):
    headers = {'Authorization': 'key={}'.format(api_key)}

    if notification:
        notification['sound'] = 'default'

    r = requests.post('https://gcm-http.googleapis.com/gcm/send',
                      json={'to': registration_id,
                            'data': data,
                            'notification': notification},

                      headers=headers)

    if r.status_code != 200:
        raise ValueError()


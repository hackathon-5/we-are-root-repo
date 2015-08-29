import time
from hackathon import process_notifications, process_emails, app

if __name__ == '__main__':
    while True:
        with app.app_context():
            process_emails()
        time.sleep(3600)
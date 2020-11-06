import os
from dotenv import load_dotenv

basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '.env'))


class Config(object):
    SECRET_KEY = os.environ.get('SECRET_KEY') or b'_5#y2L"F4Q8z\n\xec]/'
    WTF_CSRF_SECRET_KEY = os.environ.get('SECRET_KEY') or b'_563#9236hdgjh"F4Q8z\n\xec]/'
    SESSION_COOKIE_SAMESITE = 'Lax'
    # SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
    #     'sqlite:///' + os.path.join(basedir, 'app.db')
    # SQLALCHEMY_TRACK_MODIFICATIONS = False
    LOG_TO_STDOUT = os.environ.get('LOG_TO_STDOUT', False)
    LANGUAGES = ['en', 'es']
    print(os.path.join(os.path.dirname(basedir), 'logs'))
    LOG_DIR = os.environ.get('LOG_DIR', 
                            os.path.join(os.path.dirname(basedir), 'logs'))
# Database settings
dbaccess = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',  # Add 'postgresql_psycopg2', 'mysql', 'sqlite3' or 'oracle'.
        'NAME': 'DBNAME',  # Or path to database file if using sqlite3.
        'USER': 'DBUSER',  # Not used with sqlite3.
        'PASSWORD': 'DBPASS',  # Not used with sqlite3.
        'HOST': 'DBHOST',  # Set to empty string for localhost. Not used with sqlite3.
        'PORT': 'DBPORT',  # Set to empty string for default. Not used with sqlite3.
   },
}


# Make this unique, and don't share it with anybody.
MY_SECRET_KEY = 'UNIQUEKEY'


# set default datetime format for datetime.datetime.strftime()
defaultDatetimeFormatMySQL = "%Y-%m-%d %H:%M:%SZ"
defaultDatetimeFormatOracle = "%Y-%m-%d %H:%M:%S"
defaultDatetimeFormat = defaultDatetimeFormatMySQL


# log directory
LOG_ROOT = "@@LOGROOT@@"

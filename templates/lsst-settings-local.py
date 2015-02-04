## No yet customized

# Set to anything to disable self-monitoring data
# to be injected into the database.  Otherwise r/w
# DB access is required.
#NO_SELF_MONITOR = 'yes'

# Set to the path to directory accessible for writing
# to your Web server to store Django sessions on-disk
# (otherwise DB is used and, once again, r/w access
# is needed).
#SESSION_STORE_DIR = '/some/filesystem/path/sessions'


VOMS_PROXY_CERT = "/tmp/x509_prodsys_mon"

VOMS_OPTIONS = {
    "vo": "atlas",
    "host": "voms.cern.ch",
    "port": 8443,
    "user_cert": VOMS_PROXY_CERT,
    "user_key": VOMS_PROXY_CERT,
}

# DEFT API settings

DEFT_AUTH_USER = 'FIXME'
DEFT_AUTH_KEY = 'FIXME'

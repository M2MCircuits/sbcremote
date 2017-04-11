from google.appengine.ext import ndb


class Account(ndb.Model):
	email = ndb.StringProperty()
	serviceID = ndb.StringProperty()
	phone_token = ndb.StringProperty(default=None, repeated=True)

from google.appengine.ext import ndb


class Account(ndb.model):
	email = ndb.StringProperty()
	serviceID = ndb.IntegerProperty()
	phone_token = ndb.StringProperty(default=None, repeated=True)

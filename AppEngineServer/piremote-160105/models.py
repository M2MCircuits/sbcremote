from google.appengine.ext import ndb


class Account(ndb.model):
	name = ndb.StringProperty()
	email = ndb.StringProperty()
	service_id = ndb.IntegerProperty()
	token = ndb.StringProperty()

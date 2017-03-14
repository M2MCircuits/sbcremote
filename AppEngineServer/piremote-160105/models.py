from google.appengine.ext import ndb


class User(ndb.model):
	name = ndb.StringProperty()
	email = ndb.StringProperty()
	u_id = ndb.IntegerProperty()
	token = ndb.StringProperty()

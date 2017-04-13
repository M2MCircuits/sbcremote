from google.appengine.ext import ndb


class Account(ndb.Model):
	email = ndb.StringProperty()
	serviceID = ndb.StringProperty()
	alias = ndb.StringProperty()
	phone_token = ndb.StringProperty(default=None, repeated=True)
	#21 values, each corresponding to a pin. Notice some pins will have invalid values. 
	config = ndb.StringProperty(default=None, repeated=True)
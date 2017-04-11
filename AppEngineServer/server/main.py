#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import webapp2
import logging
from basehelper import MainHelperClass
from models import Account
from google.appengine.ext import ndb


class MainHandler(webapp2.RequestHandler):
    def get(self):
        self.response.write('Hello PiRemote!')


"""
Handles sending notification to the user phone 
Request_Types: POST 
Args:
	serviceId : parama
	pin_number : requestBody
Returns:
	sucess or error response 


"""
class APNSHandler(MainHelperClass):
	INPUT = 0
	OUTPUT = 1

	HIGH = 1
	LOW = 0

	RESTART = 0
	CHANGE = 1

	valString = ["LOW", "HIGH"]
	funcStr = ["INPUT", "OUTPUT"]

	def post(self, serviceID):
		account = self.validateAccount(serviceID)
		body = self.jsonifyRequestBody()
		pin = body["pin"]
		message = int(body["message"])
		funct = int(body["funct"])
		val = int(body["val"])
		if account and pin:
			for phone_token in account.token:
				# If it's a restart, we don't send pin information.
				if message == RESTART:
					#TODO: Add more information about Pi such as "the unique pi name"
					self.sendAPN("Your Pi has restarted!", phone_token, None)
				else:
					pin_data = {"pin" : pin,
								"func" : funct.
								"val" : val}
				# TODO : Get Pi name? Case where user has mutliple pi's on the account. How will the user know which Pi?
				# TODO: Convert pin number to more meaningful representation? Have a config tied to the pi address which stores 
				# string representing names of services tied to the each pin number or None if there isn't one?
				self.sendAPN("Pin " + pin + " has turned " + valString[val]  , phone_token, pin_data)
			self.writeResponse("You just hit the APNS endpoint. Your serviceID is " + serviceID)
		else:
			self.writeErrorResponse("Invalid serviceID or no pin provided")


"""
Handles creation of user accounts.
Request-types : POST

Args:
	serviceIDs : array of serviceids, body
	email : body 
Returns:
	sucess or failure

"""
class AccountHandler(MainHelperClass):

	def post(self):
		json_req = self.jsonifyRequestBody()
		data = json_req
		print data
		print "Entering account handler!"
		service_ids = data["service_ids"]
		for id_ in service_ids:
			# Checks if account exists at all..
			# Means only there cannot be two accounts with the same service_id
			accountExists = self.validateAccount(id_)
			if accountExists:
				print "Account exists"
				continue
			print "Creating account for id " + id_
			acc = Account()
			try:
				acc.email = data["email"]
				print "gotten email"
				acc.serviceID = id_
				print "got service id"
				acc.key = ndb.Key(Account, id_)
				print "creating key"
				acc.put()
				print "Account sucessfully created"
				logging.info("Account has been put into the datastore")
			except:
				continue
		self.writeSucessfulResponse("data", "Account sucessfully created")
		# self.writeErrorResponse("Account data not fully provided.")

class APNPhoneTokenHandler(MainHelperClass):
    def post(self):
    	# We get all pi addresses associated with email account.
    	# We add the phone number to phones that listen to the device
        requestBody = self.jsonifyRequestBody()
        parsed_token = self.parseToken(requestBody["token"])
        email = requestBody["email"]

        if not parseToken or not email:
        	self.writeErrorResponse("Seems like something went wrong. (User Auth)")
        	return
        accounts = Account.query(Account.email == email).fetch()
        for acc in accounts:
        	if parsed_token not in acc:
        		acc.phone_token += parsed_token
            	acc.put()
        		# Hacky...
				# Why? Because technically the phone token can change for the same device (rare but possible), but
				# the old token would still be mapped to the account. We never remove them. Only add. 
				# Best we can do as the Pi can only hold it's address for security purposes.
        self.writeSucessfulResponse("data", "Sucess, user token has been inputed.")

    def parseToken(self, token):
    	if not token:
    		return None
        startString = token[1:len(token) - 1]
        endString = startString.replace(" ", "")
        return endString


class APNTest(MainHelperClass):
	def get(self, token):
		self.sendAPN("Hello World", token, None)



app = webapp2.WSGIApplication([
    ('/', MainHandler),
    ('/apns/(\S*)', APNSHandler), 
    ('/accounts', AccountHandler),
    ('/token', APNPhoneTokenHandler),
    ('/apnstest/(\S*)', APNTest)
], debug=True)

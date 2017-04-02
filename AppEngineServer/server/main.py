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
from basehelper import MainHelperClass

class MainHandler(webapp2.RequestHandler):
    def get(self):
        self.response.write('Hello PiRemote!')


class APNSHandler(MainHelperClass):
	def post(self, serviceID):
		account = self.validateAccount(serviceID)
		body = self.jsonifyRequestBody()
		pin = body["pin"]
		if account and pin:
			for phone_token in account.token:
				pin_data = {"pin" : pin}
				self.sendAPN("Something's Up!", phone_token, pin_data)
			self.writeResponse("You just hit the APNS endpoint. Your serviceID is " + serviceID)
		else:
			self.writeErrorResponse("Invalid serviceID or no pin provided")

	def get(self, serviceID):
		account = self.validateAccount(serviceID)
		if account:
			for phone_token in account.token:
				self.sendAPN("Testing", token, None)
			self.writeResponse("You just hit the APNS endpoint. Your serviceID is " + serviceID)
		else:
			self.writeErrorResponse("Invalid serviceID")


class AccountHandler(MainHelperClass):
	def jsonifyAccount(account):
		returnDict = {
						"email" : account.email,
						"service_id" : account.serviceID,
		}
		return returnDict


	def get(self, serviceID):
		account = self.validateAccount(serviceID)
		if account:
			data = self.jsonifyAccount(account)
			self.writeSucessfulResponse("data", data)
		else:
			self.writeErrorResponse("Invalid serviceID")

	def post(self, serviceID):
		json_req = self.jsonifyRequestBody()
		data = json_req["data"]
		accountExists = self.validateAccount(serviceID)
		if accountExists:
			self.writeErrorResponse("Account already exists")
			return
		acc = Account()
		try:
			acc.email = data["email"]
			acc.serviceID = serviceID
			acc.key = ndb.Key(Account, serviceID)
			acc.put()
			self.writeSucessfulResponse("data", "Account sucessfully created")
		except:
			self.writeErrorResponse("Account data not fully provided.")

class APNPhoneTokenHandler(MainHelperClass):
	# TODO in Testing:  Check if this can be called before serviceID is recieved.
    def post(self, serviceID):
        requestBody = self.jsonifyRequestBody()
        parsed_token = self.parseToken(requestBody["token"])
        if not parseToken:
        	self.writeErrorResponse("Seems like something went wrong. (User Auth)")
        	return
        accKey = ndb.Key(Account, serviceID)
        acc = accKey.get()
        if acc:
        	# Hacky...
			# Why? Because technically the phone token can change for the same device (rare but possible), but
			# the old token would still be mapped to the account. We never remove them. Only add. 
			# Best we can do as the Pi can only hold it's address for security purposes.
            acc.phone_token += parsed_token
            acc.put()
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
    ('/account/(\S*)', AccountHandler),
    ('/token/(\S*)', APNPhoneTokenHandler),
    ('/apnstest/(\S*)', APNTest)
], debug=True)

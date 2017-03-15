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
		if account:
			self.sendAPN("Testing", account.token, None)
			self.writeResponse("You just hit the APNS endpoint. Your serviceID is " + serviceID)
		else:
			self.writeResponse("Invalid serviceID")

	def get(self, serviceID):
		self.writeResponse("This endpoint is POST only. Your service ID is " + serviceID)


class AccountHandler(MainHelperClass):
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
    def post(self):
        requestBody = self.jsonifyRequestBody()
        email = requestBody["email"]
        parsed_token = self.parseToken(requestBody["token"])
        if not email or not parseToken:
        	self.writeErrorResponse("Seems like something went wrong. (User Auth)")
        	return
        results = Account.query(Account.email == email).fetch()
        for acc in results:
            acc.phone_token = parsed_token
            acc.put()
        self.writeSucessfulResponse("info", "Sucess, user token has been inputed.")

    def parseToken(self, token):
    	if not token:
    		return None
        startString = token[1:len(token) - 1]
        endString = startString.replace(" ", "")
        return endString


app = webapp2.WSGIApplication([
    ('/', MainHandler),
    ('/apn/(\S*)', APNSHandler),
    ('/account/(\S*)', AccountHandler),
    ("/token", APNPhoneTokenHandler)
], debug=True)

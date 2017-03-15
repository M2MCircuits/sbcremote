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
			acc.name = data["name"]
			acc.email = data["email"]
			acc.serviceID = data["service_id"]
			acc.token = data["token"]
			acc.key = ndb.Key(Account, serviceID)
			acc.put()
			self.writeSucessfulResponse("data", "Account sucessfully created")
		except:
			self.writeErrorResponse("Account data not fully provided.")

app = webapp2.WSGIApplication([
    ('/', MainHandler),
    ('/apns/(\S*)', APNSHandler),
    ('/user/(\S*)', AccountHandler)
], debug=True)

import cgi
import os

class FormParser:

	def __init__(self, env, method):

		self.env = env
		self.method = method
		self.body = self.get_request_body()


	def get_request_body(self):

		body = None

		if self.method == 'GET':
			body = cgi.parse_qs(self.env['QUERY_STRING'])
		elif self.method == 'POST':
			request_body_size = int(self.env.get('CONTENT_LENGTH', 0))
			body = cgi.parse_qs(self.env['wsgi.input'].read(request_body_size))

		return body


	def getField(self, field):
		f = self.body.get(field, [''])[0]
		print field + ": " + f
		return f




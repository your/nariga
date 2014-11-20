import pymongo
import courseDAO
import sessionDAO
import userDAO
import formParser
import cgi
import os

##
POST_METHOD = 'GET';
##

connection_string = "mongodb://localhost"
connection = pymongo.MongoClient(connection_string)
database = connection.blog #for now only lets use blog

courses = courseDAO.CourseDAO(database)
users = userDAO.UserDAO(database)
sessions = sessionDAO.SessionDAO(database)

def login(form):

	nuser = form.getField('u')
	npass = form.getField('p')

	user_record = users.validate_login(nuser, npass)

	session_id = "-1"

	if user_record:
		session_id = sessions.start_session(user_record['_id'])

	return session_id  


def application(env, start_response):

	form = formParser.FormParser(env, POST_METHOD)
	what = form.getField('w')

	resp = False

	if what == '1':
		resp = login(form)

	start_response('200 OK', [('Content-Type','text/html'), ('Access-Control-Allow-Origin', '*')])

	# s = "True" if resp else "False"
	print("session_id: " + resp)

	return [str(resp)]
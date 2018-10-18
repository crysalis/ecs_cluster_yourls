from yourls import YOURLSClient
import random, string


def randomword(length):
   letters = string.ascii_lowercase
   rnd = ''.join(random.choice(letters) for i in range(length))
   return rnd


def short(url):
	yourls = YOURLSClient('test-yourls.com/yourls-api.php', signature='sdkjhkjfhg')
	return yourls.shorten('http://google.com/'+str(url))

for i in range(200):
	print str(i)+"\n"+str(short(randomword(6)))



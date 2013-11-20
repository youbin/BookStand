import re
import urllib
import urllib2
import requests
import sys
from bs4 import BeautifulSoup
from PIL import Image
from StringIO import StringIO

bookUrl = 'http://book.naver.com/search/search.nhn?sm=sta_hty.book&sug=&where=nexearch&query='

if len(sys.argv) == 2:
    number = sys.argv[1]
    
    if len(number) == 13:
      url = bookUrl + str(number)
      f = urllib.urlopen(url)
      html = f.read()

      soup = BeautifulSoup(html)

      category= soup.find("ul", attrs={'class':'list_sub field'}).find('li').find('span').find('a').get('title')

      print category
    else:
      print "InvalidArgument Error"
elif len(sys.argv) == 1:
    print "NoArgument Error"
else: 
    print "InvalidArgument Error"

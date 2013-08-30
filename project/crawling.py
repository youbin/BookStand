import re
import urllib
import requests
import sys
import time
from bs4 import BeautifulSoup

bookUrl = 'http://book.naver.com/bookdb/book_detail.nhn?bid='
bookNum = 7241060

file = open('isbnsleeptime.txt', 'rw+')
for i in range(2000):
  if i == 100:
    time.sleep(5)
  elif i == 500:
    time.sleep(5)
  elif i == 1000:
    time.sleep(5)
  elif i == 1500:
    time.sleep(5)

  url = bookUrl + str(bookNum)
  f = urllib.urlopen(url)
  html = f.read()

  soup = BeautifulSoup(html)
  isbn = re.findall('978[0-9]{10}', soup.text)
  if len(isbn) != 0:
    file.write(str(isbn[0])+ " \n")
    bookNum = bookNum + 1
    print "bookNum: " + str(bookNum) + " isbn: " + isbn[0]
  else:
    print "error len isbn"
    bookNum = bookNum + 1
file.close()

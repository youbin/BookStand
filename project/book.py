import re
import urllib
import requests
import sys
import time
from bs4 import BeautifulSoup

bookUrl = 'http://book.naver.com/search/search.nhn?sm=sta_hty.book&sug=&where=nexearch&query='

list = [i.strip().split()[0] for i in open("isbn.txt").readlines()]
print len(list)
i=0

for i in range(len(list)):
  if i == 100:
    time.sleep(5)
  elif i == 300:
    time.sleep(5)
  elif i == 500:
    time.sleep(5)

  if len(list[i]) == 13:
    url = bookUrl + list[i]
    f = urllib.urlopen(url)
    html = f.read()

    soup = BeautifulSoup(html)

    title = soup.find("ul", attrs={'class':'basic'}).find("dt").find("a")
    print (title.text)

    isbn = soup.find("dd", attrs={'class':'txt_block'}).find("strong")
    print (isbn.text)

    book = soup.find("dd", attrs={'class':'txt_block'}).findAll("a")
    author = book[0].text
    print author

    if len(book) == 2:
      translator = ""
      print translator
      publisher = book[1].text
      print publisher
    else:
      translator = book[1].text
      print translator
      publisher = book[2].text
      print publisher

      print (title.text)
      print (isbn.text)
      post_data = {'title':title.text, 'author':author, 'translator':translator, 'publisher':publisher, 'isbn': isbn.text}
      port_response = requests.post(url='http://14.63.185.160:3000/books/', data=post_data)
  else:
     print "InvalidArgument Error"

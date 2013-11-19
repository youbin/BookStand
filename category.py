from bs4 import BeautifulSoup
from PIL import Image
from StringIO import StringIO
import re
import urllib
import urllib2
import requests
import sys

list = [i.strip().split()[0] for i in open("isbn.txt").readlines()]


bookUrl = 'http://book.naver.com/search/search.nhn?sm=sta_hty.book&sug=&where=nexearch&query='

for j in list:
    number = j
    
    if len(number) == 13:
        url = bookUrl + str(number)
        f = urllib.urlopen(url)
        html = f.read()

        soup = BeautifulSoup(html)

        if(soup.find("ul", attrs={'class':'list_sub field'}) is None):
            print "isbn : "+ j
        else:
            category= soup.find("ul", attrs={'class':'list_sub field'}).find('li').find('span').find('a').get('title')
            print "isbn : "+ j + " category : " + category
    else:
        print "InvalidArgument Error"

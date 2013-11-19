import re
import urllib
import urllib2
import requests
import sys
from bs4 import BeautifulSoup
from PIL import Image
from StringIO import StringIO

bookUrl = 'http://book.naver.com/search/search.nhn?sm=sta_hty.book&sug=&where=nexearch&query='
newUrl = 'http://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords='
resize_width = 80
resize_height = 120

if len(sys.argv) == 2:
    number = sys.argv[1]
    
    if len(number) == 13:
      url = bookUrl + str(number)
      f = urllib.urlopen(url)
      html = f.read()

      soup = BeautifulSoup(html)

      if(soup.find("ul",attrs={'class':'basic'}) != None):
          title = soup.find("ul", attrs={'class':'basic'}).find("dt").find("a")
          book = soup.find("dd", attrs={'class':'txt_block'}).findAll("a")
          author = book[0].text

          imgUrl = soup.find("div", attrs={'class':'thumb_type'}).find("img")['src']

          if len(book) == 2:
              translator = ""
              publisher = book[1].text
          else:
              translator = book[1].text
              publisher = book[2].text
      else:
          url = newUrl + str(number)
          f = urllib.urlopen(url)
          html = f.read()

          soup = BeautifulSoup(html)
          title = soup.find("div", attrs={'class' : "productTitle"}).find("a").text
          imgUrl = soup.find("div", attrs={'class':'productImage'}).find("img")['src']
          if(soup.find("div", attrs={'class' : 'productTitle'}).find("span").find("a") != None):
              author = soup.find("div", attrs={'class' : 'productTitle'}).find("span").find("a").text
          else:
              author = soup.find("div", attrs={'class' : "productTitle"}).find("span").text[3:]
          translator = ""
          publisher = ""
      print title
      print imgUrl
      print author

      img = Image.open(StringIO(urllib2.urlopen(imgUrl).read()))

          # make Thumbnail
      thumb_img = img.resize((resize_width,resize_height), Image.ANTIALIAS)
          
          # save Image && Thumbnail
      folderUrl = int(number) / 10 % 10
      saveUrl = 'public/images/' + str(folderUrl) + '/' + number
      img.save(saveUrl + '.png')
      thumb_img.save(saveUrl + '_thumb.png')
    else:
      print "InvalidArgument Error"
elif len(sys.argv) == 1:
    print "NoArgument Error"
else: 
    print "InvalidArgument Error"

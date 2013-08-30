from bs4 import BeautifulSoup
from PIL import Image
from StringIO import StringIO
import urllib2
import sys

resize_width = 80
resize_height = 120

if len(sys.argv) == 2:
    isbn = sys.argv[1]
    if len(isbn) == 13:
        # get Image url
        startUrl = 'http://www.kyobobook.co.kr/product/detailViewKor.laf?ejkGb=KOR&mallGb=KOR&barcode='
        endUrl = '&orderClick=LAH&Kc='
        url = startUrl + isbn + endUrl

        # make Image from Image url
        soup = BeautifulSoup(urllib2.urlopen(url))
        imgUrl = soup.find('p', attrs={'class':'book_img_box'}).find('img')['src']
        img = Image.open(StringIO(urllib2.urlopen(imgUrl).read()))

        # make Thumbnail
        thumb_img = img.resize((resize_width,resize_height), Image.ANTIALIAS)
        
        # save Image && Thumbnail
        folderUrl = int(isbn) / 10 % 10
        saveUrl = 'public/images/' + str(folderUrl) + '/' + isbn
        img.save(saveUrl + '.png')
        thumb_img.save(saveUrl + '_thumb.png')

        print "test"
    else:
        print "InvalidArgument Error"
elif len(sys.argv) == 1:
    print "NoArgument Error"
else:
    print "InvalidArgument Error"

import os
import urllib.request
#from bs4 import BeautifulSoup as bs

def download_index(site):
    try:
        urllib.request.urlretrieve(site, "./proxy-list.html")
    except urllib.error.URLError as e:
        print("\nThere was an error: " + str(e))


if __name__ == '__main__':
    download_index("https://www.proxynova.com/proxy-server-list/")

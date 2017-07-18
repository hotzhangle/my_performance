import urllib.request
import requests
import urllib
import socket
import threading
import re, time, random

ip_total = []
for page in range(2, 6):
    # url='http://ip84.com/dlgn/'+str(page)
    url = 'http://www.xicidaili.com/wt/' + str(page)
    # headers = {"UserAgent": "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36"}
    headers={
        'Accept':'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language':'zh-CN,zh;q=0.8',
        'Cache-Control':'max-age=0',
        'Connection':'keep-alive',
        'Cookie':'_free_proxy_session=BAh7B0kiD3Nlc3Npb25faWQGOgZFVEkiJWIxYjAwZDkxMDE1NWRiYjAwMTBjZTFjZGY3YjJjMjE4BjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMXE5aGt6cDdPU2tyajI4RjB2dENmZS9aT0RMTDVTK1R2d1hTMDVjUGYxT0E9BjsARg%3D%3D--a913aa7825c13fec2fdfd583519c69b3345ab87b; CNZZDATA1256960793=284076470-1468134027-null%7C1468307148',
        'DNT':'1',
        'Host':'www.xicidaili.com',
        'User-Agent':'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.75 Safari/537.36'
        }
    # request = urllib.request.Request(url=url, headers=headers)
    r = requests.get(url,headers=headers)
    text =r.text
    # print('reqest OK.',type(request))
    # response = urllib.request.urlopen(url)
    print('response OK.',type(text))
    # content = request.read().decode('utf-8')
    print('get page ', page)
    pattern = re.compile('<td>(\d.*?)</td>')
    ip_page = re.findall(pattern=pattern, string=text)
    ip_total.extend(ip_page)
    time.sleep(random.choice(range(3, 5)))

print('代理IP地址     ', '\t', '端口', '\t', '速度', '\t', '验证时间')
for i in range(0, len(ip_total), 4):
    print(ip_total[i], '\t', ip_total[i + 1], '\t', ip_total[i + 2], '\t', ip_total[i + 3])

proxys = []
for i in range(0, len(ip_total), 4):
    proxy_host = ip_total[i] + ":" + ip_total[i + 1]
    proxy_temp = {'http': proxy_host}
    proxys.append(proxy_temp)

proxy_ip = open('proxy_ip.txt', 'w')
lock = threading.Lock()

def test(i):
    socket.setdefaulttimeout(5)
    url = 'http://quote.stockstar.com/stock'
    try:
        proxy_support = urllib.request.ProxyHandler(proxys[i])
        opener = urllib.request.build_opener(proxy_support)
        opener.addheaders = [("User-Agent", "Mozilla/5.0 (Windows NT 10.0; WOW64)")]
        urllib.request.install_opener(opener)
        res = urllib.request.urlopen(url).read()
        lock.acquire()
        print(proxys[i], 'is OK')
        proxy_ip.write('%s\n ' % (str(proxys[i])))
        lock.release()
    except Exception as e:
        lock.acquire()
        print(proxys[i], e)
        lock.release()


# for i in range(len(proxys)):
#         test(i)

threads = []
for i in range(len(proxys)):
    thread = threading.Thread(target=test(i), args=[i])
    threads.append(thread)
    thread.start()

for thread in threads:
    thread.join()

proxy_ip.close()

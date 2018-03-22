# -*-coding:utf-8 -*-
import requests
from urllib import request
import re
import random
from bs4 import BeautifulSoup
from fake_useragent import UserAgent
import pandas  #pandas大法好

ua = UserAgent()  # 使用随机header，模拟人类
headers1={}
# headers1 ['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) Chrome/59.0.3071.115 AppleWebKit/537.36 (KHTML, like Gecko) Safari/537.36'
headers1 = {'User-Agent': 'ua.random'}  # 使用随机header，模拟人类
houseary = []  # 建立空列表放房屋信息

def runRandomIp(tag,index):
    ip = 'http://101.245.173.240:8080'
    httpIpList = ['119.36.92.41:80', '118.178.124.33:3128', '180.106.37.111:8118', '171.38.16.172:8123',
                  '139.215.214.61:8080', \
                  '111.155.116.202:8123', '222.52.142.242:8080', '111.155.116.200:8123', '171.38.94.21:8123',
                  '113.200.214.164:9999', \
                  '112.85.75.240:808', '175.44.46.79:53281', '110.73.36.17:8183', '125.89.126.252:808',
                  '121.61.17.36:8118', \
                  '182.38.97.80:808', '175.153.22.76:808', '222.85.50.5:808', '42.157.7.43:9999', '171.13.36.72:808','114.239.146.170:808']
    ipDict = {'http': httpIpList[random.randint(0, 19)]}
    ip = ipDict.get('http')
    print("tag = %s,ip = %s,index = %s" % (tag,ip,index))
    proxy_support = request.ProxyHandler(ipDict)
    # proxy_support = request.ProxyHandler({'http':'110.73.11.64:8123'})
    opener = request.build_opener(proxy_support)
    request.install_opener(opener)

def exitApplication(exit_code,exitString="服务器未返回数据，退出..."):
    print(exitString+"\t"+str(exit_code))
    exit(res.status_code)

def singleHouseInfo(url):
    singleRes = requests.get(url, headers=headers1)
    singleSoup = BeautifulSoup(singleRes.text, 'html.parser')
    return singleSoup

def getHouseDetail(soup, j):
    info = {}  # 构造字典，作为之后的返回内容
    if soup is None:
        exitApplication(404)
    try:
        # ========================================================================
        communityName = soup.select('.communityName a[class="info"]')[0].get_text()
        info['小区名称'] = communityName
        # ========================================================================
        pat1 = '<span.*?>(.*?)</span>'
        areaName = soup.select('.areaName span[class="info"]')[0].get_text().strip()
        info['具体地点'] = areaName
        # ========================================================================
        totalPrice = soup.select('.price span[class="total"]')[0].get_text().strip()
        unitPriceValue = soup.select('.price span[class="unitPriceValue"]')[0].get_text().strip()
        taxtext = soup.select('.price span[class="taxtext"]')[0].get_text().strip()
        info['房屋总价'] = totalPrice
        info['单价'] = unitPriceValue
        info['税费金额'] = taxtext
        # ========================================================================
        for dd in soup.select('.introContent span[class="label"]'):
            # print('type = %s' % (type(dd)))
            # print('dd = ' + str(dd))
            # print('name =' + str(dd.name))
            # print('attr = ' + str(dd.attrs))
            # print('previous_element\'s type is %s' % (type(dd.previous_element)))
            # print('previous_element\'s content is %s' % str(dd.previous_element))
            # print('text = ' + dd.string) # "liContent = " +
            # print('previous_element\'s value is %s' % str(dd.previous_element.text).partition(dd.string)[2])
            # ========================================================================
            key = dd.string
            value = str(dd.previous_element.text).partition(dd.string)[2]
            info[key] = value
            # print("key = %s\nvalue = %s\n" % (key,value))
        print('---------------EOF%s----------------' % (j))
    except Exception as e:
        print("error occur: " , e,dd)
        print("info = %s\n" % (info))
    return info

runRandomIp('tag1',20)
for i in range(1, 5):  # 爬取399页，想爬多少页直接修改替换掉400，不要超过总页数就好
    res = requests.get('https://wh.lianjia.com/ershoufang/pg' + str(i), headers=headers1)  # 爬取拼接域名
    if res.status_code != 200:
        exitApplication(res.status_code)
    soup = BeautifulSoup(res.text, 'html.parser')  # 使用html筛选器
    for j in range(0, 30):  # 网站每页呈现30条数据，循环爬取
        try:
            list = soup.select('.bigImgList a[class="title"]')
            url1 = list[j]['href']  # 选中class=bigImgList下的a标签里class=title的第j个元素的href子域名内容
        except Exception:
            if len(list) == 0:
                print(soup)
                exitApplication(400)
        # print(url1+ "--->"+str(j))
        singleHouseInfo(url1)
        # runRandomIp('tag2',j)
        houseary.append(getHouseDetail(singleHouseInfo(url1), j))  # 传入自编函数需要的参数
# print (str(houseary))

df=pandas.DataFrame(houseary)
df.to_excel('./house_lianjia.xlsx')
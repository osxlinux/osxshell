#!/usr/bin/env python
#coding:utf8
#auth:xingdd
#email:osx1260@163.com
import os
import time
import datetime
import sys
import xlsxwriter

# set date 
#TodyTime = datetime.date.today()
#Set_date = str(datetime.datetime.strptime(str(TodyTime),'%Y-%m-%d'))
#date_set = Set_date.strip('00:00:00').strip()
localt = time.localtime()
ISOFORMAT='%Y-%m-%d %H:%M:%S'
FILEFORMAT='%Y-%m-%d-%H-%M'
date_set = time.strftime(ISOFORMAT,localt)
file_set = time.strftime(FILEFORMAT,localt)
# Excel bulid 
Load_Info = xlsxwriter.Workbook(file_set + '-loadarg.xlsx')
worksheet = Load_Info.add_worksheet()

# Base information

Re_Peo = {'A2':'','B2':u'报告人:','C2':u'Yourname','D2':u'报告周期:','E2':date_set,'F2':'','G2':'','H2':'','I2':'','J2':''}
Infor_List = {'A3':u'系统名称','B3':u'系统CPU平均使用值','C3':u'系统CPU高峰时使用情况','D3':u'内存使用情况','E3':u'存储空间使用状况','F3':u'后续建议','G3':u'用户数','H3':u'平均在线人数','I3':u'业务数据量情况','J3':u'业务数据量情况'}

#define A3 Format
def Format():
    format = Load_Info.add_format({'bold':False,'num_format':'yyy-mm-dd'})
    format.set_border(2)    # 加粗边框
    format.set_bg_color('#006633') # 单元格颜色
    format.set_align('center') # 字体居中
    format.set_bold(0.5) #字体加粗
    format.set_font_color('#FFFFFF')#字体颜色
    return format

#Define A2 Format 
def Form():
    form = Load_Info.add_format({'bold':True,'num_format':'yyy-mm-dd'})
    form.set_border(1)    # 加粗边框
    form.set_align('center') # 字体居中
    form.set_bold(0.5) #字体加粗
    form.set_font_color('#000000')#字体颜色
    return form

# Write data and build last Excel file
def Loop_write_title():
    for tname in xrange(10):
        RandomAZ = chr(tname+ord('A')) + '3'
        RandomBZ = chr(tname+ord('A')) + '2'
        RandomInfor = Infor_List[RandomAZ]
        RandomInfo = Re_Peo[RandomBZ]
        worksheet.set_column(RandomAZ + ':' + RandomAZ, 23)
        worksheet.write(RandomAZ, RandomInfor, Format())
        worksheet.write(RandomBZ, RandomInfo, Form())


Loop_write_title()
Load_Info.close()

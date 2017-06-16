#!/usr/bin/python
# -*- coding: utf-8 -*-
# Author: liuzhaoci
# Data: 2017/4/17

import os


files_list = []
DEBUG = False

def gci(filepath):
#遍历filepath下所有文件，包括子目录
    files = os.listdir(filepath)
    for fi in files:
        fi_d = os.path.join(filepath, fi)
        if os.path.isdir(fi_d):
            gci(fi_d)
        else:
            [uuid, ext_type_name] = os.path.splitext(fi_d)
            if ext_type_name == '.wav':
                #full_file_path =  os.path.join(filepath, fi_d)
                if DEBUG: print fi_d#full_file_path
                files_list.append(fi_d)

def main(configFileName):
    '''main'''
    files_dir = "/home/lzc/aslp/task2/zhaoci/raw_data"

    f = open(configFileName, 'w')

    print("output file name:%s\n"%(configFileName))

    print("search files...\n")
    gci(files_dir) #get files_list
    #files_list = sorted(files_list)
    print("\ngenerate file list...\n")

    for curfile in files_list:
        #curfile = files_list[i]
        [uuid, ext_type_name] = os.path.splitext(curfile)
        #print(ext_type_name == '.wav')
        if ext_type_name == '.wav':
            out_str = uuid[len(files_dir)+1: ] #cut the work dir prefix
            out_str = "%s\n" % (out_str)
            if DEBUG: print(out_str)
            f.write(out_str)
        else:
            continue
    f.close()

main('test.scp')






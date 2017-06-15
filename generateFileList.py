#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author: liuzhaoci
# Data: 2017/4/17
"""生成一个文件放在config目录下，名子为all.list
每行为uuid input_filename label_filename
供convert_to_records使用

建议之后用shuf命令打乱集合，手工分成
train.list，val.list, test.list
建议三个集合只用list区分，放在同一个文件夹下
"""

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import argparse
import os

def main(configFileName, start_index, end_index):
    #configFileName = FLAGS.config_dir_name
    input_files_dir = "data/mfc2csv/"
    lab_files_dir = "data/output_csv/"
    # lab2_files_dir = "data/N_facial_expression/"
    f = open(configFileName,'w')
    print("generate file list...\n")
    print("file name:%s\n"%(configFileName))

    list = os.listdir(input_files_dir)
    list = sorted(list)
    print("files count:%d\n"%len(list))
    if end_index == -1:
        end_index = len(list)
    print("Select: [%d, %d)\n"%(start_index, end_index))
    for i in range(start_index, end_index):
        curfile = list[i]
        # TODO: remove hard code
        uuid = curfile[0:5]
        lab_file_path = '%s%s.csv'%(lab_files_dir, uuid)
        #lab2_file_path = '%sN%s_expression.csv'%(lab2_files_dir, uuid)
        if not os.path.isfile(lab_file_path):
            print("file %s not exits!"%lab_file_path)
            continue
        '''if not os.path.isfile(lab2_file_path):
            print("file %s not exits!"%lab2_file_path)
            continue
        '''
        #[uuid, ext_type_name] = os.path.splitext(curfile)
        #line = "%s %s %s %s\n" % (uuid, input_files_dir+curfile, lab_file_path, lab2_file_path)
        line = "%s %s %s\n" % (uuid, input_files_dir+curfile, lab_file_path)
        f.write(line)
    f.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--config_file_name',
        type=str,
        default='./config.list',
        help='Directory and name to put lists'
    )
    parser.add_argument(
        '--start_index',
        type=str,
        default=0,
        help='start_index'
    )
    parser.add_argument(
        '--end_index',
        type=str,
        default=-1,
        help='end_index'
    )
    FLAGS, unparsed = parser.parse_known_args()
    main(FLAGS.config_file_name,int(FLAGS.start_index),int(FLAGS.end_index))



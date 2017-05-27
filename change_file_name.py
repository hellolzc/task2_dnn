# Author : liuzhaoci
# Data : 2017/5/26

import os

files_dir = "N_facial_expression/"

filelist = os.listdir(files_dir)
filelist = sorted(filelist)
for full_filename in filelist:
    [filename, ext] = os.path.splitext(full_filename)
    if ext != '.csv':
        print full_filename + ': warning '+ext
        continue
    [c1,c2,c3] = filename.split('_')
    uuid = int(c2) - 10 + int(c3)
    old_file_path = os.path.join(files_dir, full_filename)
    new_file_path = os.path.join(files_dir, 'N%04d_expression.csv'%(uuid))
    print 'rename: %s -> %s'%(old_file_path, new_file_path)
    os.rename(old_file_path, new_file_path)


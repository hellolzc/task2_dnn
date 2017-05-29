# Author: liuzhaoci
# Data: 2017/4/17

import argparse
import os

def main(configFileName,start_index,end_index):
    #configFileName = FLAGS.config_dir_name
    input_files_dir = "data/onehot_feature_merged/"
    lab_files_dir = "data/N_wav_mfc2csv/"
    lab2_files_dir = "data/N_facial_expression/"
    f = open(configFileName,'w')
    print("generate file list...\n")
    print("file name:%s\n"%(configFileName))

    list = os.listdir(input_files_dir)
    list = sorted(list)
    print("files count:%d\n"%len(list))
    print("%d-%d\n"%(start_index,end_index))
    for i in range(start_index,end_index):
        curfile = list[i]
        uuid = curfile[8:12]
        lab_file_path = '%sN%s_wav.csv'%(lab_files_dir, uuid)
        lab2_file_path = '%sN%s_expression.csv'%(lab2_files_dir, uuid)
        if not os.path.isfile(lab_file_path):
            print "file %s not exits!"%lab_file_path
            continue
        if not os.path.isfile(lab2_file_path):
            print "file %s not exits!"%lab2_file_path
            continue
        #[uuid, ext_type_name] = os.path.splitext(curfile)
        str = "%s %s %s %s\n" % (uuid, input_files_dir+curfile, lab_file_path, lab2_file_path)
        f.write(str)
    f.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--config_file_name',
        type=str,
        default='config.list',
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
        default=100,
        help='end_index'
    )
    FLAGS, unparsed = parser.parse_known_args()
    main(FLAGS.config_file_name,int(FLAGS.start_index),int(FLAGS.end_index))



# Author: liuzhaoci
# Data: 2017/4/17

import argparse
import os

def main(configFileName,start_index,end_index):
    #configFileName = FLAGS.config_dir_name
    cmp_files_dir = "./N_text/"
    lab_files_dir = "./N_mfc2csv/"
    lab2_files_dir = "./N_facial_expression/"
    f = open(configFileName,'w')
    print("generate file list...\n")
    print("file name:%s\n"%(configFileName))

    list = os.listdir(cmp_files_dir)
    list = sorted(list)
    print("files count:%d\n"%len(list))
    print("%d-%d\n"%(start_index,end_index))
    for i in range(start_index,end_index):
        curfile = list[i]
        uuid = curfile[8:12]
        #[uuid, ext_type_name] = os.path.splitext(curfile)
        str = "%s %sarctic_b%s.lab %sN%s_wav.csv %sN%s_expression.csv\n" % (uuid, cmp_files_dir, uuid, lab_files_dir, uuid, lab2_files_dir, uuid)
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
        default=1000,
        help='end_index'
    )
    FLAGS, unparsed = parser.parse_known_args()
    main(FLAGS.config_file_name,int(FLAGS.start_index),int(FLAGS.end_index))



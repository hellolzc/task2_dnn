import numpy as np
import tensorflow as tf
#import tools.io_funcs.kaldi_io as kio
#from tools.io_funcs import feats_trans
import random
import models.feed_forward as ff
import os, sys, argparse, datetime
#import convert_to_records as c_t_r

def process_file_list(file_list):
    fid = open(file_list,'r')
    proc_file_list=[]
    lines = fid.readlines()
    for line in lines:
        proc_file_list.append(line.rstrip('\n'))
    return proc_file_list, len(lines)

def read_and_decode(filename, input_dim, label_dim, num_epochs):
    filename_queue = tf.train.string_input_producer(filename,shuffle=False, num_epochs=num_epochs)
    reader = tf.TFRecordReader()
    _, serialized_example = reader.read(filename_queue)
    _,features = tf.parse_single_sequence_example(serialized_example,
        sequence_features={
            'inputs':tf.FixedLenSequenceFeature([input_dim],tf.float32),
            'labels':tf.FixedLenSequenceFeature([label_dim], tf.float32)})
    return features['inputs'], features['labels']

def splice_feats(feats, l, r):
    sfeats = []
    row = tf.shape(feats)[0]
    for i in range(l, 0, -1):
        f1 = tf.slice(feats, [0, 0], [row-i, -1])
        for j in range(i):
            f1 = tf.pad(f1, [[1,0],[0,0]],mode='SYMMETRIC')
        sfeats.append(f1)

    sfeats.append(feats)
    for i in range(1,r+1):
        f1 = tf.slice(feats, [i, 0], [-1, -1])
        for j in range(i):
            f1 = tf.pad(f1, [[0,1],[0,0]],mode='SYMMETRIC')
        sfeats.append(f1)
    return tf.concat(sfeats, 1)

def write_output_to_csv(feature, uttid, data_dir):
    output_filename = data_dir + '/' + uttid + '_out' + '.csv'
    # output = open(output_filename, 'w')
    np.savetxt(output_filename, feature, delimiter=',', fmt='%.6f')

def verse_pca(data):
    pca = np.load(os.path.join('./tfrecords', "train_pca.npz"))
    original_data = np.dot(data, pca['pca_components']) + pca['pca_mean']
    return original_data

def reconstruct_expression(expression_30d, do_pca_flag=True):
    """30d->309d->310d"""
    # mutiply var and add mean
    cmvn = np.load(os.path.join('./tfrecords', "train_cmvn.npz"))
    #minivalue_in = np.ones(cmvn["stddev_inputs"].shape,
    #                       dtype=np.float64) * 1e-7
    minivalue_lab = np.ones(cmvn["stddev_labels"].shape,
                            dtype=np.float64) * 1e-7
    #print(cmvn["stddev_inputs"])
    #inputs = (inputs - cmvn["mean_inputs"]) /(
    #    cmvn["stddev_inputs"]+minivalue_in)
    expression_30d = expression_30d * (cmvn["stddev_labels"]+minivalue_lab) \
             + cmvn["mean_labels"]
    # verse PCA
    if do_pca_flag:
        output_309d = verse_pca(expression_30d)
    else:
        output_309d = expression_30d

    # add line number
    length = len(output_309d)
    tag = np.arange(0, length, 1)
    output_310d = np.column_stack([tag, output_309d])
    return output_310d

def test(sess, coord, dnn, sfeats, file_list, data_dir):

    count = 0
    try:
        while not coord.should_stop():
            x = sess.run(sfeats)
            output = dnn.get_output(x)#numpy array
            tffilename = file_list[count]
            (_, name) = os.path.split(tffilename)
            (uttid, _) = os.path.splitext(name)

            #kaldi_writer = kio.ArkWriter(data_dir+'/' + uttid + '.scp')
            #kaldi_writer.write_next_utt(data_dir+'/' + uttid + '.ark', uttid, output)
            output = reconstruct_expression(output)
            write_output_to_csv(output, uttid, data_dir)
            count += 1
            if count%5 == 0:
                print "Processing ", count, "utterances \n"
    except tf.errors.OutOfRangeError:
        return
    finally:
        coord.request_stop()
        #kaldi_writer.close()



def main(_):

    data_dir = FLAGS.data_dir
    if not os.path.exists(data_dir):
        os.makedirs(data_dir)


    l = FLAGS.left_context
    r = FLAGS.right_context
    input_dim = FLAGS.input_dim
    output_dim = FLAGS.output_dim
    num_layers = FLAGS.num_layers
    num_units = FLAGS.num_units
    output_layer = FLAGS.output_layer
    active_func = FLAGS.active_func
    test_list, len_test = process_file_list(FLAGS.test_list)
    load_model = FLAGS.load_model
    sess = tf.Session()
    dnn = ff.FeedForward(input_dim*(l+r+1), output_dim, num_layers, [num_units],
                         active_func, output_layer='linear')
    dnn.new_session(sess)
    saver = tf.train.Saver()
    if load_model != '':
        saver.restore(dnn.sess, load_model)

    coord = tf.train.Coordinator()
    feats, labels = read_and_decode(test_list, input_dim, output_dim, 1)
    sess.run(tf.local_variables_initializer())
    sfeats = splice_feats(feats, l, r)
    thread = tf.train.start_queue_runners(sess=sess, coord=coord)

    test(sess, coord, dnn, sfeats, test_list, data_dir)

if __name__ == "__main__":
    tf.logging.set_verbosity(tf.logging.INFO)
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--input_dim',
        default = 39,#257,
        type=int,
        help = 'Input feature dim with out context windows len.')
    parser.add_argument(
        '--output_dim',
        default = 30,#257,
        type=int,
        help = 'Output feature dim with out context windows len.')
    parser.add_argument(
        '--left_context',
        default = 2,
        type= int,
        help = 'Left context lengh for slicing feature')
    parser.add_argument(
        '--right_context',
        default = 2,
        type= int,
        help = 'Right context lengh for slicing feature')
    parser.add_argument(
        '--num_layers',
        default=2,#3,
        type=int,
        help = 'Number of hidden layers.')
    parser.add_argument(
        '--num_units',
        default=128,#1024,
        type=int,
        help='Number of nuros in every layer')
    parser.add_argument(
        '--test_list',
        default='tfrecords/test_tf.list',
        type=str,
        help='Test feature and label tf list.')
    parser.add_argument(
        '--data_dir',
        type= str,
        default='test_output',#'data/test',
        help = 'Directory to put the network output')
    parser.add_argument(
        '--load_model',
        type=str,
        default='',
        help = 'The model name we need to load, default is \'\'')
    parser.add_argument(
        '--keep_prob',
        type=float,
        default=1,#0.8,
        help = 'Kepp probability for training dropout')
    parser.add_argument(
        '--output_layer',
        default = 'linear',
        type=str,
        help= 'The output layer type, softmox or linear')
    parser.add_argument(
        '--active_func',
        default=tf.nn.sigmoid,#'tf.nn.relu',
        type=str,
        help = 'The active function of hidden layers')
    FLAGS,unparsed = parser.parse_known_args()
    sys.stdout.flush()
    tf.app.run(main=main, argv=[sys.argv[0]] + unparsed)



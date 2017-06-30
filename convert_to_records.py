#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright 2016 ASLP@NPU.  All rights reserved.
# Author: npuichigo@gmail.com (zhangyuchao)
# Modified: lzc80234@qq.com (liuzhaoci) 20170417
"""Converts data to TFRecords file format with Example protos.
三个文件放在config目录下，名子为train.list，val.list, test.list
每行为uuid input_filename label_filename
转成的tfrecords放output_dir下
建议三个集合只用list区分，放在同一个文件夹下
"""
from __future__ import absolute_import
#from __future__ import division
from __future__ import print_function

import argparse
import os
import struct
import sys
import multiprocessing

import numpy as np
import tensorflow as tf
from sklearn.decomposition import PCA
#print(sys.path[0])

#sys.path.append(os.path.dirname(sys.path[0]))
from tfrecords_io import make_sequence_example

tf.logging.set_verbosity(tf.logging.INFO)

pca_global = PCA(n_components=30)
is_fited = False

def fit_pca(data):
    newData = pca_global.fit_transform(data)
    is_fited = True
    print("set n_components:", newData.shape[1])
    print("variance remained:", sum(pca_global.explained_variance_ratio_))

    pca_components = pca_global.components_
    pca_mean = pca_global.mean_
    pca_file_name = os.path.join(FLAGS.output_dir, "train_pca.npz")
    np.savez(pca_file_name,
             pca_components=pca_components,
             pca_mean=pca_mean)
    tf.logging.info("Wrote to %s" % pca_file_name)
    return newData

def do_pca(data):
    if is_fited:
        return pca_global.transform(data)

    pca = np.load(os.path.join(FLAGS.output_dir, "train_pca.npz"))
    data = data - pca['pca_mean']
    data_transformed = np.dot(data, pca['pca_components'].T)
    return data_transformed

def verse_pca(data):
    pca = np.load(os.path.join(FLAGS.output_dir, "train_pca.npz"))
    original_data = np.dot(data, pca['pca_components']) + pca['pca_mean']
    return original_data

def apply_pca(name):
    """apply pca."""
    tf.logging.info("Apply dimensionality reduction to %s" % name)
    config_filename = open(os.path.join(FLAGS.config_dir, name + '.list'))

    frame_count = 0
    for line in config_filename:
        utt_id, inputs_path, labels_path = line.strip().split()
        #utt_id, inputs_path, labels1_path, labels2_path = line.strip().split()
        tf.logging.info("Reading utterance %s" % utt_id)

        inputs, labels = load_a_sample(inputs_path, labels_path, do_pca_flag=False)
        if inputs is None:
            continue
        if frame_count == 0:    # create numpy array for accumulating
            big_matrix = labels
        else:
            big_matrix = np.row_stack((big_matrix, labels))
        frame_count += len(inputs)
    #fit PCA
    #np.savetxt('./debug_bigmatrix.txt', big_matrix, delimiter=',', fmt='%.6f')
    fit_pca(big_matrix)
    config_filename.close()


def calculate_cmvn(name, apply_pca=False):
    """Calculate mean and var."""
    tf.logging.info("Calculating mean and var of %s" % name)
    config_filename = open(os.path.join(FLAGS.config_dir, name + '.list'))

    frame_count = 0
    for line in config_filename:
        utt_id, inputs_path, labels_path = line.strip().split()
        #utt_id, inputs_path, labels1_path, labels2_path = line.strip().split()
        tf.logging.info("Reading utterance %s" % utt_id)

        inputs, labels = load_a_sample(inputs_path, labels_path, do_pca_flag=apply_pca)
        if inputs is None:
            continue

        if frame_count == 0:    # create numpy array for accumulating
            ex_inputs = np.sum(inputs, axis=0)
            ex2_inputs = np.sum(inputs**2, axis=0)
            ex_labels = np.sum(labels, axis=0)
            ex2_labels = np.sum(labels**2, axis=0)

        else:
            ex_inputs += np.sum(inputs, axis=0)
            ex2_inputs += np.sum(inputs**2, axis=0)
            ex_labels += np.sum(labels, axis=0)
            ex2_labels += np.sum(labels**2, axis=0)

        frame_count += len(inputs)

    mean_inputs = ex_inputs / frame_count
    stddev_inputs = np.sqrt(ex2_inputs / frame_count - mean_inputs**2)

    mean_labels = ex_labels / frame_count
    stddev_labels = np.sqrt(ex2_labels / frame_count - mean_labels**2)

    cmvn_name = os.path.join(FLAGS.output_dir, name + "_cmvn.npz")
    #save several arrays into a single file in uncompressed ``.npz`` format.
    np.savez(cmvn_name,
             mean_inputs=mean_inputs,
             stddev_inputs=stddev_inputs,
             mean_labels=mean_labels,
             stddev_labels=stddev_labels)
    config_filename.close()
    tf.logging.info("Wrote to %s" % cmvn_name)


def read_binary_file(filename):
    """Read data from matlab binary file (row, col and matrix).

    Returns:
        A numpy matrix containing data of the given binary file.
    """
    read_buffer = open(filename, 'rb')

    rows = 0; cols= 0
    rows = struct.unpack('<i', read_buffer.read(4))[0]
    cols = struct.unpack('<i', read_buffer.read(4))[0]

    tmp_mat = np.frombuffer(read_buffer.read(rows * cols * 4), dtype=np.float32)
    mat = np.reshape(tmp_mat, (rows, cols))

    read_buffer.close()

    return mat

def load_binary_file(file_name,dimension=501):
    '''read a text lab file provided by yangshan'''
    fid_lab = open(file_name, 'rb')
    features = np.fromfile(fid_lab, dtype=np.float32)
    fid_lab.close()
    assert features.size % float(dimension) == 0.0,\
        'specified dimension %s not compatible with data'%(dimension)
    features = features[:(dimension * (features.size / dimension))]
    features = features.reshape((-1, dimension))
    return features

def load_csv_file(file_name):
    '''read data from csv return numpyarray'''
    my_matrix = np.loadtxt(file_name,delimiter=',',skiprows=0)
    return my_matrix

def load_csv_file_upsample(file_name):
    '''read data from csv return numpyarray the double the sample rate'''
    my_matrix = np.loadtxt(file_name,delimiter=',',skiprows=0)

    rows = my_matrix.shape[0] * 2 - 1
    upsample_matrix = []
    for row in range(0,rows):
        if row % 2 == 0:
             upsample_matrix.append(my_matrix[row/2,:].tolist())
        else:
             upsample_temp = (my_matrix[(row-1)/2] + my_matrix[(row+1)/2]) / 2
             upsample_matrix.append(upsample_temp.tolist())
    return np.array(upsample_matrix)

def load_a_sample(inputs_path, labels2_path, do_pca_flag=False):
    '''read three file and concatenate two output,
     make sure lens are the same,
     return numpy or return None if false
     inputs_path: text features
     labels1: wav mfcc
     labels2: expression data
    '''
    inputs = load_csv_file(inputs_path).astype(np.float64)
    #inputs = inputs[0:-1:2]  # Downsized sample
    # concatenate two output
    #labels1 = load_csv_file(labels1_path).astype(np.float64)
    #labels2 = load_csv_file_upsample(labels2_path).astype(np.float64)
    labels2 = load_csv_file(labels2_path).astype(np.float64)
    '''
    if not len(labels1) - len(labels2) < 5:
        print("dim not compatible: %s:%d - %d"%(utt_id, len(labels1), len(labels2)))
        return None
    '''
    if not len(inputs) - len(labels2) < 5:
        print("len not compatible: %s:%d - %d"%(inputs_path, len(inputs), len(labels2)))
        return (None, None)

    # make sure lens are the same
    #min_len = min(len(labels1), len(labels2), len(inputs))
    min_len = min(len(labels2), len(inputs))
    inputs = inputs[0:min_len]
    #labels1 = labels1[0:min_len]
    labels2 = labels2[0:min_len]
    labels2 = labels2[:, 1:] # delete first column
    labels = labels2 #np.column_stack((labels1, labels2))
    # DO PCA
    # np.savetxt('./debug_a_sample.txt', labels, delimiter=',', fmt='%.6f')
    if do_pca_flag:
        labels = do_pca(labels)
    return (inputs, labels)

def convert_to(name, apply_cmvn=True,  apply_pca=False):
    """Converts a dataset to tfrecords."""
    cmvn = np.load(os.path.join(FLAGS.output_dir, "train_cmvn.npz"))
    config_file = open(os.path.join(FLAGS.config_dir, name + ".list"))
    for line in config_file:
        utt_id, inputs_path, labels_path = line.strip().split()
        #utt_id, inputs_path, labels1_path, labels2_path = line.strip().split()
        tfrecords_name = os.path.join(FLAGS.output_dir, name,
                                      utt_id + ".tfrecords")
        with tf.python_io.TFRecordWriter(tfrecords_name) as writer:
            tf.logging.info(
                "Writing utterance %s to %s" % (utt_id, tfrecords_name))

            #labels = read_binary_file(labels_path).astype(np.float64)
            # concatenate two output
            inputs, labels = load_a_sample(inputs_path, labels_path, do_pca_flag=apply_pca)
            if inputs is not None:
                if apply_cmvn:
                    #print(cmvn["stddev_inputs"].dtype)
                    minivalue_in = np.ones( cmvn["stddev_inputs"].shape,
                                        dtype=np.float64) * 1e-7
                    minivalue_lab = np.ones( cmvn["stddev_labels"].shape,
                                        dtype=np.float64) * 1e-7
                    #print(cmvn["stddev_inputs"])
                    inputs = (inputs - cmvn["mean_inputs"]) /(
                        cmvn["stddev_inputs"]+minivalue_in)
                    labels = (labels - cmvn["mean_labels"]) /(
                        cmvn["stddev_labels"]+minivalue_lab)
                ex = make_sequence_example(inputs, labels)
                writer.write(ex.SerializeToString())
        if os.path.getsize(tfrecords_name) < 10: #filesize < 10byte
            os.remove(tfrecords_name)
    config_file.close()


def main(unused_argv):
    # Convert to Examples and write the result to TFRecords.
    DO_PCA = False
    if DO_PCA:
        apply_pca("train")
    calculate_cmvn("train", apply_pca=DO_PCA)    # use training data to calculate mean and var

    convert_to("train", apply_cmvn=True, apply_pca=DO_PCA)
    convert_to("val", apply_cmvn=True, apply_pca=DO_PCA)#val mean validation
    convert_to("test", apply_cmvn=True, apply_pca=DO_PCA)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--output_dir',
        type=str,
        default='./tfrecords',
        help='Directory to write the converted result'
    )
    parser.add_argument(
        '--config_dir',
        type=str,
        default='config',
        help='Directory to load train, val and test lists'
    )
    FLAGS, unparsed = parser.parse_known_args()
    tf.app.run(main=main, argv=[sys.argv[0]] + unparsed)


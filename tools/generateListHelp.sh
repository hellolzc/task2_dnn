python generateFileList.py
shuf config.list | shuf > config/all.txt

head -130 all.txt > train.list
head -160 all.txt | tail -30 > val.list 
head -190 all.txt | tail -30 > test.list 

find ./tfrecords/train/ -name '*.tfrecords' | shuf > ./tfrecords/train_tf.list
find ./tfrecords/val/ -name '*.tfrecords' | shuf > ./tfrecords/val_tf.list
find ./tfrecords/test/ -name '*.tfrecords' | shuf > ./tfrecords/test_tf.list
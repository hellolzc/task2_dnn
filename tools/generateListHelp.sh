python generateFileList.py
shuf config.list  > config/all.txt

cd config
head -110 all.txt > train.list
head -125 all.txt | tail -15 > val.list 
head -140 all.txt | tail -15 > test.list 

cd ..
rm ./tfrecords/train/*
rm ./tfrecords/val/*
rm ./tfrecords/test/*
rm ./test_output/*
python convert_to_records.py
find ./tfrecords/train/ -name '*.tfrecords' | shuf > ./tfrecords/train_tf.list
find ./tfrecords/val/ -name '*.tfrecords' | shuf > ./tfrecords/val_tf.list
find ./tfrecords/test/ -name '*.tfrecords' | shuf > ./tfrecords/test_tf.list


ffmpeg -i video.mp4 -i audio.wav -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 output.mp4

ffmpeg -i N0017_0.avi -i ../NewDataArranged/aligened_netural/output_wav/N0017_mono.wav -c:v copy -c:a copy -map 0:v:0 -map 1:a:0 N0017_0_output.mp4
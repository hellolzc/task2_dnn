#!/bin/bash

stage=0
config_dir=config/
output_dir=data/tfrecords
num_layers=4
num_units=256
out_left_context=0
out_right_context=0
in_left_context=2
in_right_context=2
keep_prob=1
apply_cmvn=1
output_dim=309

save_dir=exp_wsj0_sp_pit
if [ ! -d $config_dir ]; then
  mkdir $config_dir
fi

if [ $stage -le 0 ]; then
  echo "stage=$stage, conver the csv data to TFRecord."
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
fi

if [ $stage -le 1 ]; then
  echo "stage=$stage, generate the tfrecord file lists and store them"
  find ./tfrecords/train/ -name '*.tfrecords' | shuf > ./tfrecords/train_tf.list
  find ./tfrecords/val/ -name '*.tfrecords' | shuf > ./tfrecords/val_tf.list
  find ./tfrecords/test/ -name '*.tfrecords' | shuf > ./tfrecords/test_tf.list
fi

if [ $stage -le 2 ]; then
  echo "state=$stage, begin training the model"
  learning_rate=0.0001
  halving_factor=0.5
  training_impr=0.01
  load_model=
  pre_cv_costs=100000.0
  reject=0
  #if [ -f $save_dir/log.txt ];then

  #  rm $save_dir/log.txt
  #fi
 for i in `seq 1 12`; do 
    if [ $i -gt 1 ]; then
      load_model=`cat $save_dir/best.mdl | cut -d ' ' -f 1`
    fi
    echo -e "\nLoad: $load_model"
    python -u train_dnn_tfrecords.py --num_iter=$i --learning_rate=$learning_rate --load_model=$load_model \
    --num_layers=$num_layers --num_units=$num_units --save_dir=$save_dir --output_dim=$output_dim \
    \ #--out_left_context=$out_left_context --out_right_context=$out_right_context \
    --left_context=$in_left_context --right_context=$in_right_context|| exit 1
    cur_cv_costs=`tail -n 1 $save_dir/log.txt | cut -d ' ' -f 2` 
    if [ $(echo "$cur_cv_costs <= $pre_cv_costs" | bc) = 1 ]; then
      best_model_name=`tail -n 1 $save_dir/log.txt | cut -d ' ' -f 1`
      echo $best_model_name > $save_dir/best.mdl
      pre_cv_costs=$cur_cv_costs
    else
     
      reject=$[$reject+1]
    fi
    if [ $reject -gt 0 ]; then
      learning_rate=$(echo " $learning_rate * $halving_factor  "|bc -l)
      echo -e "change learning rate to $learning_rate\n"
    fi
    rel_impr=$(bc <<< "scale=10; ($pre_cv_costs-$cur_cv_costs)/$pre_cv_costs")
   # if [ $(echo "$rel_impr < $training_impr" | bc) = 1 ];then
   #   if [ $reject -gt 0 ];then
   #     break
   #   fi
   # fi
  done
fi

echo 'Training Done'

#mode=wsj0_sp_test
if [ $stage -le 3 ]; then
  rm test_output/*
  load_model=`cat $save_dir/best.mdl`
  data_dir=`pwd`/test_output/ #`pwd`/data/wsj0_separation/test_pit/
  test_list=`pwd`/tfrecords/test_tf.list #config/${mode}_tf.lst
  python   test_dnn_tfrecords.py --load_model=$load_model --test_list=$test_list --data_dir=$data_dir \
    --num_layers=$num_layers --num_units=$num_units  --output_dim=$output_dim \
    \ #--out_left_context=$out_left_context --out_right_context=$out_right_context \
    --left_context=$in_left_context --right_context=$in_right_context|| exit 1

fi

if [ $stage -le 4 ]; then
  # . ./path.sh 
  # data_dir=`pwd`/data/wsj0_separation/test_pit/  #same as the stage 3
  tmp_list=/dev/shm/test_output.list
  # ori_wav_path=/home/disk1/snsun/Workspace/tensorflow/kaldi/data/wsj0_separation/ori_wav/wsj0_mixed_test/
  # rec_wav_path=data/wsj0_separation/rec_wav_test/
  output_data_dir=`pwd`/test_output
  #mkdir -p $rec_wav_path
  find $output_data_dir -iname "*.csv" | sort > $tmp_list
  for line in `cat $tmp_list`; do
    csvname=`basename -s .scp $line`
    csvname=${csvname:0:5}
    echo $csvname
    `matlab -nosplash -nodesktop -r "gen_video_f2('$csvname');exit;"` # -nodisplay
    tmp_file_name=/dev/shm/temp_0.avi
    wav_file_name=../NewDataArranged/aligened_netural/output_wav/${csvname}_mono.wav
    merged_result=./test_output/${csvname}_0_output.avi
    echo $tmp_file_name '+' $wav_file_name '>' $merged_result
    `ffmpeg -i $tmp_file_name -i $wav_file_name -c:v copy -c:a copy -map 0:v:0 -map 1:a:0 $merged_result`
  done

fi
echo "Done OK!"

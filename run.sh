#!/bin/bash

while getopts f:b: flag; do
  case "${flag}" in
  f) FG_PATH=${OPTARG} ;;
  b) BG_PATH=${OPTARG} ;;
  esac
done

FPS=$(ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate $FG_PATH)
FG_NUM_FRAMES=$(ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 $FG_PATH)
BG_NUM_FRAMES=$(ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 $BG_PATH)

MODEL_PATH='PaddleSeg/contrib/Matting'

mkdir -p $MODEL_PATH/tmp/extracted_frames/fgs
mkdir -p $MODEL_PATH/tmp/extracted_frames/bgs
mkdir -p $MODEL_PATH/tmp/blended_frames

ffmpeg -i $FG_PATH -qscale:v 1 -qmin 1 "${MODEL_PATH}/tmp/extracted_frames/fgs/fg_frames_%0${#FG_NUM_FRAMES}d.jpg"
ffmpeg -i $BG_PATH -qscale:v 1 -qmin 1 "${MODEL_PATH}/tmp/extracted_frames/bgs/bg_frames_%0${#BG_NUM_FRAMES}d.jpg"

cd $MODEL_PATH

for filename in tmp/extracted_frames/fgs/*jpg
do
	python bg_replace.py --config configs/modnet/modnet_hrnet_w18.yml --model_path output/best_model/modnet-hrnet_w18.pdparams --save_dir tmp/blended_frames --image_path "$filename" --bg_path "${filename//fg/bg}"
done

ffmpeg -framerate $FPS -i "tmp/blended_frames/fg_frames_%0${#FG_NUM_FRAMES}d.jpg" -c:v libx264 -r $FPS -pix_fmt yuv420p tmp/out_wo_audio.mp4

cd ../../../
ffmpeg -i $MODEL_PATH/tmp/out_wo_audio.mp4 -i $FG_PATH -c copy -map 0:0 -map 1:1 -shortest "blended_video$(date +'%Y-%m-%d_%H-%M-%S').mp4"

rm -rf "${MODEL_PATH}/tmp"
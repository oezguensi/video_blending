# Introduction
This repository contains information and a script on how to blend two videos, where the foreground contains a person whose background should be replaced by the given background video.

It uses [PaddleSeg](https://github.com/PaddlePaddle/PaddleSeg) as an Image Matting algorithm, but any other model which segments out persons can also be used.

# Installation
1. Clone [PaddleSeg](https://github.com/PaddlePaddle/PaddleSeg) in the root folder of this repository
2. Follow [these](https://github.com/PaddlePaddle/PaddleSeg/tree/release/2.4/contrib/Matting#Installation) steps to install the Image Matting model
3. Download one of the mentioned models. We used `HRNet_W18` for best perfomance, which can be download [here](https://paddleseg.bj.bcebos.com/matting/models/modnet-hrnet_w18.pdparams). Create a folder `PaddleSeg/contrib/Matting/output/best_model` and move the downloaded model in here 
4. Download the restructured [demo data](https://paddleseg.bj.bcebos.com/matting/datasets/PPM-100.zip) which is not used for this use case, but is needed for the model to run. Create a folder `PaddleSeg/contrib/Matting/data` and move the dataset in here

# Usage
Run the `run.sh` script and specify foreground (`-f`) and background (`-b`) videos with the corresponding flags. The blended video will be saved in the root folder. 

# mmWave-radar-signal-processing-and-microDoppler-classification
This is a repository for codes and template data of paper "Experiments with mmWave Automotive RadarTest-bed"

Please cite our paper with below bibtex when you use the codes.

@INPROCEEDINGS{9048939,  author={Gao, Xiangyu and Xing, Guanbin and Roy, Sumit and Liu, Hui}, 
booktitle={2019 53rd Asilomar Conference on Signals, Systems, and Computers}, 
title={Experiments with mmWave Automotive Radar Test-bed}, 
year={2019},  volume={},  number={},  pages={1-6},  doi={10.1109/IEEECONF44664.2019.9048939}}

## Software requirement
Matlab

## Run codes for generating range-angle maps and 3D point clouds
1. Customize your testbed/FMCW parameter in script: 
    ```
    ./utils/get_params_value.m
    ```
3. Select the input data ('pms1000_30fs.mat', 'bms1000_30fs.mat' or 'cms1000_30fs.mat') in script:
    ```
    generate_ra_3dfft.m
    ```
3. Run 'generate_ra_3dfft.m' script to get results. For example, the range-angle image and detected 3D point clouds for input data 'pms1000_30fs' are shown below:

  ![pms1000_ra](https://user-images.githubusercontent.com/46943965/121766791-50763380-cb09-11eb-9bef-7608e1afa9ce.jpg)
  ![pms1000_pointclouds](https://user-images.githubusercontent.com/46943965/121766798-5835d800-cb09-11eb-883c-e7c1cb3714c0.jpg)
 
4. Manipulate the algorithm parameters in below script to obtain the desired pointcloud results:
    ```
    ./utils/cfar_RV.m
    ```

## Continue to update the repos

# mmWave-radar-signal-processing-and-microDoppler-classification
This is a repository for codes and template data of paper ["***Experiments with mmWave Automotive Radar Test-bed***"](https://arxiv.org/pdf/1912.12566.pdf)

Please cite our paper with below bibtex if you find this repository useful.
```
@INPROCEEDINGS{9048939,  author={Gao, Xiangyu and Xing, Guanbin and Roy, Sumit and Liu, Hui}, 
booktitle={2019 53rd Asilomar Conference on Signals, Systems, and Computers}, 
title={Experiments with mmWave Automotive Radar Test-bed}, 
year={2019},  volume={},  number={},  pages={1-6},  doi={10.1109/IEEECONF44664.2019.9048939}}
```
## Update
***(June 18, 2022) A script for reading binary file has been created [read_bin.m](read_bin.m).***

***(June 9, 2022) One raw binary file named '2019_04_30_pbms002_raw_900fs.zip' can be downloaded [here](https://drive.google.com/drive/folders/1CC3nluGDral__geL6zIzCK2t5Jrhfwex?usp=sharing) for your use. It contains 900 frames with the same radar configuration as the data used below.***

***(Nov 22, 2021) NEW!!! The micro-Dooler classification part has been updated***

## Contact
Any questions or suggestions are welcome!

Xiangyu Gao xygao@uw.edu

## Software requirement
MATLAB, Python 3.6, Tensorflow 2.0, Jupyter Notebook

## Run codes for generating range-angle maps, range-Doppler maps, and 3D point clouds
1. Customize your testbed/FMCW parameter in script: 
    ```
    ./config/get_params_value.m
    ```
3. Select the input data ('pms1000_30fs.mat', 'bms1000_30fs.mat' or 'cms1000_30fs.mat') in script:
    ```
    generate_ra_3dfft.m
    ```
3. Run 'generate_ra_3dfft.m' script to get results. For example, the range-angle image, range-Doppler image, and detected 3D point clouds for input data 'pms1000_30fs' are shown below:

  ![pms1000_ra](https://user-images.githubusercontent.com/46943965/121766791-50763380-cb09-11eb-9bef-7608e1afa9ce.jpg)
  ![pms1000_rd](https://user-images.githubusercontent.com/46943965/123009986-9ab1ad00-d372-11eb-8541-d5469228868b.jpg)
  ![pms1000_pointclouds](https://user-images.githubusercontent.com/46943965/121766798-5835d800-cb09-11eb-883c-e7c1cb3714c0.jpg)
 
4. You can manipulate the algorithm parameters of below commands in "./utils/cfar_RV.m" script to obtain the desired point-cloud results:
    ```
    x_detected = cfar_ca1D_square(Dopdata_sum(rani,:), 4, 7, Pfa, 0, 0.7);
    y_detected = cfar_ca1D_square(Dopdata_sum(:, C(1,dopi)), 4, 8, Pfa, 0, 0.7);
    ```
5. It is optional to stop the range-Doppler image by setting below flag in codes to 0: 
    ```
    Is_plot_rangeDop = 1;
    ```
    
## Run codes for generating micro-Doppler maps
1. Customize your testbed/FMCW parameter in script: 
    ```
    ./config/get_params_value.m
    ```
3. Select the input data ('pms1000_30fs.mat', 'bms1000_30fs.mat' or 'cms1000_30fs.mat') in script:
    ```
    generate_microdoppler_stft.m
    ```
3. Run 'generate_microdoppler_stft.m' script to get results. For example, the micro-Doppler map for input data 'pms1000_30fs' is shown below:

   ![pms1000_md](https://user-images.githubusercontent.com/46943965/121852166-ed6cd400-cca3-11eb-8698-320efbfc9ad1.jpg)
 
4. You can manipulate the algorithm parameters in "generate_microdoppler_stft.m" to customize the micro-Doppler map properties:
    ```
    M = 16; % number of frames for generating micro-Doppler image
    Lr = 11; % length of cropped region along range
    La = 5; % length of cropped region along angle
    Ang_seq = [2,5,8,11,14]; % dialated angle bin index for cropping
    WINDOW =  255; % STFT parameters
    NOVEPLAP = 240; % STFT parameters
    ```

## Train and Test VGG16 classifier 
1. Download the template training data, testing data, and trained model from the Google Drive with below link:
    ```
    https://drive.google.com/drive/folders/1CC3nluGDral__geL6zIzCK2t5Jrhfwex?usp=sharing
    ```
    *Note that we select **part of our training and testing set** for your use here and the model was trainied with **whole complete** training set*. 

    *You may use the above algorithm "generate_microdoppler_stft.m" to create your own training and testing set (micro-Doopler images)*.

2. Put the decompressed training data, testing data, and trained model in "template data" folder as follow:
    ```
    '.\template data\train_data_part'
    '.\template data\test_data_part'
    '.\template data\trained_model\new_epoch10'
    ```
3. Run the training:
    ```
    train_classify.ipynb
    ```
5. Run the testing
    ```
    test_classify.ipynb
    ```
 
 ## License
 mmWave-radar-signal-processing-and-microDoppler-classification is released under MIT license (see LICENSE).
 
 ## Acknowlegement
This project is not possible without multiple great opensourced codebase and dataset. We list some notable examples below.  

* [raw_ADC_radar_dataset_for_automotive_object_detection](https://github.com/Xiangyu-Gao/Raw_ADC_radar_dataset_for_automotive_object_detection)
* [raw_2D_MIMO_radar_dataset_for_carry_object_detection](https://github.com/Xiangyu-Gao/Raw_2D_MIMO_radar_dataset_for_carry_object_detection)


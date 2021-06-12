# mmWave-radar-signal-processing-and-microDoppler-classification
Codes and template data for paper "Experiments with mmWave Automotive RadarTest-bed"

# NEW-cr-data-collector
 works for cascaded radar board

# Camera/Radar Data Collection Tools
This is a repository for Camera/Radar data collection tools, including operating the sensors, image/radar data preprocessing, sensor calibration.

## Installation
1. Install Anaconda and MATLAB.
2. Clone this repository to your local laptop.
3. Setup Python environment in Anaconda Prompt:
    ```
    cd cr-data-collector
    conda create --name datacol --file requirements.txt
    ```
4. Download Spinnaker Python SDK
    1) Download Spinnaker Python SDK: https://www.flir.com/products/spinnaker-sdk/
    2) DOWNLOAD NOW => DOWNLOAD FROM BOX => Windows => Latest Python Spinnaker => 
    x86: `spinnaker_python-1.23.0.27-cp36-cp36m-win32.zip` / x64: `spinnaker_python-1.23.0.27-cp36-cp36m-win_amd64.zip`
5. Activate conda env:
    ```
    activate datacol
    ```
6. Unzip downloaded Python SDK and follow `README.txt` "1.1 Installation for Windows". 
7. Install MATLAB Engine API for Python by following the instruction: https://www.mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html


## Run data collector
1. Activate conda env:
    ```
    activate datacol
    ```
2. Run script:
    ```
    python run_datacol.py
    ```
3. Set configurations:

    There are several configurations need to be set as follows. If you input nothing, it will use the default values.
    - Base directory: the place to store collected data. Default to be `D:\RawData`.
    - Sequence number: the number of sequences to be collected. Default to be 1. (if == 1, sequence name is needed; else, use `onrd_xxx`)
    - Sequence name: the name of the current sequence. Does not have default value.
    - Frame rate: the frame rate of the camera. Default to be 30 FPS.
    - Number of images: the number of images need to be collected in this sequence. Default to be 30. 

    Here is an example output of running this script:
    ```
    (datacol) D:\data-collection-tools\cr-data-collector>python run_datacol.py
    Enter base directory (default='D:\RawData'):
    Enter sequence number (default=1): 3
    Enter frame rate (default=30):
    Enter number of images (default=30):
    Input configurations:
            Base Directory:          D:\RawData\2019_06_26
            Sequence Number:         3
            Sequence Name:           ['2019_06_26_onrd012', '2019_06_26_onrd013', '2019_06_26_onrd014']
            Framerate:               30
            Image Number:            30
    
    Are the above configurations correct? (y/n) y
    ......
    ```
4. When all the configurations are set, press enter to start recording.

## Camera Calibration

We use [ROS](https://www.ros.org/) to calibrate our camera(s). 

ROS Kinetic installation instructions can be found here: http://wiki.ros.org/kinetic/Installation.

After install ROS, download Spinnaker SDK for our BlackFly S Cameras: http://wiki.ros.org/spinnaker_sdk_camera_driver.
Follow the instructions to install drivers and run camera. 

### Steps for monocular camera calibration
- Refer to http://wiki.ros.org/camera_calibration for the details first.
- Start ROS server: 
    ```
    roscore
    ```
- Start camera acquisition: 
    ```
    roslaunch spinnaker_camera_driver camera.launch
    ```
- Run camera calibration:
    ```
    rosrun camera_calibration cameracalibrator.py --size 8x6 \\
        --square 0.033 image:=/camera/image_raw camera:=/camera
    ```
- Move camera around the checkerboard to collect enough images and click "Calibrate" button.
- After calibration finished, click "Save" button.
- Copy calibration results to a desired destination: 
    ```
    cp /tmp/calibrationdata.tar.gz /mnt/nas_crdataset/
    ```

### Steps for stereo camera calibration
- Refer to http://wiki.ros.org/camera_calibration/Tutorials/StereoCalibration for the details first.
- Start ROS server: 
    ```
    roscore
    ```
- Start camera acquisition: 
    ```
    roslaunch spinnaker_camera_driver stereo.launch
    ```
- Run camera calibration:
    ```
    rosrun camera_calibration cameracalibrator.py --approximate 0.1 \\ 
        --size 8x6 --square 0.033 right:=/stereo/right/image_raw \\
        left:=/stereo/left/image_raw right_camera:=/stereo/right \\
        left_camera:=/stereo/left
    ```
- Move camera around the checkerboard to collect enough images and click "Calibrate" button.
- After calibration finished, click "Save" button.
- Copy calibration results to a desired destination: 
    ```
    cp /tmp/calibrationdata.tar.gz /mnt/nas_crdataset/
    ```


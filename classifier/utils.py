import tensorflow.compat.v1 as tf
import numpy as np
import scipy.io as spio
import os

_author__ = “Xiangyu Gao”
__copyright__ = “Copyright 2021, The Radar Perception project”
__credits__ = [“Xiangyu Gao”]
__license__ = “MPL 2.0”
__version__ = “0.1.0”
__maintainer__ = “Xiangyu Gao”
__email__ = “xygao@uw.edu”
__status__ = “Dev”

def get_session():
    """Create a session that dynamically allocates memory."""
    # See: https://www.tensorflow.org/tutorials/using_gpu#allowing_gpu_memory_growth
    config = tf.ConfigProto()
    config.gpu_options.allow_growth = True
    config.gpu_options.allocator_type = 'BFC'
    config.gpu_options.per_process_gpu_memory_fraction = 0.90
    session = tf.Session(config=config)
    # session = tf.Session()
    return session


def fetch_data(directory, files):
    item_list = []
    for file_name in files:
        file_directory = directory + file_name
        for sub_file in sorted(os.listdir(file_directory)):
            full_img_str = file_directory + "/" + sub_file
            # append the img and label to the list
            sub_file_elem = sub_file.split('_')
            file_type = sub_file_elem[-1][-3:]
            if file_type == 'png':
                pass
            else:

                if sub_file_elem[5] == 'cyclist':
                    label = [0, 1, 0]
                elif sub_file_elem[5] == 'pedestrian':
                    label = [1, 0, 0]
                elif sub_file_elem[5] == 'car':
                    label = [0, 0, 1]
                elif sub_file_elem[5] == 'train':
                    label = [0, 0, 1]
                elif sub_file_elem[5] == 'truck':
                    label = [0, 0, 1]
                elif sub_file_elem[5] == 'van':
                    label = [0, 0, 1]
                elif sub_file_elem[5] == '-1':
                    label = [-1, -1, -1]
                else:
                    label = [-1, -1, -1]

                sub_list = [full_img_str, label]
                item_list.append(sub_list)

    # return format [directory, label]
    return item_list


def mini_batch(features, labels, mini_batch_size):
    """
    Args:
        features: features for one batch
        labels: labels for one batch
        mini_batch_size: the mini-batch size you want to use.
    """
    # split the data into batches
    amount_of_data = len(features)
    number_of_bunches = amount_of_data / mini_batch_size

    bunches_features = []
    bunches_labels = []

    # loop over breaking the data into batches
    for i in range(int(number_of_bunches)):
        current_range = i * mini_batch_size
        f_b = features[current_range:current_range + mini_batch_size]
        l_b = labels[current_range:current_range + mini_batch_size]

        bunches_features.append(f_b)
        bunches_labels.append(l_b)

    # return the mini-batched data
    return bunches_features, bunches_labels


def fetch_batch(train_set_data):
    batch_data = []
    for files in train_set_data:
        mat = spio.loadmat(files, squeeze_me=True)
        data = np.abs(mat["STFT_data"])
        batch_data.append(data)

    return batch_data


def find_nearest(array, value):
    """
    Find nearest value to 'value' in 'array'
    :param array:
    :param value:
    :return:
    """
    array = np.asarray(array)
    idx = (np.abs(array - value)).argmin()
    return idx, array[idx]


def pol2cart(rho, phi):
    x = rho * np.cos(phi)
    y = rho * np.sin(phi)
    return x, y

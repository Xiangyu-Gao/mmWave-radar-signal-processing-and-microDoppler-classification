train_sets = {
    'root_dir': "./template data/train_data_part/",
    'dates': ['2019_04_09'],
    'seqs': [
        ['2019_04_09_pms1000', '2019_04_09_bms1000', '2019_04_09_cms1000'],
    ],  # 'seqs' is two list corresponding to 'dates', include all seqs if None
}  # training dat

test_sets = {
    'root_dir': "./template data/test_data_part/",
    'dates': ['2019_05_28'],
    'seqs': [
        ['2019_05_28_bm1s011', '2019_05_28_cm1s009', '2019_05_28_pm2s012'],
    ],
}  # test dataset

network_config = {
    'lr': 1e-5,  # learning rate
    'epoch': 10,  # number of traning steps
    'batch_size': 5,  # batch_size
    'num_classes': 3,  # num_input = 784
    'weights_path': './template data/trained_model/new_epoch10/model',
    # restore weights
}

class_ids = {
    'pedestrian': 0,
    'cyclist': 1,
    'car': 2,
    'van': 2,
    'truck': 2,
    'train': 2,
    'noise': -1000,
}

n_class = 3
class_table = {
    0: 'pedestrian',
    1: 'cyclist',
    2: 'car',
    # 3: 'van',
    # 4: 'truck',
}
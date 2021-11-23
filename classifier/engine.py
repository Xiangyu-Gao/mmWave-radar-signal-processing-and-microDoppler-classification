import time
import os
import logging
import numpy as np
import tensorflow.compat.v1 as tf

from classifier.networks import VGG16
from classifier.utils import fetch_data, mini_batch, get_session, fetch_batch
from config.classifier_config import network_config

_author__ = "Xiangyu Gao"
__copyright__ = "Copyright 2021, The Radar Perception project"
__credits__ = ["Xiangyu Gao"]
__license__ = "MPL 2.0"
__version__ = "0.1.0"
__maintainer__ = "Xiangyu Gao"
__email__ = "xygao@uw.edu"
__status__ = "Dev"


def load_data(data_sets, if_shuffle=False):
    """
    This function is for loading data with directory and label
    """
    root_dir = data_sets['root_dir']
    capture_date = data_sets['dates']
    seqs = data_sets['seqs']
    training_set = []
    for date_counter, date in enumerate(capture_date):
        directory = root_dir + capture_date[date_counter] + '/'
        if seqs[date_counter] is None:
            # find all in current folder
            train_file = os.listdir(directory)
        else:
            train_file = seqs[date_counter]
        training_set = training_set + fetch_data(directory, train_file)

    if if_shuffle:
        np.random.shuffle(training_set)
    train_set_data = []
    train_set_labels = []
    for i in range(len(training_set)):
        train_set_data.append(training_set[i][0])
        train_set_labels.append(training_set[i][1])

    return train_set_data, train_set_labels


def train(train_set_data, train_set_labels, if_save_model=False):
    """
    network training function
    """
    tf.reset_default_graph()
    tf.disable_eager_execution()  # disable eager since converting codes from tf1.0 to tf2.0
    tf.get_logger().setLevel(logging.ERROR)

    lr = network_config['lr']
    epoch = network_config['epoch']
    batch_size = network_config['batch_size']
    num_classes = network_config['num_classes']
    # weights_path = network_config['weights_path']

    train_set_data, train_set_labels = mini_batch(train_set_data, train_set_labels, batch_size)
    total_number_batch = len(train_set_data)
    print('the batch number of training set is ', total_number_batch)

    # tf graph input
    X = tf.placeholder(tf.float32, [None, 256, 256, 55], name='X')
    Y = tf.placeholder(tf.int32, [None, num_classes], name='Y')
    keep_prob = tf.placeholder(tf.float32, name='keep_prob')

    # predicted labels
    logits = VGG16(X, keep_prob)
    # define loss
    loss = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits_v2(logits=logits, labels=Y), name='loss')
    l2_loss = tf.losses.get_regularization_loss()
    loss += l2_loss

    # define optimizer
    optimizer = tf.train.AdamOptimizer(learning_rate=lr)
    train_op = optimizer.minimize(loss)

    # compare the predicted labels with true labels
    correct_pred = tf.equal(tf.argmax(logits, 1), tf.argmax(Y, 1))
    # compute the accuracy by taking average
    accuracy = tf.reduce_mean(tf.cast(correct_pred, tf.float32), name='accuracy')

    # Initialize the variables
    init = tf.global_variables_initializer()

    # Initiate or Load model
    saver = tf.train.Saver()
    sess = get_session()
    sess.run(init)
    # saver.restore(sess, weights_path) # load pre-trained model
    acc_t_list = []
    loss_list = []

    for i in range(0, epoch):
        acc_t = 0
        loss_final = 0
        for j in range(total_number_batch):
            cur_time = time.time()
            # fetch batch
            batch_x = fetch_batch(train_set_data[j])
            # print("running")
            batch_y = train_set_labels[j]
            # run optimization
            loss1, acc1, _ = sess.run([loss, accuracy, train_op], feed_dict={X: batch_x, Y: batch_y, keep_prob: 0.5})
            used_time = time.time() - cur_time
            print('[%d, %d] loss: %.7f, accuracy: %.7f, used time: %.5f' % (i, j, loss1, acc1, used_time))
            acc_t += acc1
            loss_final = loss1

        acc_t = acc_t / len(train_set_data)
        loss_final = loss_final / len(train_set_data)
        print("Epoch " + str(i) + ': Accuracy training = %.3f, loss training = %.5f' % (acc_t, loss_final))

        acc_t_list.append(acc_t)
        loss_list.append(loss_final)

        if if_save_model:
            save_model_folder = './template data/trained_model/new_epoch' + str(i) + '/'
            if not os.path.exists(save_model_folder):
                os.mkdir(save_model_folder)
            save_model_dir = save_model_folder + 'model'
            saver.save(sess, save_model_dir)

    print("Training finished!")


def test(test_set_data, test_set_labels):
    """
    network testing function
    The directory for loading model is specified in network_config dictionary
    """
    tf.reset_default_graph()
    tf.disable_eager_execution()  # disable eager since converting codes from tf1.0 to tf2.0
    tf.get_logger().setLevel(logging.ERROR)
    batch_size = 1
    num_classes = network_config['num_classes']
    weights_path = network_config['weights_path']

    test_set_data, test_set_labels = mini_batch(test_set_data, test_set_labels, batch_size)
    total_number_batch = len(test_set_data)
    print('the batch number of testing set is ', total_number_batch)

    # tf graph input
    X = tf.placeholder(tf.float32, [None, 256, 256, 55], name='X')
    Y = tf.placeholder(tf.int32, [None, num_classes], name='Y')
    keep_prob = tf.placeholder(tf.float32, name='keep_prob')

    # predicted labels
    logits = VGG16(X, keep_prob)
    # define loss
    loss = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits_v2(logits=logits, labels=Y), name='loss')
    l2_loss = tf.losses.get_regularization_loss()
    loss += l2_loss

    # compare the predicted labels with true labels
    correct_pred = tf.equal(tf.argmax(logits, 1), tf.argmax(Y, 1))
    # compute the accuracy by taking average
    accuracy = tf.reduce_mean(tf.cast(correct_pred, tf.float32), name='accuracy')

    # tensor board
    tf.summary.scalar('loss', loss)
    merge = tf.summary.merge_all()

    # Save model
    saver = tf.train.Saver()
    sess = get_session()
    saver.restore(sess, weights_path) # load pre-trained model

    acc_t = 0
    loss_final = 0
    i = 0
    for j in range(total_number_batch):
        cur_time = time.time()
        # fetch batch
        batch_x = fetch_batch(test_set_data[j])
        # print("running")
        batch_y = test_set_labels[j]
        # run optimization
        summary, loss1, acc1 = sess.run([merge, loss, accuracy], feed_dict={X: batch_x, Y: batch_y, keep_prob: 0.5})
        used_time = time.time() - cur_time
        print('[%d, %d] loss: %.7f, accuracy: %.7f, used time: %.5f' % (i, j, loss1, acc1, used_time))
        acc_t += acc1
        loss_final = loss1

    acc_t = acc_t / len(test_set_data)
    loss_final = loss_final / len(test_set_data)
    print("Epoch " + str(i) + ': Accuracy training = %.3f, loss training = %.5f' % (acc_t, loss_final))
    print("Testing finished!")

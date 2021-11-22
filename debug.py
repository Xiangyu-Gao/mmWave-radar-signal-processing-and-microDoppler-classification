import os
import tensorflow.compat.v1 as tf
from tensorflow.python.tools.inspect_checkpoint import print_tensors_in_checkpoint_file
from classifier.networks import VGG16
from config.classifier_config import network_config
"""
This script is for temporary debugging
"""

old_train_model_dir = './template data/trained_model/epoch10/model'
replace_model_dir = './template data/trained_model/epoch10/model'
# vars_list = tf.train.list_variables(old_train_model_dir)
# vars_list_replace = tf.train.list_variables(replace_model_dir)
# print_tensors_in_checkpoint_file(file_name=old_train_model_dir, tensor_name='fully_connected_2/biases',
#                                  all_tensors=False)

tf.reset_default_graph()
tf.disable_eager_execution()  # disable eager since converting codes from tf1.0 to tf2.0
lr = network_config['lr']
epoch = network_config['epoch']
batch_size = network_config['batch_size']
num_classes = network_config['num_classes']

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

reader = tf.train.NewCheckpointReader(old_train_model_dir)
restore_dict = dict()
v_exist = []
left = []
for v in tf.trainable_variables():
    tensor_name = v.name.split(':')[0]
    # print(tensor_name)
    if reader.has_tensor(tensor_name):
        print('has tensor ', tensor_name)
        # restore_dict[tensor_name] = v
        v_exist.append(v)
    else:
        left.append(v)

# saver = tf.train.Saver(restore_dict)
with tf.Session() as sess:
    sess.run(tf.initialize_all_variables())
    # # print(sess.run(tf.trainable_variables()[0]))
    # saver.restore(sess, old_train_model_dir)
    # # print(tf.train.load_variable(old_train_model_dir, tf.trainable_variables()[0].name.split(':')[0]))
    # # print(sess.run(tf.trainable_variables()[0]))
    for vn in v_exist:
        tensor_name = vn.name.split(':')[0]
        new_vn_val = tf.train.load_variable(old_train_model_dir, tensor_name)
        # print(vn.shape, new_vn_val.shape)
        sess.run(tf.assign(vn, new_vn_val))

    for vn in left:
        tensor_name = vn.name.split(':')[0]
        new_tensor_name = tensor_name.replace("dense", "fully_connected").replace("kernel", "weights").replace("bias",
                                                                                                               "biases")
        new_vn_val = tf.train.load_variable(old_train_model_dir, new_tensor_name)
        sess.run(tf.assign(vn, new_vn_val))

    # Initiate or Load model
    saver = tf.train.Saver()
    save_model_folder = './template data/trained_model/new_epoch' + str(10) + '/'
    if not os.path.exists(save_model_folder):
        os.mkdir(save_model_folder)
    save_model_dir = save_model_folder + 'model'
    saver.save(sess, save_model_dir)

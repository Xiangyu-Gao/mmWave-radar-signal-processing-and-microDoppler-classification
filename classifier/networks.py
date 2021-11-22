import tensorflow.compat.v1 as tf

num_classes = 3


def VGG16(x, keep_prob):    
    # first conv and pool pair
    # filters, then kernel size
    conv1 = tf.layers.conv2d(x, 64, 3, activation=tf.nn.relu, padding="same")
    conv2 = tf.layers.conv2d(conv1, 64, 3, activation=tf.nn.relu, padding="same")
    # pool size, then stride
    pool2 = tf.layers.max_pooling2d(conv2, 2, 2)
    
    # filters, then kernel size
    conv3 = tf.layers.conv2d(pool2, 128, 3, activation=tf.nn.relu, padding="same")
    conv4 = tf.layers.conv2d(conv3, 128, 3, activation=tf.nn.relu, padding="same")
    # pool size, then stride
    pool4 = tf.layers.max_pooling2d(conv4, 2, 2)
    
    # filters, then kernel size
    conv5 = tf.layers.conv2d(pool4, 256, 3, activation=tf.nn.relu, padding="same")
    conv6 = tf.layers.conv2d(conv5, 256, 3, activation=tf.nn.relu, padding="same")
    conv7 = tf.layers.conv2d(conv6, 256, 3, activation=tf.nn.relu, padding="same")
    # pool size, then stride
    pool7 = tf.layers.max_pooling2d(conv7, 2, 2)
    
    # filters, then kernel size
    conv8 = tf.layers.conv2d(pool7, 512, 3, activation=tf.nn.relu, padding="same")
    conv9 = tf.layers.conv2d(conv8, 512, 3, activation=tf.nn.relu, padding="same")
    conv10 = tf.layers.conv2d(conv9, 512, 3, activation=tf.nn.relu, padding="same")
    # pool size, then stride
    pool10 = tf.layers.max_pooling2d(conv10, 2, 2)

    # filters, then kernel size
    conv11 = tf.layers.conv2d(pool10, 512, 3, activation=tf.nn.relu, padding="same")
    conv12 = tf.layers.conv2d(conv11, 512, 3, activation=tf.nn.relu, padding="same")
    conv13 = tf.layers.conv2d(conv12, 512, 3, activation=tf.nn.relu, padding="same")
    # pool size, then stride
    pool13 = tf.layers.max_pooling2d(conv13, 2, 2)
    
    # flatten to connect to fully connected
    full_in = tf.layers.flatten(pool13)
    
    # fully connected layer
    full1 = tf.layers.dense(inputs=full_in, units=4096, activation=tf.nn.relu)
    full2 = tf.layers.dense(inputs=full1, units=4096, activation=tf.nn.relu)
    logits = tf.layers.dense(inputs=full2, units=num_classes, activation=None)

    return logits

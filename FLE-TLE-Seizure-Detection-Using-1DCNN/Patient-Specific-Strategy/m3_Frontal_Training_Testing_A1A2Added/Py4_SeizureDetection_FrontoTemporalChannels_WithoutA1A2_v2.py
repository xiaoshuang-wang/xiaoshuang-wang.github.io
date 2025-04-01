# -*- coding: utf-8 -*-
"""
Created on Tue Dec  5 14:42:00 2023
@author: User
"""

# In[]
from keras.layers import Input
from keras.layers import Conv1D, BatchNormalization, MaxPooling1D, concatenate
from keras.layers import GlobalAveragePooling1D, Dense, Activation, Dropout
from keras.models import Model 
#from keras.layers import Flatten,LSTM,Dropout

def OneDCNN_model(length,channels):
    NumKernel = 64;
    input_layer = Input(shape=(length,channels))

    # 第一个1DCNN模型
    model1 = Conv1D(NumKernel,3,strides=2,padding='same')(input_layer)
    model1 = Activation('relu')(model1)
    model1 = BatchNormalization()(model1)
    model1 = Conv1D(NumKernel,3,strides=2,padding='same')(model1)
    model1 = Activation('relu')(model1)
    model1 = BatchNormalization()(model1)
    model1 = MaxPooling1D(2,strides=2,padding='same')(model1)
    
    model1 = Conv1D(2*NumKernel,3,strides=1,padding='same')(model1)
    model1 = Activation('relu')(model1)
    model1 = BatchNormalization()(model1)
    model1 = Conv1D(2*NumKernel,3,strides=1,padding='same')(model1)
    model1 = Activation('relu')(model1)
    model1 = BatchNormalization()(model1)
    model1 = MaxPooling1D(2,strides=2,padding='same')(model1)
    
    model1 = Conv1D(4*NumKernel,3,strides=1,padding='same')(model1)
    model1 = Activation('relu')(model1)
    model1 = BatchNormalization()(model1)
    model1 = Conv1D(4*NumKernel,3,strides=1,padding='same')(model1)
    model1 = Activation('relu')(model1)
    model1 = BatchNormalization()(model1)
    model1 = MaxPooling1D(2,strides=2,padding='same')(model1)
    
    model1 = Conv1D(8*NumKernel,3,strides=1,padding='same')(model1)
    model1 = Activation('relu')(model1)
    model1 = BatchNormalization()(model1)
    model1 = Conv1D(8*NumKernel,3,strides=1,padding='same')(model1)
    model1 = Activation('relu')(model1)
    model1 = BatchNormalization()(model1)
    model1 = MaxPooling1D(2,strides=2,padding='same')(model1)

    # 第二个1DCNN模型
    model2 = Conv1D(NumKernel,5,strides=2,padding='same')(input_layer)
    model2 = Activation('relu')(model2)
    model2 = BatchNormalization()(model2)
    model2 = Conv1D(NumKernel,5,strides=2,padding='same')(model2)
    model2 = Activation('relu')(model2)
    model2 = BatchNormalization()(model2)
    model2 = MaxPooling1D(2,strides=2,padding='same')(model2)
    
    model2 = Conv1D(2*NumKernel,5,strides=1,padding='same')(model2)
    model2 = Activation('relu')(model2)
    model2 = BatchNormalization()(model2)
    model2 = Conv1D(2*NumKernel,5,strides=1,padding='same')(model2)
    model2 = Activation('relu')(model2)
    model2 = BatchNormalization()(model2)
    model2 = MaxPooling1D(2,strides=2,padding='same')(model2)
    
    model2 = Conv1D(4*NumKernel,5,strides=1,padding='same')(model2)
    model2 = Activation('relu')(model2)
    model2 = BatchNormalization()(model2)
    model2 = Conv1D(4*NumKernel,5,strides=1,padding='same')(model2)
    model2 = Activation('relu')(model2)
    model2 = BatchNormalization()(model2)
    model2 = MaxPooling1D(2,strides=2,padding='same')(model2)
    
    model2 = Conv1D(8*NumKernel,5,strides=1,padding='same')(model2)
    model2 = Activation('relu')(model2)
    model2 = BatchNormalization()(model2)
    model2 = Conv1D(8*NumKernel,5,strides=1,padding='same')(model2)
    model2 = Activation('relu')(model2)
    model2 = BatchNormalization()(model2)
    model2 = MaxPooling1D(2,strides=2,padding='same')(model2)
    
    # 合并两个模型
    x = concatenate([model1,model2])
    x = GlobalAveragePooling1D()(x)
    
    # 全连接层
    x = Dense(256,activation='relu')(x)
    x = Dropout(0.25)(x)
    x = Dense(64,activation='relu')(x)
    output_layer = Dense(2,activation='sigmoid')(x)

    model = Model(inputs=input_layer,outputs=output_layer)
    model.compile(loss='categorical_crossentropy',optimizer='adam',metrics=['accuracy'])
    return model

# In[]
import os, gc
import h5py
import numpy as np
from keras.utils import np_utils
from keras.callbacks import EarlyStopping
from keras import backend as K
import scipy.io as sio

def create_folder_if_not_exists(NewPath):
    if not os.path.exists(NewPath):
        os.makedirs(NewPath)
        print(f"文件夹 '{NewPath}' 已创建。")
    else:
        print(f"文件夹 '{NewPath}' 已存在，跳过创建。")

early_stopping = EarlyStopping(monitor='val_loss',patience=10,verbose=1,restore_best_weights=True)
Path = 'D:/03_EpilepsyData/02_DataSelectedProcessing/m3_Frontal_Training_Testing_A1A2Added/' ###
 
Folders = ['Pat_01/','Pat_02/','Pat_03/','Pat_04/','Pat_05/','Pat_06/','Pat_07/','Pat_08/','Pat_09/','Pat_10/',
           'Pat_11/','Pat_12/','Pat_13/','Pat_14/','Pat_15/','Pat_16/','Pat_17/','Pat_18/','Pat_19/','Pat_20/'] ######################
NumFolder = len(Folders)
NumRun = 5
#
for FoldersNum in range(0,NumFolder):
    Route = Path+Folders[FoldersNum]
    mat_files = [f for f in os.listdir(Route) if f.endswith('.mat')]
    NumMat = len(mat_files)
    
    NewPath = Path+'DetectionLabels_v2/'+'04_FrontoTemporalChannels_WithoutA1A2/'+Folders[FoldersNum] #############################
    create_folder_if_not_exists(NewPath)
    
    for MatNum in range(0,NumMat):
        MatPath = Route+mat_files[MatNum]
        Data = h5py.File(MatPath,'r')
        X = Data['TrainTest']
        
        TempTrain = Data[X[0][0]][:]
        Train = TempTrain[:,:,np.r_[0:4,10:16,18]]
        del TempTrain
        gc.collect()
        print(np.shape(Train))
        length = len(Train[0,:,0])
        channels = len(Train[0,0,:])
        
        Label = Data[X[1][0]]
        Label = np.transpose(Label,[1,0])
        Label_Train = np_utils.to_categorical(Label)
        
        Label_Test = Data[X[3][0]]
        Label_Test = np.transpose(Label_Test,[1,0])
        samps = len(Label_Test)
        Label_Test = np.squeeze(Label_Test)
        Pred_Labels = np.zeros((samps,3,NumRun))
        
        TempTest = Data[X[2][0]][:]
        Test = TempTest[:,:,np.r_[0:4,10:16,18]]
        del TempTest
        gc.collect()
        print(np.shape(Test))
        
        del X
        gc.collect()
        del Data
        gc.collect()
        del Label
        gc.collect()
        
        model = OneDCNN_model(length,channels)
        for RunNum in range(0,NumRun):
            model.fit(Train,Label_Train,epochs=100,batch_size=64,validation_split=0.20,
                      callbacks=[early_stopping])
            K.clear_session()
            
            Label_Prob = model.predict(Test)
            Pred_Labels[:,0:2,RunNum] = Label_Prob
            Pred_Labels[:,2,RunNum] = Label_Test
            
        NewRoute = NewPath+'PredLabels_'+mat_files[MatNum]
        sio.savemat(NewRoute,{'PredLabels':Pred_Labels})


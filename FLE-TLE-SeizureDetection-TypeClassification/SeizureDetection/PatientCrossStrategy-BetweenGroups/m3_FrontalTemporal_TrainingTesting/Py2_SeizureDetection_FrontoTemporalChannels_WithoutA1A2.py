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
Path = 'D:/03_EpilepsyData/03_SeizureDetection/m1_FrontalTemporal_TrainingTesting/0.5Overlap/' ###
mat_files = [f for f in os.listdir(Path) if f.endswith('.mat')]
NumMat = len(mat_files)
NumRun = 5

NewPath_F = Path+'DetectionLabels_Again/'+'02_FrontoTemporalChannels_WithoutA1A2/Labels_Frontal/' #############################
create_folder_if_not_exists(NewPath_F)

NewPath_T = Path+'DetectionLabels_Again/'+'02_FrontoTemporalChannels_WithoutA1A2/Labels_Temporal/' #############################
create_folder_if_not_exists(NewPath_T)

for MatNum in range(0,NumMat):
    MatPath = Path+mat_files[MatNum]
    Data = h5py.File(MatPath,'r')
    X = Data['TrainTest']
    #print(X.shape)
    
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
    
    TempTestF = Data[X[2][0]][:]
    TestF = TempTestF[:,:,np.r_[0:4,10:16,18]]
    del TempTestF
    gc.collect()
    print(np.shape(TestF))
    
    Label_TestF = Data[X[3][0]]
    Label_TestF = np.transpose(Label_TestF,[1,0])
    sampsF = len(Label_TestF)
    Label_TestF = np.squeeze(Label_TestF)
    Pred_Labels_F = np.zeros((sampsF,3,NumRun))
    
    TempTestT = Data[X[4][0]][:]
    TestT = TempTestT[:,:,np.r_[0:4,10:16,18]]
    del TempTestT
    gc.collect()
    print(np.shape(TestT))
    
    Label_TestT = Data[X[5][0]]
    Label_TestT = np.transpose(Label_TestT,[1,0])
    sampsT = len(Label_TestT)
    Label_TestT = np.squeeze(Label_TestT)
    Pred_Labels_T = np.zeros((sampsT,3,NumRun))
    
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
        
        Label_ProbF = model.predict(TestF)
        Pred_Labels_F[:,0:2,RunNum] = Label_ProbF
        Pred_Labels_F[:,2,RunNum] = Label_TestF
        
        Label_ProbT = model.predict(TestT)
        Pred_Labels_T[:,0:2,RunNum] = Label_ProbT
        Pred_Labels_T[:,2,RunNum] = Label_TestT
        
    NewRoute_F = NewPath_F+'PredLabels_'+mat_files[MatNum]
    sio.savemat(NewRoute_F,{'PredLabels':Pred_Labels_F})
    
    NewRoute_T = NewPath_T+'PredLabels_'+mat_files[MatNum]
    sio.savemat(NewRoute_T,{'PredLabels':Pred_Labels_T})




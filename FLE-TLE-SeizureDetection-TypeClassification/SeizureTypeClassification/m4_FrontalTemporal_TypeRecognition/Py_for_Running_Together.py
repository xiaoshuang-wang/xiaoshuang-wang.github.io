# -*- coding: utf-8 -*-
"""
Created on Fri Sep 18 16:31:46 2020

@author: lenovo
"""

# In[]

PatFile = ['D:/03_EpilepsyData/04_SeizureTypeRecognition/m2_FrontalTemporal_TypeRecognition/Py1_SeizureDetection_AllChannels_WithA1A2.py',
           'D:/03_EpilepsyData/04_SeizureTypeRecognition/m2_FrontalTemporal_TypeRecognition/Py2_SeizureDetection_FrontoTemporalChannels_WithoutA1A2.py']

# In[]

import os
import subprocess
for Num in range(0,len(PatFile)):
    Route = os.path.join(PatFile[Num])
    subprocess.run(['python',Route], check=True)

    
    #print(p)
    # p should be 0
    
# In[] 
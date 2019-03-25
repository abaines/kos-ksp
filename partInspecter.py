# Alan Baines

import os.path
import os
import threading
import hashlib
import shutil
import winsound
import time
import glob
import re


interestingParts = []

for filename in glob.iglob('../../GameData/**/*.cfg', recursive=True):
   abspath = os.path.abspath(filename)
   ##print(abspath)
   interestingParts.append(abspath)
##   print(filename)

def shortname(filename):
   #print(filename)
   key = "\\GameData\\"
   idx = filename.find(key)+1
   #print(idx)
   return filename[idx:]


def partTitle(fileContents):
   firstTitle = re.findall(r'title.*\n',fileContents)[0][:-1]
   return firstTitle[firstTitle.rfind('=')+1:].strip()

def partName(fileContents):
   firstName = re.findall(r'name.*\n',fileContents)[0][:-1]
   return firstName[firstName.rfind('=')+1:].strip()


for filename in interestingParts:
   statinfo = os.stat(filename)

   try:
      with open(filename,'r') as f:
         output = f.read()

      fileContents = output

      ModuleEnginesFX_count = len(re.findall(r'ModuleEnginesFX',fileContents))

      IntakeAir_count = len(re.findall(r'IntakeAir',fileContents))
      LiquidFuel_count = len(re.findall(r'LiquidFuel',fileContents))
      Oxidizer_count = len(re.findall(r'Oxidizer',fileContents))

      
      

      if ModuleEnginesFX_count>0 and LiquidFuel_count>Oxidizer_count:

         print(partTitle(fileContents))
         print(partName(fileContents))
         print(IntakeAir_count,LiquidFuel_count,Oxidizer_count,shortname(filename))

         print()
   except:
      pass

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

for filename in interestingParts:
   statinfo = os.stat(filename)

   try:
      with open(filename,'r') as f:
         output = f.read()

      fileContents = output

      f = re.findall(r'ModuleEnginesFX',fileContents)

      count = len(f)
      if count>0:
         print(count,shortname(filename),statinfo.st_size)
   except:
      pass

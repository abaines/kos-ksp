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


class Engine:
   def __init__(self, filename, fileContents, IntakeAir_count, LiquidFuel_count, Oxidizer_count):

      self.filename = filename
      self.IntakeAir_count = IntakeAir_count
      self.LiquidFuel_count = LiquidFuel_count
      self.Oxidizer_count = Oxidizer_count

      self.title = partTitle(fileContents)
      self.name = partName(fileContents)

      self.engineAccelerationSpeed = doubleValuesFromKeyValueAssignment(fileContents,'engineAccelerationSpeed')
      self.engineDecelerationSpeed = doubleValuesFromKeyValueAssignment(fileContents,'engineDecelerationSpeed')

   def __repr__(self):
      return self.title


interestingParts = []

for filename in glob.iglob('../../GameData/**/*.cfg', recursive=True):
   abspath = os.path.abspath(filename)
   interestingParts.append(abspath)

def shortname(filename):
   key = "\\GameData\\"
   idx = filename.find(key)+1
   return filename[idx:]


def partTitle(fileContents):
   firstTitle = re.findall(r'title.*\n',fileContents)[0][:-1]
   return firstTitle[firstTitle.rfind('=')+1:].strip()

def partName(fileContents):
   firstName = re.findall(r'name.*\n',fileContents)[0][:-1]
   return firstName[firstName.rfind('=')+1:].strip()

def doubleValuesFromKeyValueAssignment(fileContents,key):
   fa = re.findall(r'engineAccelerationSpeed.*=.*',fileContents)

   doubles = []

   for m in fa:
      s = m[m.rfind('=')+1:].strip()
      doubles.append(float(s))

   return doubles

failedFiles = []

engineObjects = []

for filename in interestingParts:
   statinfo = os.stat(filename)

   try:
      with open(filename,'r') as f:
         output = f.read()

      fileContents = output

      ModuleEnginesFX_count = len(re.findall(r'ModuleEnginesFX',fileContents))

      IntakeAir_count = len(re.findall(r'name.*=.*IntakeAir',fileContents))
      LiquidFuel_count = len(re.findall(r'name.*=.*LiquidFuel',fileContents))
      Oxidizer_count = len(re.findall(r'name.*=.*Oxidizer',fileContents))

      if ModuleEnginesFX_count>0 and LiquidFuel_count>Oxidizer_count:
         engineObject = Engine(filename, fileContents, IntakeAir_count,LiquidFuel_count,Oxidizer_count)
         engineObjects.append(engineObject)

   except:
      failedFiles.append(shortname(filename))
      pass



for filename in failedFiles:
   if '\\Localization\\' in filename:
      pass
   elif '\\Lang\\' in filename:
      pass
   elif '\\Localization.cfg' in filename:
      pass
   else:
      print(filename)


for engine in sorted(engineObjects, key=lambda engine: min(engine.engineAccelerationSpeed)):
   print(engine)
   print(engine.name)
   print(shortname(engine.filename))
   print(engine.IntakeAir_count, engine.LiquidFuel_count, engine.Oxidizer_count)
   print(engine.engineAccelerationSpeed)
   print(engine.engineDecelerationSpeed)

   print()

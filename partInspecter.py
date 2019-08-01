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
import traceback
import sys


class Engine:
   def __init__(self, filename, fileContents, IntakeAir_count, LiquidFuel_count, Oxidizer_count):

      self.filename = filename
      self.IntakeAir_count = IntakeAir_count
      self.LiquidFuel_count = LiquidFuel_count
      self.Oxidizer_count = Oxidizer_count

      try:
         self.title = partTitle(fileContents)
      except:
         pass         
      self.name = partName(fileContents)

      try:
         self.gimbalRange = partGimbalRange(fileContents)
      except:
         pass

      try:
         self.attachRules = partAttachRules(fileContents)
      except:
         pass

      self.atmosphereCurve = partAtmosphereCurve(fileContents)

      self.engineAccelerationSpeed = doubleValuesFromKeyValueAssignment(fileContents,'engineAccelerationSpeed')
      self.engineDecelerationSpeed = doubleValuesFromKeyValueAssignment(fileContents,'engineDecelerationSpeed')

   def __repr__(self):
      if hasattr(self,'title'):
         return self.title
      else:
         return "Unknown Title"


class Antenna:
   def __init__(self, filename, fileContents):
      self.filename = filename

      try:
         self.title = partTitle(fileContents)
      except:
         pass         
      self.name = partName(fileContents)

      # TODO
      # antennaType
      # antennaCombinable

      self.antennaPower = int(Antenna.parseGenericFloat(fileContents,"antennaPower"))
      self.packetResourceCost = int(Antenna.parseGenericFloat(fileContents,"packetResourceCost"))
      self.packetSize = int(Antenna.parseGenericFloat(fileContents,"packetSize"))
      self.packetInterval = Antenna.parseGenericFloat(fileContents,"packetInterval")
      self.mass = Antenna.parseGenericFloat(fileContents,"mass")

      try:
         self.attachRules = partAttachRules(fileContents)
      except:
         pass


      # upper case fields for derived; lower case for raw
      self.ElectricChargePerSecond = self.packetResourceCost / self.packetInterval
      self.ElectricChargePerMits = self.packetResourceCost / self.packetSize
      self.Bandwidth = self.packetSize / self.packetInterval



   def parseGeneric(fileContents,key):
      search = re.findall(r''+key+'.*=.*\n',fileContents)[0][:-1]
      search = search[search.rfind('=')+1:].strip()
      return search

   def parseGenericFloat(fileContents,key):
      search = Antenna.parseGeneric(fileContents,key)
      commentPos = search.rfind('//')
      if commentPos>0:
         search = search[:search.rfind('//')].strip()
      return float(search)

   def __repr__(self):
      if hasattr(self,'title'):
         return self.title
      else:
         return "Unknown Title"



def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

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

def partGimbalRange(fileContents):
   firstName = re.findall(r'gimbalRange.*\n',fileContents)[0][:-1]
   return [float(firstName[firstName.rfind('=')+1:].strip())]

def partAttachRules(fileContents):
   # attachment rules: stack, srfAttach, allowStack, allowSrfAttach, allowCollision
   firstName = re.findall(r'attachRules.*\n',fileContents)[0][:-1]
   return firstName[firstName.rfind('=')+1:].strip()

def doubleValuesFromKeyValueAssignment(fileContents,key):
   fa = re.findall(r'engineAccelerationSpeed.*=.*',fileContents)

   doubles = []

   for m in fa:
      s = m[m.rfind('=')+1:].strip()
      doubles.append(float(s))

   return doubles

def partAtmosphereCurve(fileContents):
   atmosphereCurveText = re.findall(r'atmosphereCurve[^\{]*?\{[^\}]*?\}',fileContents)

   atmosphereCurveData = []
   for multitext in atmosphereCurveText:
      d = dict()
      multiResult = re.findall(r'.*key.*=.*?[\d+]\w+[\d+]',multitext) # regex find all results
      for line in multiResult:
         line = line.strip()
         if not set(line).issubset('key =1234567890.'):
            print("!"+line)

         linere = re.findall(r'[\d.]+',line)
         if len(linere)!=2:
            print("@"+linere)

         d[float(linere[0])] = float(linere[1])

      atmosphereCurveData.append(d)

   return atmosphereCurveData


def checkIfImportantFileName(filename):
   if '\\Localization\\' in filename:
      return False
   elif '\\Lang\\' in filename:
      return False
   elif '\\Localization.cfg' in filename:
      return False
   else:
      return True


failedFiles = []

engineObjects = []

relayAntennas = []

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

      # antennaType = RELAY
      relayAntenna_count = len(re.findall(r'antennaType.*=.*RELAY',fileContents))
      

      # and LiquidFuel_count>=Oxidizer_count 
      if ModuleEnginesFX_count>0 and LiquidFuel_count>0:
         engineObject = Engine(filename, fileContents, IntakeAir_count,LiquidFuel_count,Oxidizer_count)
         engineObjects.append(engineObject)

      if relayAntenna_count>0:
         relayAntenna = Antenna(filename,fileContents)
         relayAntennas.append(relayAntenna)

   except Exception as e:
      if checkIfImportantFileName(filename):
         failedFiles.append(shortname(filename))
         eprint(shortname(filename))
         traceback.print_exc()


for filename in failedFiles:
   if '\\Localization\\' in filename:
      pass
   elif '\\Lang\\' in filename:
      pass
   elif '\\Localization.cfg' in filename:
      pass
   else:
      print(filename)


def engine_compare(engine):
   spaceIsp = -1
   for curve in engine.atmosphereCurve:
      ncurve = list(curve.values())
      spaceIsp = max(max(ncurve),spaceIsp)
   return spaceIsp


def displayEngineData():
   print("Engines:")
   for engine in sorted(engineObjects, key=lambda engine: engine_compare(engine)):

      print(engine)
      print(engine.name)
      print(shortname(engine.filename))
      print(engine.IntakeAir_count, engine.LiquidFuel_count, engine.Oxidizer_count)
      print(engine.engineAccelerationSpeed)
      print(engine.engineDecelerationSpeed)

      try:
         print(engine.gimbalRange)
      except:
         print("-")
      try:
         print(engine.attachRules)
      except:
         print("-")

      print(engine.atmosphereCurve)

      print()


print(" ")
for antenna in sorted(relayAntennas,key=lambda antenna: antenna.antennaPower):
   if antenna.antennaPower>=2e+9:
      print(antenna)
      print('antennaPower', '%.0E' % antenna.antennaPower)
      print('Electric/Mits',antenna.ElectricChargePerMits)
      #print('Bandwidth',antenna.Bandwidth)
      #print('Electric Charge/sec',antenna.ElectricChargePerSecond)
      print("")

for antenna in sorted(relayAntennas,key=lambda antenna: antenna.ElectricChargePerMits):
   if antenna.antennaPower>=2e+9:
      print(antenna, '%.0E' % antenna.antennaPower, antenna.ElectricChargePerMits, antenna.mass, sep="\t")


print('end of file')

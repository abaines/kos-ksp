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


class Parser:
   def __init__(self):
      raise Exception("Please do not init me!")

   def generic(fileContents,key):
      search = re.findall(r''+key+'.*=.*\n',fileContents)[0][:-1]
      search = search[search.rfind('=')+1:].strip()
      return search

   def genericFloat(fileContents,key):
      search = Parser.generic(fileContents,key)
      commentPos = search.rfind('//')
      if commentPos>0:
         search = search[:search.rfind('//')].strip()
      return float(search)

   def shortname(filename):
      key = "\\GameData\\"
      idx = filename.find(key)+len(key)-1
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


class Engine:
   def __init__(self, filename, fileContents, IntakeAir_count, LiquidFuel_count, Oxidizer_count):

      self.filename = filename
      self.IntakeAir_count = IntakeAir_count
      self.LiquidFuel_count = LiquidFuel_count
      self.Oxidizer_count = Oxidizer_count

      try:
         self.title = Parser.partTitle(fileContents)
      except:
         pass
      self.name = Parser.partName(fileContents)

      try:
         self.gimbalRange = Parser.partGimbalRange(fileContents)
      except:
         pass

      try:
         self.attachRules = Parser.partAttachRules(fileContents)
      except:
         pass

      self.atmosphereCurve = Parser.partAtmosphereCurve(fileContents)

      self.engineAccelerationSpeed = Parser.doubleValuesFromKeyValueAssignment(fileContents,'engineAccelerationSpeed')
      self.engineDecelerationSpeed = Parser.doubleValuesFromKeyValueAssignment(fileContents,'engineDecelerationSpeed')

   def __repr__(self):
      if hasattr(self,'title'):
         return self.title
      else:
         return "Unknown Title"


class Antenna:
   def __init__(self, filename, fileContents):
      self.filename = filename

      try:
         self.title = Parser.partTitle(fileContents)
      except:
         pass
      self.name = Parser.partName(fileContents)

      # TODO
      # antennaType
      # antennaCombinable

      self.antennaPower = int(Parser.genericFloat(fileContents,"antennaPower"))
      self.packetResourceCost = int(Parser.genericFloat(fileContents,"packetResourceCost"))
      self.packetSize = int(Parser.genericFloat(fileContents,"packetSize"))
      self.packetInterval = Parser.genericFloat(fileContents,"packetInterval")
      self.mass = Parser.genericFloat(fileContents,"mass")

      try:
         self.attachRules = Parser.partAttachRules(fileContents)
      except:
         pass


      # upper case fields for derived; lower case for raw
      self.ElectricChargePerSecond = self.packetResourceCost / self.packetInterval
      self.ElectricChargePerMits = self.packetResourceCost / self.packetSize
      self.Bandwidth = self.packetSize / self.packetInterval

   def __repr__(self):
      if hasattr(self,'title'):
         return self.title
      else:
         return "Unknown Title"


class FuelTank:
   def __init__(self, filename, fileContents):
      self.filename = filename

      try:
         self.title = Parser.partTitle(fileContents)
      except:
         pass
      self.name = Parser.partName(fileContents)

      try:
         self.mass = Parser.genericFloat(fileContents,"mass")
      except:
         pass

      try:
         self.attachRules = Parser.partAttachRules(fileContents)
      except:
         pass

      try:
         self.maxTemp = Parser.genericFloat(fileContents,"maxTemp")
      except:
         self.maxTemp = None

      try:
         self.skinMaxTemp = Parser.genericFloat(fileContents,"skinMaxTemp")
         print("skinMaxTemp!",filename)
      except:
         self.skinMaxTemp = None




   def __repr__(self):
      if hasattr(self,'title'):
         return self.title
      else:
         return "Unknown Title: " + self.name





def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

interestingParts = []

for filename in glob.iglob('../../GameData/**/*.cfg', recursive=True):
   abspath = os.path.abspath(filename)
   interestingParts.append(abspath)



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

fuelTanks = []

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

      resource_count = len(re.findall(r'RESOURCE',fileContents))


      # and LiquidFuel_count>=Oxidizer_count
      if ModuleEnginesFX_count>0 and LiquidFuel_count>0:
         engineObject = Engine(filename, fileContents, IntakeAir_count,LiquidFuel_count,Oxidizer_count)
         engineObjects.append(engineObject)

      if relayAntenna_count>0:
         relayAntenna = Antenna(filename,fileContents)
         relayAntennas.append(relayAntenna)

      if LiquidFuel_count>0 and Oxidizer_count>0 and resource_count>=2 and ModuleEnginesFX_count is 0:
         fuelTank = FuelTank(filename,fileContents)
         fuelTanks.append(fuelTank)

   except Exception as e:
      if checkIfImportantFileName(filename):
         failedFiles.append(Parser.shortname(filename))
         eprint(Parser.shortname(filename))
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
      print(Parser.shortname(engine.filename))
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

def displayRelayAntennaData():
   print(" ")
   for antenna in sorted(relayAntennas,key=lambda antenna: antenna.ElectricChargePerMits):
      if antenna.antennaPower>=2e+9:
         print(antenna)
         print('antennaPower', '%.0E' % antenna.antennaPower)
         print('Electric/Mits',antenna.ElectricChargePerMits)
         #print('Bandwidth',antenna.Bandwidth)
         #print('Electric Charge/sec',antenna.ElectricChargePerSecond)
         print("")

   for antenna in sorted(relayAntennas,key=lambda antenna: antenna.antennaPower):
      if antenna.antennaPower>=2e+9:
         print(antenna, '%.0E' % antenna.antennaPower, antenna.ElectricChargePerMits, antenna.mass, sep="\t")



def displayFuelTankData():
   for fuelTank in sorted(fuelTanks,key=lambda fuelTank: fuelTank.maxTemp or -1):
      if fuelTank.skinMaxTemp is None:
         pass
      print(fuelTank)
      print(Parser.shortname(fuelTank.filename))
      print(fuelTank.maxTemp)
      print("")




displayEngineData()
displayFuelTankData()
print('end of file')

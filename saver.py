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

# TODO: put this on its own git repository

files2watch = dict.fromkeys([
    r"..\..\saves\2018 Sept 16a\quicksave.sfs",
    r"..\..\saves\2018 Sept 16a\persistent.sfs",
    r"..\..\saves\CHEAT 2018 Sept 16a CHEAT\quicksave.sfs",
    r"..\..\saves\CHEAT 2018 Sept 16a CHEAT\persistent.sfs"
    ])

def lastModified(path):
    return os.path.getmtime(path)

def hashSha1(readFile):
    return hashlib.sha1(readFile).hexdigest()

def findSave(name):
    #print(name)

    dirname = os.path.dirname(name)
    maxFound = -1

    prefix1 = os.path.basename(name)[0] + '_'
    search = os.path.join( dirname , prefix1 + "*.sfs" )
    for file in glob.glob(search):
        basename = os.path.basename(file)
        digits = re.findall(r'\d+',basename)
        if (len(digits)==1):
            num = int(digits[0])
            if num>maxFound:
                maxFound = num

    prefix2 = "$" + os.path.basename(name)[:5] + '_'
    search = os.path.join( dirname , prefix2 + "*.sfs" )
    for file in glob.glob(search):
        basename = os.path.basename(file)
        digits = re.findall(r'\d+',basename)
        if (len(digits)==1):
            num = int(digits[0])
            if num>maxFound:
                maxFound = num
                
    search = os.path.join( dirname , "$*_*.sfs" )
    for file in glob.glob(search):
        basename = os.path.basename(file)
        digits = re.findall(r'\d+',basename)
        if (len(digits)==1):
            num = int(digits[0])
            if num>maxFound:
                maxFound = num
    
    maxFound = 1 + maxFound
    #print("maxFound :" , maxFound)

    maxFound = str(maxFound).zfill(6)
    newFile = prefix2 + maxFound + ".sfs"
    print(maxFound,newFile)
    new = os.path.join( dirname , newFile )
    return new

    

def scan():
    for key, value in files2watch.items():

        #print(key)

        lastMod = lastModified(key)
        
        currentFile = open(key,'rb').read()
        #print(type(currentFile))

        sha1 = hashSha1(currentFile)

        #print( sha1,lastMod, len(currentFile) )

        if (value is None):
            files2watch[key] = sha1
            
        elif (value != sha1):
            winsound.Beep(120,60)
            print( "change detected :", key )
            newsave = findSave(key)
            print( "new save name   :" + newsave )

            #shutil.copy2(key,newsave)
            
            fout = open(newsave, 'wb')
            fout.write(currentFile)
            fout.close()

            files2watch[key] = sha1
            winsound.Beep(320,60)


def scanThread():
    threading.Timer(3.0,scanThread).start()

    scan()


scanThread()

print("Scanning started")


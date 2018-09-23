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
    r"..\..\saves\2018 Sept 16a\persistent.sfs"
    ])

def lastModified(path):
    return os.path.getmtime(path)

def hashSha1(readFile):
    return hashlib.sha1(readFile).hexdigest()

def findSave(name):
    #print(name)

    dirname = os.path.dirname(name)
    prefix = os.path.basename(name)[0] + '_'
    print("dirname :", dirname, " prefix :", prefix )

    maxFound = -1

    search = os.path.join( dirname , prefix + "*.sfs" )
    #print(search)
    for file in glob.glob(search):
        basename = os.path.basename(file)
        #print(file)
        digits = re.findall(r'\d+',basename)
        print(digits)
        if (len(digits)==1):
            num = int(digits[0])
            #print(num)
            if num>maxFound:
                maxFound = num
    
    maxFound = 1 + maxFound
    print("maxFound :" , maxFound)

    maxFound = str(maxFound).zfill(6)
    new = os.path.join( dirname , prefix + maxFound + ".sfs" )
    return new

    

def scan():
    for key, value in files2watch.items():

        #print(key)

        lastMod = lastModified(key)
        
        currentFile = open(key,'rb').read()

        sha1 = hashSha1(currentFile)

        #print( sha1,lastMod, len(currentFile) )

        if (value is "None") or (value != sha1):
            winsound.Beep(120,60)
            print( "key :", key )
            newsave = findSave(key)
            print( "findSave :" + newsave )

            shutil.copy2(key,newsave)

            files2watch[key] = sha1
            winsound.Beep(320,60)


def scanThread():
    threading.Timer(3.0,scanThread).start()

    scan()


scanThread()

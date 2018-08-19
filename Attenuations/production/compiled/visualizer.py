# http://pillow.readthedocs.io/en/3.0.x/
from PIL import Image
import numpy as np
import datetime
import sys

size = 1000
window = (750, 750)
testTrace = './Data/savedPlate'
time = datetime.datetime.now().strftime('%s')
savedStr = './Images/image_' + time + '.png'
checkSumMsg = "Test Trace Fails CheckSum: %.9f instead of %.9f"
checkSumVal = 14365.942363022965

def checkSum(ary):
  sumAry = sum(ary)
  if (len(sys.argv) == 1) and (sumAry != checkSumVal):
    print(checkSumMsg % (sumAry, checkSumVal))

def renderBlackWhite(t, ary, mm): # RGB
  val = ary[t]
  if val <= 0: return((0,0,0))
  else:
    normedV = int(255 * (1 - val/mm))
    return(normedV, normedV, normedV)

def renderFalseColor(t, ary, mm): # RGB
  val = ary[t]
  if val <= 0: return((0,0,0))
  else:
    unit = (1 - val/mm)
    (r,g,b) = circleToRGB(unit)
    return(int(255*r), int(255*g), int(255*b))

def norm(x1,y1,x2,y2):
  return(np.sqrt((x1-x2)**2 + (y1-y2)**2))

def circleToRGB(t):
  (x, y) = (np.cos(t), np.sin(t))
  (c, d) = (np.sqrt(3)/2, -0.5)
  r = norm(x,y, 0,1)
  g = norm(x,y,-c,d)
  b = norm(x,y, c,d)
  return(r,g,b)

def renderImage(filename):
  ary = np.loadtxt(filename, dtype='d')
  img = Image.new('RGB',(size, size), 0)
  px = img.load()
  checkSum(ary)

  mm = np.amax(ary) # normalize photo luminosity.
  for t in range(0, size**2): # value to pixel
    px[t % size, t // size] = renderFalseColor(t, ary, mm)
    # px[t % size, t // size] = renderBlackWhite(t, ary, mm)

  resized = img.resize(window)
  resized.save(savedStr)
  resized.show()


renderImage(testTrace)

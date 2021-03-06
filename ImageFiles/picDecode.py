import base64
import sys

# =========================================================================
# This is a simply function to take in a compressed JPG image as a text 
# file and save it as an image file.
#
# Usage:
# In MATLAB - commandStr = 'python PATHTOSCRIPT/picDecode.py PICFILENAME';
#             [status, commandOut] = system(commandStr);
# 	The 'status' variable will be 0 if the picture is successfully decoded
#   The 'commandOut' variable will contain error text if there was one
#
# =========================================================================

with open("ImageFiles\\picString.txt") as picFile:
    content = picFile.read()

picFileName = "ImageFiles\\" + sys.argv[1] + ".jpg"
	
pic = open( picFileName, "wb")
pic.write(content.decode('base64'))
pic.close()
picFile.close()
exit

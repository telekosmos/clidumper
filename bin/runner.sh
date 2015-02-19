
# This system script forwards the parameters to the real node program
# Actually the parameters will be reduced to a file with tasks, gulp style
# Tasks will be just parameters to develop downloads, defined as a json file
# This file will contains an array [...] where each element is an object
# with the parameters to perform a download

# for windows is %* instead $*
node main.js $*
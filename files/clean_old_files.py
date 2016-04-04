#!/usr/bin/python

# FILE:         /opt/endit/clean_old_files.py
#
# DESCRIPTION:  
#
# VERSION:      29.11.2013
#
# AUTOR:        Cristina Manzano
#               Juelich Supercomputing Centre (JSC)
#               Forschungszentrum Juelich GmbH
#               52425 Juelich, Germany
#
#               Phone: +49 2461 61 1958
#               E-mail: c.manzano@fz-juelich.de
#
# TO DO:
# -

import os
import logging

# set up logging to file - see previous section for more details
logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(levelname)-6s %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                    filename='/tmp/clean_old_files.log',
                    filemode='a')

# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.StreamHandler()
console.setLevel(logging.INFO)
# set a format which is simpler for console use
formatter = logging.Formatter('%(asctime)s %(levelname)-6s %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
# tell the handler to use this format
console.setFormatter(formatter)
# add the handler to the root logger
logging.getLogger('').addHandler(console)

def delete(filename):

    outfile = "/tmp/deleted_files.out"
    request = "rm -f /pool01/in/"+filename

    logging.info(request)
 
    os.system(request+" 2>&1 >> "+outfile)

    input_f = open(outfile, "r")
    logging.info(input_f.read())
    input_f.close()

    return

#MAIN

#input_f = open("/var/log/dcache/pool01_in_short.out","r")
#input_f = open("/var/log/dcache/pool01_in.out.09.12.2013","r")
input_f = open("/var/log/dcache/files_to_delete.24.03.2014","r")
for line in input_f:
    words = line.split("\n")
    filename = words[0]
    delete(filename)
input_f.close()

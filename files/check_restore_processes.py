#!/usr/bin/python

# FILE:         /opt/endit/check_restore_processes.py
#
# DESCRIPTION:  
#
# VERSION:      06.12.2013
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
                    filename='/tmp/checking.log',
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

def check_process(pnfsid):

    outfile = "/tmp/checking.out"
    request = "ps -ef |grep "+pnfsid

    logging.info(request)

    #os.system("rm -f "+outfile) 
    os.system(request+" 2>&1 > "+outfile)

    input_f = open(outfile, "r")
    logging.info(input_f.read())
    input_f.close()

    return

#MAIN

#input_f = open("/var/log/dcache/files_dC12_CACHED","r")
input_f = open("/var/log/dcache/files_to_delete.24.03.2014","r")
for line in input_f:
    words = line.split("\n")
    pnfsid = words[0]
    check_process(pnfsid)
input_f.close()

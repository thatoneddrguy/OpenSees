#!/usr/bin/python
if __name__ == '__main__':
  import sys
  import os
  sys.path.insert(0, os.path.abspath('config'))
  import configure
  configure_options = [
    '--prefix=/home/linuxbrew/.linuxbrew/Cellar/petsc/3.10.3_2',
    '--with-debugging=0',
    '--with-scalar-type=real',
    '--with-x=0',
    'PETSC_ARCH=arch-linux2-c-opt',
  ]
  configure.petsc_configure(configure_options)

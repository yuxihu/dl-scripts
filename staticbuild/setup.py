# pylint: disable=invalid-name, exec-used
"""Setup mxnet package."""
from __future__ import absolute_import
from datetime import datetime
import os
import sys
import shutil

sys.argv.append('--universal')
sys.argv.append('--plat-name=manylinux1_x86_64')

from setuptools import setup, find_packages

# We can not import `mxnet.info.py` in setup.py directly since mxnet/__init__.py
# Will be invoked which introduces dependences
CURRENT_DIR = os.path.dirname(__file__)
libinfo_py = os.path.join(CURRENT_DIR, 'mxnet-build/python/mxnet/libinfo.py')
libinfo = {'__file__': libinfo_py}
exec(compile(open(libinfo_py, "rb").read(), libinfo_py, 'exec'), libinfo, libinfo)

LIB_PATH = libinfo['find_lib_path']()
__version__ = libinfo['__version__'] + 'b{0}'.format(datetime.today().strftime('%Y%m%d'))

DEPENDENCIES = [
    'numpy<1.15.0,>=1.8.2',
    'requests>=2.20.0',
    'graphviz<0.9.0,>=0.8.1'
]

shutil.rmtree(os.path.join(CURRENT_DIR, 'mxnet'), ignore_errors=True)
shutil.rmtree(os.path.join(CURRENT_DIR, 'dmlc_tracker'), ignore_errors=True)
shutil.copytree(os.path.join(CURRENT_DIR, 'mxnet-build/python/mxnet'),
                os.path.join(CURRENT_DIR, 'mxnet'))
shutil.copytree(os.path.join(CURRENT_DIR, 'mxnet-build/3rdparty/dmlc-core/tracker/dmlc_tracker'),
                os.path.join(CURRENT_DIR, 'dmlc_tracker'))
shutil.copy(LIB_PATH[0], os.path.join(CURRENT_DIR, 'mxnet'))

# copy tools to mxnet package
shutil.rmtree(os.path.join(CURRENT_DIR, 'mxnet/tools'), ignore_errors=True)
os.mkdir(os.path.join(CURRENT_DIR, 'mxnet/tools'))
shutil.copy(os.path.join(CURRENT_DIR, 'mxnet-build/tools/launch.py'), os.path.join(CURRENT_DIR, 'mxnet/tools'))
shutil.copy(os.path.join(CURRENT_DIR, 'mxnet-build/tools/im2rec.py'), os.path.join(CURRENT_DIR, 'mxnet/tools'))
shutil.copy(os.path.join(CURRENT_DIR, 'mxnet-build/tools/kill-mxnet.py'), os.path.join(CURRENT_DIR, 'mxnet/tools'))
shutil.copy(os.path.join(CURRENT_DIR, 'mxnet-build/tools/parse_log.py'), os.path.join(CURRENT_DIR, 'mxnet/tools'))
shutil.copy(os.path.join(CURRENT_DIR, 'mxnet-build/tools/diagnose.py'), os.path.join(CURRENT_DIR, 'mxnet/tools'))
shutil.copytree(os.path.join(CURRENT_DIR, 'mxnet-build/tools/caffe_converter'), os.path.join(CURRENT_DIR, 'mxnet/tools/caffe_converter'))
shutil.copytree(os.path.join(CURRENT_DIR, 'mxnet-build/tools/bandwidth'), os.path.join(CURRENT_DIR, 'mxnet/tools/bandwidth'))

# copy headers to mxnet package
shutil.rmtree(os.path.join(CURRENT_DIR, 'mxnet/include'), ignore_errors=True)
os.mkdir(os.path.join(CURRENT_DIR, 'mxnet/include'))
shutil.copytree(os.path.join(CURRENT_DIR, 'mxnet-build/include/mxnet'),
                os.path.join(CURRENT_DIR, 'mxnet/include/mxnet'))
shutil.copytree(os.path.join(CURRENT_DIR, 'mxnet-build/3rdparty/dlpack/include/dlpack'),
                os.path.join(CURRENT_DIR, 'mxnet/include/dlpack'))
shutil.copytree(os.path.join(CURRENT_DIR, 'mxnet-build/3rdparty/dmlc-core/include/dmlc'),
                os.path.join(CURRENT_DIR, 'mxnet/include/dmlc'))
shutil.copytree(os.path.join(CURRENT_DIR, 'mxnet-build/3rdparty/mshadow/mshadow'),
                os.path.join(CURRENT_DIR, 'mxnet/include/mshadow'))
shutil.copytree(os.path.join(CURRENT_DIR, 'mxnet-build/3rdparty/tvm/nnvm/include/nnvm'),
                os.path.join(CURRENT_DIR, 'mxnet/include/nnvm'))
shutil.copytree(os.path.join(CURRENT_DIR, 'mxnet-build/3rdparty/mkldnn/include'),
                os.path.join(CURRENT_DIR, 'mxnet/include/mkldnn'))

package_name = 'mxnet'

variant = os.environ['mxnet_variant'].upper()
if variant != 'CPU':
    package_name = 'mxnet_{0}'.format(variant.lower())
package_name += '_gcc5'

# pypi only supports rst, so use pandoc to convert
import pypandoc

short_description = 'MXNet is an ultra-scalable deep learning framework.'
package_data = {'mxnet': [os.path.join('mxnet', os.path.basename(LIB_PATH[0]))],
                'dmlc_tracker': []}
if variant.endswith('MKL'):
    shutil.copy(os.path.join(os.path.dirname(LIB_PATH[0]), 'libmklml_intel.so'), os.path.join(CURRENT_DIR, 'mxnet'))
    shutil.copy(os.path.join(os.path.dirname(LIB_PATH[0]), 'libiomp5.so'), os.path.join(CURRENT_DIR, 'mxnet'))
    shutil.copy(os.path.join(os.path.dirname(LIB_PATH[0]), 'libmkldnn.so.0'), os.path.join(CURRENT_DIR, 'mxnet'))
    package_data['mxnet'].append('mxnet/libmklml_intel.so')
    package_data['mxnet'].append('mxnet/libiomp5.so')
    package_data['mxnet'].append('mxnet/libmkldnn.so.0')
    shutil.copy(os.path.join(os.path.dirname(LIB_PATH[0]), '../MKLML_LICENSE'), os.path.join(CURRENT_DIR, 'mxnet'))
    package_data['mxnet'].append('mxnet/MKLML_LICENSE')

shutil.copy(os.path.join(os.path.dirname(LIB_PATH[0]), 'libgfortran.so.3'), os.path.join(CURRENT_DIR, 'mxnet'))
package_data['mxnet'].append('mxnet/libgfortran.so.3')
shutil.copy(os.path.join(os.path.dirname(LIB_PATH[0]), 'libquadmath.so.0'), os.path.join(CURRENT_DIR, 'mxnet'))
package_data['mxnet'].append('mxnet/libquadmath.so.0')

setup(name=package_name,
      version=__version__,
      description=short_description,
      zip_safe=False,
      packages=find_packages(),
      package_data=package_data,
      include_package_data=True,
      install_requires=DEPENDENCIES,
      license='Apache 2.0',
      url='https://github.com/apache/incubator-mxnet',
      classifiers=[ # https://pypi.org/pypi?%3Aaction=list_classifiers
          'Development Status :: 5 - Production/Stable',
          'Intended Audience :: Developers',
          'Intended Audience :: Education',
          'Intended Audience :: Science/Research',
          'License :: OSI Approved :: Apache Software License',
          'Programming Language :: C++',
          'Programming Language :: Cython',
          'Programming Language :: Other',  # R, Scala
          'Programming Language :: Perl',
          'Programming Language :: Python',
          'Programming Language :: Python :: 2.7',
          'Programming Language :: Python :: 3.4',
          'Programming Language :: Python :: 3.5',
          'Programming Language :: Python :: 3.6',
          'Programming Language :: Python :: Implementation :: CPython',
          'Topic :: Scientific/Engineering',
          'Topic :: Scientific/Engineering :: Artificial Intelligence',
          'Topic :: Scientific/Engineering :: Mathematics',
          'Topic :: Software Development',
          'Topic :: Software Development :: Libraries',
          'Topic :: Software Development :: Libraries :: Python Modules',
      ])

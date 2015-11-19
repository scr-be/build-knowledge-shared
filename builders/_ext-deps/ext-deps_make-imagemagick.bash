#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

SCRIPT_SELF_SPATH="${0}"
SCRIPT_SELF_RPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2> /dev/null && pwd)"
SCRIPT_SELF_NAME="$(basename ${SCRIPT_SELF_SPATH} 2> /dev/null)"
SCRIPT_SELF_ROOT="$(pwd)"
SYS_REQ="$(basename ${SCRIPT_SELF_BASE:14} .bash)"

type outLines &>> /dev/null || . ${SCRIPT_SELF_RPATH}/../_common/bash-inc_all.bash

${CMD_PRE} apt-get install build-essential;
sudo apt-get build-dep imagemagick;
sudo apt-get install libautotrace3 libautotrace-dev autotrace ghostscript gsfonts libgs-dev pslib1 libopenjpeg-dev libopenjp2-7-dev libjxr-dev libhpdf-dev libfreeimage-dev libwebp-dev libexif-dev libjasper-dev libjpeg-dev libjpeg-turbo8-dev libjpeg8-dev libgd-dev libpng12-dev libpng++-dev libpnglite-dev libfftw3-dev libfftw3-quad3 libgxps-dev libgxps-utils liblcms2-dev liblcms2-utils gir1.2-rsvg-2.0 libgc1c2 libgraphviz-dev libgsl0ldbl libgtkspell0 liblqr-1-0-dev libnetpbm10 libplot-dev libplot2c2 librsvg2-dev libwmf-bin libwmf-dev libxaw7-dev libxdot4 libxmu-dev libxmu-headers netpbm checkinstall automake autoconf libtool pkg-config checkinstall;

wget http://www.imagemagick.org/download/ImageMagick.tar.bz2
tar xjf ImageMagick-*.tar.bz2 && cd ImageMagick-*/

./configure CXXFLAGS="-march=native -g -O2" CPPFLAGS="-march=native -g -O2" --with-autotrace --with-webp --with-rsvg --with-gslib --with-jbig --with-jpeg --with-jp2 --enable-hdri --with-quantum-depth=32 --with-modules --with-fftw --with-perl
make

/sbin/ldconfig /usr/local/lib

# EOF #

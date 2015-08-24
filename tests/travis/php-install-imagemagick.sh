sudo apt-get install build-essential;
sudo apt-get build-dep imagemagick;
sudo apt-get install libautotrace3 libautotrace-dev autotrace ghostscript gsfonts libgs-dev pslib1 libopenjpeg-dev libopenjp2-7-dev libjxr-dev libhpdf-dev libfreeimage-dev libwebp-dev libexif-dev libjasper-dev libjpeg-dev libjpeg-turbo8-dev libjpeg8-dev libgd-dev libpng12-dev libpng++-dev libpnglite-dev libfftw3-dev libfftw3-quad3 libgxps-dev libgxps-utils liblcms2-dev liblcms2-utils gir1.2-rsvg-2.0 libgc1c2 libgraphviz-dev libgsl0ldbl libgtkspell0 liblqr-1-0-dev libnetpbm10 libplot-dev libplot2c2 librsvg2-dev libwmf-bin libwmf-dev libxaw7-dev libxdot4 libxmu-dev libxmu-headers netpbm checkinstall automake autoconf libtool pkg-config checkinstall;

wget http://mirrors-usa.go-parts.com/mirrors/ImageMagick/ImageMagick-6.9.1-9.tar.bz2
tar xjf ImageMagick-6.9.1-9.tar.bz2
cd ImageMagick-6.9.1-9/

./configure CXXFLAGS="-march=native -g -O2" CPPFLAGS="-march=native -g -O2" --with-autotrace --with-webp --with-rsvg --with-gslib --with-jbig --with-jpeg --with-jp2 --enable-hdri --with-quantum-depth=32 --with-modules --with-fftw --with-perl
make

/sbin/ldconfig /usr/local/lib
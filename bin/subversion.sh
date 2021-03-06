#!/bin/bash

export VERSION=1.4.6
export GXX=yes
export PERL=/usr/local/bin/perl
export PYTHON2=/usr/bin/python
export RUBY=/usr/bin/ruby

. `dirname $0`/functions.sh

if [ -f /usr/local/bin/svn ]; then
    if [ `/usr/local/bin/svn --version --quiet` = "$VERSION" ]; then
        exit
    fi
fi

setup

# Download the Subversion dependencies.
rm -rf subversion-$VERSION
download http://subversion.tigris.org/tarballs/subversion-deps-$VERSION.tar.bz2
tar jxf subversion-deps-$VERSION.tar.bz2 || exit $?

# Install Subversion
download http://subversion.tigris.org/tarballs/subversion-$VERSION.tar.bz2
tar jxf subversion-$VERSION.tar.bz2 || exit $?
cd subversion-$VERSION
./configure \
  --enable-shared \
  --with-ssl \
  --with-apr=/usr/local/apache2 \
  --with-apr-util=/usr/local/apache2 \
  --with-apxs=/usr/local/apache2/bin/apxs || exit $?
make -j3 || exit $?
make install || exit $?
# Perl bindings fail. http://subversion.tigris.org/issues/show_bug.cgi?id=3165
# make swig-pl || exit $?
# make check-swig-pl || exit $?
# make install-swig-pl || exit $?
make -j3 swig-py || exit $?
make check-swig-py || exit $?
make install-swig-py || exit $?
make -j3 swig-rb || exit $?
# As of now, the ruby tests fail because there is no bdb, but it's not important.
make check-swig-rb
make install-swig-rb || exit $?
cp tools/backup/hot-backup.py /usr/local/bin
if [ ! -e /usr/lib/python2.5/site-packages/libsvn ]; then
    ln -s /usr/local/lib/svn-python/libsvn /usr/lib/python2.5/site-packages
fi
if [ ! -e /usr/lib/python2.5/site-packages/svn ]; then
    ln -s /usr/local/lib/svn-python/svn /usr/lib/python2.5/site-packages
fi
/sbin/ldconfig
cd ..

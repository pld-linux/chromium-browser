#!/bin/bash

# This script checks out chromium source from svn, using the gclient tool.

LOCALDIR=`pwd`
REMOVE=false
TODAYSDATE=`date +%Y%m%d`
USAGE="Usage: chromium-daily-tarball.sh [-hrv]"
VERBOSE=false


while getopts "hrv" opt; do
   case $opt in
      h  ) printf "$USAGE\n"
           printf "\nAvailable command line options:\n"
           printf "%b\t-h\t\tthis help\n"
           printf "%b\t-r\t\tremove conflicting chromium files/directories\n"
           printf "%b\t-v\t\tverbose output\n\n"
           exit 1 ;;
      r  ) REMOVE=true ;;
      v  ) VERBOSE=true
           printf "[VERBOSE]: Enabled\n" ;;
      \? ) printf "$USAGE\n"
           exit 1 ;;
   esac
done

# Prerequisites:
#  gclient
printf "Looking for gclient in your PATH: " 
which gclient
RETVAL=$?
if [ $RETVAL -ne 0 ]; then
   printf "[ERROR]: Could not find gclient in PATH. Please install it first.\n"
   exit 2
else
   printf "Found it! Lets get to work.\n"
fi


# First, lets look for the directory, without svnrev.
if [ -d chromium-$TODAYSDATE ]; then
   if [ "$REMOVE" = "true" ]; then
      if [ "$VERBOSE" = "true" ]; then
         printf "[VERBOSE]: Removing conflicting directory: chromium-$TODAYSDATE/\n"
      fi
      rm -rf chromium-$TODAYSDATE/
      if [ "$VERBOSE" = "true" ]; then
         printf "[VERBOSE]: Removed conflicting directory: chromium-$TODAYSDATE/\n"
      fi
   else
      printf "[ERROR]: chromium-$TODAYSDATE/ exists, use -r option to remove it\n"
      exit 2
   fi
fi

# At this point, we know the chromium daily directory does not exist, time to make it.
if [ "$VERBOSE" = "true" ]; then
   printf "[VERBOSE]: Creating directory: chromium-$TODAYSDATE/\n"
fi
mkdir -p chromium-$TODAYSDATE

# go into the chromium dir
pushd chromium-$TODAYSDATE/

# Make the gclient config
if [ "$VERBOSE" = "true" ]; then
   printf "[VERBOSE]: Generating gclient config\n"
fi

gclient config http://src.chromium.org/svn/trunk/src

# We rewrite .gclient to take out the LayoutTests for size considerations
cat > .gclient <<'EOF'
# An element of this array (a "solution") describes a repository directory
# that will be checked out into your working copy.  Each solution may
# optionally define additional dependencies (via its DEPS file) to be
# checked out alongside the solution's directory.  A solution may also
# specify custom dependencies (via the "custom_deps" property) that
# override or augment the dependencies specified by the DEPS file.
# If a "safesync_url" is specified, it is assumed to reference the location of
# a text file which contains nothing but the last known good SCM revision to
# sync against. It is fetched if specified and used unless --head is passed
solutions = [
  { "name"        : "src",
    "url"         : "http://src.chromium.org/svn/trunk/src",
    "custom_deps" : {
      # To use the trunk of a component instead of what's in DEPS:
      #"component": "https://svnserver/component/trunk/",
      # To exclude a component from your working copy:
      #"data/really_large_component": None,
      "src/webkit/data/layout_tests/LayoutTests": None,
    },
    "safesync_url": ""
  }
]
EOF

printf "Checking out the source tree. This will take some time.\n"

if [ "$VERBOSE" = "true" ]; then
   gclient sync --force
else
   gclient sync --force 2>&1 >/dev/null
fi

# Determine SVN rev of chromium (we don't care about the other sub-checkouts)
pushd src/chrome
SVNREV=`svnversion`   
popd

printf "Chromium svn$SVNREV [$TODAYSDATE] checked out\n"

FULLVER=`echo ${TODAYSDATE}svn${SVNREV}`

# Remove third party bits that we have on the system
if [ "$VERBOSE" = "true" ]; then
   printf "[VERBOSE]: Removing unnecessary third_party bits\n"
fi
pushd src/third_party
rm -rf bzip2/ libevent/ libjpeg/ libpng/ libxml/ libxslt/ nss/ nspr/ zlib/
popd

# Get rid of .svn bits to save space
if [ "$VERBOSE" = "true" ]; then
   printf "[VERBOSE]: Removing unnecessary .svn bits\n"
fi
find src -depth -name .svn -type d -exec rm -rf {} \;

# Get rid of reference_build prebuilt binaries
if [ "$VERBOSE" = "true" ]; then
   printf "[VERBOSE]: Removing reference_build prebuilt binaries\n"
fi
find src -depth -name reference_build -type d -exec rm -rf {} \;

# Gclient embeds the full checkout path all over the .scons files. We'll replace it with a known dummy tree, which we can sed out
# in the rpm spec.
# FIXME: There has to be a better way to prevent this .scons mangling.
for i in `find . |grep "\.scons"`; do
   sed -i "s|$LOCALDIR/chromium-$TODAYSDATE/|/home/spot/sandbox/chromium-$TODAYSDATE/|g" $i
done

popd

# Now, lets look for the final target directory, without svnrev.
if [ -d chromium-$FULLVER ]; then
   if [ "$REMOVE" = "true" ]; then
      if [ "$VERBOSE" = "true" ]; then
         printf "[VERBOSE]: Removing conflicting directory: chromium-$FULLVER/\n"
      fi
      rm -rf chromium-$FULLVER/
      if [ "$VERBOSE" = "true" ]; then
         printf "[VERBOSE]: Removed conflicting directory: chromium-$FULLVER/\n"
      fi
   else
      printf "[ERROR]: chromium-$FULLVER/ exists, use -r option to remove it\n"
      exit 2
   fi
fi

# At this point, we know the chromium target directory does not exist, time to rename the checkout
if [ "$VERBOSE" = "true" ]; then
   printf "[VERBOSE]: Renaming checkout directory from: chromium-$TODAYSDATE/ to: chromium-$FULLVER/\n"
fi
mv chromium-$TODAYSDATE/ chromium-$FULLVER/

# Now, lets look for the tarball.
if [ -f chromium-$FULLVER.tar.bz2 ]; then
   if [ "$VERBOSE" = "true" ]; then
      printf "[VERBOSE]: Found tarball matching chromium-$FULLVER.tar.bz2\n"
   fi
   if [ "$REMOVE" = "true" ]; then
      if [ "$VERBOSE" = "true" ]; then
         printf "[VERBOSE]: Removing conflicting file: chromium-$FULLVER.tar.bz2\n"
      fi
      rm -f chromium-$FULLVER.tar.bz2
      if [ "$VERBOSE" = "true" ]; then
         printf "[VERBOSE]: Removed conflicting file: chromium-$FULLVER.tar.bz2\n"
      fi
   else
      printf "[ERROR]: chromium-$FULLVER.tar.bz2 exists, use -r option to remove it\n"
      exit 2
   fi
fi
         
if [ "$VERBOSE" = "true" ]; then
   printf "[VERBOSE]: Creating tarball: chromium-$FULLVER.tar.bz2\n"
fi
tar cfj chromium-$FULLVER.tar.bz2 chromium-$FULLVER

# All done.
printf "Daily chromium source processed and ready: chromium-$FULLVER.tar.bz2\n"
exit 0

###
# Build package with binaries for Windows
###

# Install this cross-compiler toolchain:
sudo apt-get install mingw-w64

# Ensure the target distribution directory exists before copying
mkdir -p build/Release/dist

# x86_64
mkdir build-mingw-64
cd build-mingw-64
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/modules/set_toolchain.cmake \
      -DCMAKE_SYSTEM_NAME=Windows \
      -DTOOLCHAIN_PREFIX=x86_64-w64-mingw32 \
      -DSTLINK_GENERATE_GUI=OFF \
      ..
make package
sudo cp dist/*.zip ../build/Release/dist
make clean
cd ..

# i686
mkdir build-mingw-32
cd build-mingw-32
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/modules/set_toolchain.cmake \
      -DCMAKE_SYSTEM_NAME=Windows \
      -DTOOLCHAIN_PREFIX=i686-w64-mingw32 \
      -DSTLINK_GENERATE_GUI=OFF \
      ..
make package
sudo cp dist/*.zip ../build/Release/dist
make clean
cd ..

#!/bin/bash
set -e

cd /tmp

# Realsense SDK
if [[ -d librealsense ]]; then
    rm -rf librealsense
fi

git clone https://github.com/IntelRealSense/librealsense.git -b v2.41.0
cd librealsense && mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_EXAMPLES=ON \
    -DBUILD_GRAPHICAL_EXAMPLES=OFF \
	-DBUILD_UNIT_TESTS=OFF \
	-DBUILD_INTERNAL_UNIT_TESTS=OFF \
	-DBUILD_PYTHON_BINDINGS=ON \
	-DBUILD_PYTHON_DOCS=OFF \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_UNITY_BINDINGS=OFF \
	-DBUILD_WITH_CUDA=OFF \
	-DCHECK_FOR_UPDATES=OFF \
	-DENABLE_ZERO_COPY=ON \
	-DIMPORT_DEPTH_CAM_FW=ON \
	-DFORCE_LIBUVC=OFF \
	-DFORCE_RSUSB_BACKEND=OFF ..
make -j$((`nproc` - 2))
make install

# add camera udev rules
../scripts/setup_udev_rules.sh

# Realsense ROS interface
mkdir -p /home/$FIRST_USER_NAME/ros_ws/src && cd /home/$FIRST_USER_NAME/ros_ws/src
git clone https://github.com/IntelRealSense/realsense-ros.git -b 2.2.21

cd /home/$FIRST_USER_NAME/ros_ws/src && catkin_init_workspace 
cd .. && catkin_make -DCMAKE_BUILD_TYPE=Release

if [[ ! -f /home/$FIRST_USER_NAME/.bashrc || ! `cat /home/$FIRST_USER_NAME/.bashrc | grep "source /home/$FIRST_USER_NAME/ros_ws/devel/setup.bash"` ]]; then
    echo "source /home/$FIRST_USER_NAME/ros_ws/devel/setup.bash" >> /home/$FIRST_USER_NAME/.bashrc
fi

echo "ROS workspace build complete, enjoy!"

# fix user permissions
chown -R $FIRST_USER_NAME:$FIRST_USER_NAME /home/$FIRST_USER_NAME


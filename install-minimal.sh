#!/bin/sh

set -e
PATH=/usr/bin:/usr/sbin

# helpers
msg() {
	printf "\033[1m$@\n\033[m"
}

err() {
	msg "ERROR $@"
	exit 1
}

step() {
	current_step=$((current_step+1))
	msg "[${current_step}/${step_count}] $@"
}

taskdir=$PWD/tasks
tdone() {
	touch $taskdir/$1
}

isdone() {
	test -f $taskdir/$1
}

# This portion of the script has to be run as root
install_deps() {
	step "Installing dependencies using xbps and pip"
	xbps-install -Sy $xbps_packages || [ $? -eq "17" -o $? -eq "6" ]
	pip install -U $pip_packages

	step "Building console_bridge from source"
	if ! isdone console_bridge ; then
		lpwd="$(pwd)"
		cbd=./console_bridge
		git clone https://github.com/ros/console_bridge $cbd && cd $cbd
		mkdir build && cd build
		cmake ..
		make && make install
		cd "$lpwd" && rm -rf $cbd
		tdone console_bridge
	fi

	step "Patching rospkg/os_detect.py"
	if ! isdone patch_os_detect ; then
		patch <./patches/os_detect.py.patch \
			/usr/lib/python2.7/site-packages/rospkg/os_detect.py
		tdone patch_os_detect
	fi

	step "rosdep init"
	if ! isdone rosdep_init ; then 
		rosdep init
		tdone rosdep_init
	fi
}

# This can be run without root priviliges
setup_ros() {
	step "rosdep update"
	if ! isdone rosdep_update ; then
		rosdep update
		tdone rosdep_update
	fi
	
	step "Initializing ROS workspace at $ros_ws"
	if ! isdone init_ws ; then
		# Create workspace to build ros in
		mkdir -p $ros_ws
		lpwd="$(pwd)"
		cd $ros_ws
		# Download ros sources using ros_install_generator and wstool
		rosinstall_generator ros_comm --rosdistro kinetic --deps --wet-only --tar > kinetic-ros_comm-wet.rosinstall
		wstool init -j8 src kinetic-ros_comm-wet.rosinstall
		cd "$lpwd"
		tdone init_ws
	fi
	
	step "Building ROS"
	cd $ros_ws
	./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release
	cd "$lpwd"
}

ros_ws=./ros_catkin_ws
xbps_packages='base-devel boost-devel bzip2-devel cmake git lz4-devel python-devel python-pip tinyxml-devel'
pip_packages='catkin_tools empy rosdep rosinstall rosinstall_generator wstool'
deps_taskfile=.deps_installed
current_step=0
step_count=7

# Check for root permissions.
if [ "$(id -u)" -ne 0 ] ; then
	[ -f $deps_taskfile ] || err "Must be run using sudo or as root, exiting..."

	current_step=4
	setup_ros
	rm -f $deps_taskfile

	msg "Installation done!"
	msg "To use ros you have to source the regarding setup file for bash/sh/zsh:"
	msg "source $ros_ws/install_isolated/setup.bash"
else
	mkdir -p $taskdir

	install_deps
	touch $deps_taskfile
	chown -R $SUDO_USER $taskdir

	# Drop root priviliges as they are no longer needed
	sudo -u $SUDO_USER $0
fi

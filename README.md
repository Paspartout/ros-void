ros-void
========

> scripts, notes and patches to install [ROS](http://www.ros.org/) Kinetic
> on [Void Linux](http://www.voidlinux.eu/).

This repository contains scripts to automatically install
[ROS Kinetic Kame](http://wiki.ros.org/kinetic) from source on the
Void Linux distribution.

Scripts
-------

### install-minimal.sh

This script installs all dependencies for ROS Kinetic in its minimal configuration.

To run the script you have to call it with root privileges.
The scripts drops it root privileges when called using sudo to create a
ROS workspace that is writable by the non-root user.

	$ sudo ./install-minimal.sh

Notes
-----

The scripts are mainly an automated way of installing ROS Kinetic from source.
It resembles the operations of the following guide in the ROS wiki:
[Installing from source](http://wiki.ros.org/kinetic/Installation/Source)

I had to manually install [`console_bridge`](https://github.com/ros/console_bridge) 
before building.
Also, [`rospkg/os_detect.py`](https://github.com/ros-infrastructure/rospkg/blob/master/src/rospkg/os_detect.py)
had to be patched in order to detect Void Linux as a valid OS.
See Patches below for the actual modifications.

It may be worth the work to add Void Linux as a rosdep platform.
Documentation and Tutorials about rosdep can also be found in
the ROS wiki: [rosdep](http://wiki.ros.org/rosdep/Tutorials)

Patches
-------

### os_detect.py.patch

This patch adds a detector class for Void Linux. Without this patch
rosdep won't accept Void Linux as a valid Linux distribution.

License
-------

ROS Kinetic, Void Linux and other software products used and listed in the
script have their respective licenses.

The scripts and this note itself is licensed under the MIT License:

```
MIT License

Copyright (c) 2016 Phileas Vöcking

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
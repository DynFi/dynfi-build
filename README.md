Build system for DynFi Firewall
===============================
 
This is a collection of build scripts for DynFi Firewall.
 
build\_base.sh
=============
 
The script is responsible for building FreeBSD kernel and world.
There are three supported options:   
- `-c` for building everything from scratch
- `-r` bootstrap a release (does make packages instead of update-packages)
- `-b` allows to change a FreeBSD branch (default: dynfi-13-stable)
 
Useful variables in common.subr:
- `FBSD_TREE` - the FreeBSD repo
- `FBSD_BRANCH` - the default branch                
- `MAKEOBJDIRPREFIX` - where to store obj file
 
build\_pacakges.sh
================= 
 
Script responsible for building packages.
Supported options:
- `-b` Git branch for the jail (default: dynfi-13-stable) 
- `-o` Ports tree to use for the overlays (default: dynfi-overlay) 
- `-p` Git branch for the portstree (default: default) 
- `-c` Recreate the jail 
 
Useful variables in common.subr:
- `PORT_BRANCH` - the default port branch
 
build\_installer.sh
==================
                               
Script building the installer.
 
Useful variables in common.subr:
- `IMAGE\_DIR` - where to store build images
                       
poudriere.sh           
============
 
The alias for poudriere, including the common.subr, work on a local instance of poudriere.
 
build\_sync.sh
============= 
 
Script for syncing the ports packages to a remote server.
 
How to build the project
========================
 
- First, you have to pull all required repos:
        - The FreeBSD repo used by Dyn
        - Dyn ports overlay 
- Change configuration if you fetched the repos to a different place.
  The file you have to modify is common.subr, and interesting values are:
        - `OVERLAY_PORTS` - is a directory where the dynfi-overlay repo is
        - `FBSD_TREE` - is a directory where is FreeBSD dir
- Next, you can use a `build_base.sh` script to build FreeBSD kernel and world 
- Next step is to build packages. The `build_packages.sh` script is responsible for that
- When you have a package, kernel and world, you can build install with `build_installer.sh`
- Finally, you can push the required repo to a remote server with the `build_sync.sh` script

Contribute
==========

Contribution are more then welcome.
We always looking for additional tests, bug request or pull requests via GitHub.
 
Licensing
=========
 
This project itself is licensed according to the two-clause BSD license.


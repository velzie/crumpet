# how to build your own rootfs
there is no automated build script, or any real way of making the builds reproducible, and while i apologize, you'll be able to see why i made that decision

this isn't an exhaustive tutorial, you just kinda have to know what you're doing and know what i'm talking about
## requirements
- linux (obviously)
- \>300gbs of free disk space on a specifically ext4 filesystem (yes, really)
- a modern enough cpu
- little to no remaining sanity
- far too much free time on your hand

first you need to get a full chromiumos checkout. follow this [guide](https://chromium.googlesource.com/chromiumos/docs/+/HEAD/developer_guide.md) until you get to the point where you run "cros_sdk", after you run that stop and return here

now, enter the chroot and cd to `~/chromiumos/src`, setup with `gclient config` and `gclient sync` to acquire the remaining little bits of source code

now go ahead and build a full chromiumos devimage. this will take a decent amount of time
```
cros build-packages --board=amd64-generic
cros build-image --board=amd64-generic  --no-enable-rootfs-verification dev
```
once that's done, extract the image it gives you into a rootfs:
```
cd ~/chromiumos/src/build/images/amd64-generic/latest
./unpack_partitions.sh 
```
mount part_1 somewhere, and mount part_3 somewhere else

copy everything from where you mounted part_3 (make sure to copy with the preserve argument, and as root) to a new folder, that will be your rootfs

in the place you mounted part_1, there will be a directory called "dev_image". copy everything in there to /usr/local *in your rootfs folder containing the copied contents of part_3*. you may now delete all the part_* files and the entirety of `/build/amd64-generic` if you're running low on space
 
 now that you have the basis for the chroot environment, you'll have to build chrome.
 staying inside the cros_sdk chroot, head over to `~/chromiumos/src/chromium/src`

run `gn args out/ash`, and in the vim window that shows up paste the argument list i specify in "args.gn" in the root of this repository.
now you can run `nice ../depot_tools/autoninja -j32 -C out/ash chrome`. adjust -j32 if you have a better or worse cpu than me. i reccommend killing off the desktop environment/display manager and booting a plain TTY for this step 

now, because of the failures of c++ as a language, wait several days for compilation and linking to finish, dependi ng on your cpu. of course if you have access to a google build farm you can use it with the `goma=true` argument

return back to this guide after it compiles, and get ready for the next step. 

go back to the "rootfs" folder you created earlier by merging part_1 and part_3, and `rm -rf /opt/google/chrome/*`, we won't be needing it.
instead, replace it by copying in the contents of the `out/ash` thingy we just built. you can rm -rf gen/ and obj/

rename the `chrome` binary to `chrome_silly` (we need a way of differentiating the process names)

if you feel inclined, at this point you can move the rootfs folder somewhere safe and nuke the entirety of your cros_sdk chroot, we won't need it anymore i think

setup bindmounts for /proc, /dev, and /sys, and chroot into the `rootfs` folder that we've created, and fix the path for good measure
```
export LD_LIBRARY_PATH=/opt/google/chrome:/usr/local/lib64
export PATH=/usr/local/bin/:/usr/local/sbin/:/usr/bin/:/usr/sbin/:/bin/:/sbin/ 
```
you'll notice that the chrome binary doesn't actually run, missing shared libraries and whatnot.
there are a few ways of getting these libraries, but the best way i found is through chromebrew.

pick it up [here](https://github.com/chromebrew/chromebrew). the chromebrew developers are wimps and don't want you to run it as root for some reason, even though it works perfectly fine as root. you can go ahead and remove that line from the scripts. or just su into chronos. but i prefer removing that line from the scripts because i'm particularly petty

i don't remember the exact list of packages that you absolutely need, but just install various shit until ./chrome_silly stops whining about libraries. oh also you need xdotool

next you want to just completely remove `/etc/lsb-release` or just move it somewhere else. it makes the chrome binary try and look for external dbus/mojo sockets and fail.

also fix some of the permissions in /home/chronos they can get weirdly messed up sometimes?

that should be it? i don't think i left anything out. you can now safely use the rootfs you constructed in place of the tarball that crumpet downloads, with the peace of mind that i haven't installed an evil chromebook unenrolling virus onto your system. was it worth it?

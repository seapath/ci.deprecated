# How to test the PXE docker image

The PXE docker image is intended to be launched by docker-compose. It is
however possible to launch it in standalone mode to test.

To do so, follow these steps:
* generate with Yocto the *seapath-flash-pxe* image
* create in the current folder the *images* folder
* copy the files *bzImage* and *seapath-flash-pxe-votp.cpio.gz* to the *images* folder
* build the PXE image with docker: `docker build . --tag pxe`
* disconnect the PC from the network
* connect the PC to the PXE network
* run the PXE container:
  `docker run --rm -it -v $(pwd)/images:/tftpboot/images 
  -e DHCP_RANGE_BEGIN=192.168.111.50 -e DHCP_RANGE_END=192.168.111.100 --cap-add
  NET_ADMIN --net host pxe`
* start the machine you want to boot
* at the end you should have access to a login prompt

It is very important to disconnect the PC from the network if you have a DHCP
server on this network.

`DHCP_RANGE_BEGIN` and `DHCP_RANGE_END` must be changed according to your
network configuration. All the range must be in the same subnet as your PC IP.

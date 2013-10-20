This is a vagrant file and a bootstrap file that will build and install OpenTelepresence from https://code.google.com/p/telepresence/.

It works as of 2013-10-20 and uses the latest version of ffmpeg 1.2, doubango, and telepresence based off of the rest of the requirements being packages in Ubuntu Saucy Salamander.

Run:

git clone https://github.com/ClashTheBunny/telepresence-vagrant.git
cd telepresence-vagrant
vagrant up

and you should end up with a fully built telepresence in the virtual machine in /usr/local/sbin/.

Run ./telepresence from that directory and you should be running the software.

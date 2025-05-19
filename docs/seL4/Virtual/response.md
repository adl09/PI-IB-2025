Hello Indan,
Thanks for the quick response!

I've tried with both VMs individually, and they work fine. Some of the curious things that I found doing more tests are that:
- Changing the level_trig option to 0 resolves both the freeze and error that appear, but one of the VMs still doesn't work with the NIC.
- I found that the working VM, the one that works well with the NIC, is the one that has the major "dest" number. Maybe it is a sort of priority thing in seL4 sharing IRQ11 for both VMs.

procurve-rancid
===============

Tools for building HP ProCurve policies with RANCID

Overview
========

This is a collection of scripts which can be used to build a policy
framework for configuration of HP ProCurve (ProVision) switches, built on
RANCID.  It supports bulk creation and deletion of VLANs, setting of IP
addresses for VLANs, etc.

It expects to be run as a non-root user, inside your RANCID directory at the
same level as router.db and configs.  I called the directory "policies" on
my system.

This is published under the "deliberately crappy and no shame about it"
philosophy.  Most of the code is a horrible hack, inefficient, inelegant,
and in some places probably just plain wrong.  But it did the job for me at
the time.  Hopefully it will help someone.  More on this philosophy here:
http://www.nanog.org/meetings/nanog26/presentations/stephen.pdf


WARNING
=======

DO NOT USE these scripts without testing and verification in a
non-production environment.

DO NOT USE these scripts in a production environment which has not been
backed up with RANCID or similar.

This repository contains example data which has not been validated in any
way, and will not work in your network without modification.  If you do not
review and check the data carefully, you might delete VLANs from your
switches, change IP addresses, or any one of a number of other non-useful
things, making your switches unreachable and your boss unhappy.  Don't say i
didn't warn you. :-)


Author
======

Paul Gear <github@libertysys.com.au>

- Success stories and patches gratefully accepted.
- Complaints about hideous code dutifully ignored.
- Feature requests welcome, but they'll probably not get much love unless
  they're trivially simple.
- Questions (dumb or not) are still free; the only truly dumb question is
  the one you didn't ask.


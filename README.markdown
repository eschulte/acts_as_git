ActsAsGit
==========

Allows ActiveFile models to interact with git repositories.  This adds
history, attribution, change-logs, rollbacks, and many of the useful
features of git to ActiveFile objects.

The two main methods are

- *acts\_as\_git\_repo*: for ActiveFile objects which are located at
  the top of git repositories
- *acts_as_git*: for ActiveFile objects which live inside of a git
  repository

Installation
============

From the root of your rails project execute the following

> ruby script/plugin install git://github.com/eschulte/acts\_as\_git.git

This plugin requires the [Ruby/Git](http://jointheconversation.org/rubygit/) gem

> gem install git

Example
=======


Licence
=======

Copyright (C) 2009 Eric Schulte

This is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

This file is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this software; see the file COPYING. If not, write to the
Free Software Foundation at this address:

  Free Software Foundation
  51 Franklin Street, Fifth Floor
  Boston, MA 02110-1301
  USA

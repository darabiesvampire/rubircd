# RubIRCd - An IRC server written in Ruby
# Copyright (C) 2013 Lloyd Dilley (see authors.txt for details) 
# http://www.rubircd.rocks/
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

require 'digest/sha2'

def make_password(plain_text)
  hash = Digest::SHA2.new(256) << plain_text
  return hash.to_s
end

if ARGV.length < 1
  puts("Not enough arguments. Expected 1 plain-text argument.")
elsif ARGV.length > 1
  puts("Too many arguments. Expected 1 plain-text argument.")
else
  puts(make_password(ARGV[0].to_s))
end

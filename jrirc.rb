# $Id$
# jrIRC    
# Copyright (c) 2013 (see authors.txt for details) 
# http://www.devux.org/projects/jrirc/
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

require_relative 'channel'
require_relative 'log'
require_relative 'network'
require_relative 'options'
require_relative 'server'
require_relative 'user'

puts(Server::VERSION)
print("Initializing logging... ")
Log.write("Initializing logging...")
puts("done.")
Log.write("Logging initialized.")
print("Parsing options file... ")
Options.parse()
puts("done.")
Log.write("Options loaded.")
if Options.debug_mode.to_s == "true"
  Thread.abort_on_exception = true
end
puts("Server name: #{Options.server_name}\nTCP port: #{Options.listen_port}")
print("Registering commands... ")
Command.register_commands()
puts("done.")
print("Populating reserved nicknames... ")
chanserv = User.new("ChanServ", "services", Options.server_name, nil, "Channel Services", nil, nil)
global = User.new("Global", "services", Options.server_name, nil, "Global Messenger", nil, nil)
memoserv = User.new("MemoServ", "services", Options.server_name, nil, "Memo Services", nil, nil)
nickserv = User.new("NickServ", "services", Options.server_name, nil, "Nickname Services", nil, nil)
operserv = User.new("OperServ", "services", Options.server_name, nil, "Operator Services", nil, nil)
Server.add_user(chanserv)
Server.add_user(global)
Server.add_user(memoserv)
Server.add_user(nickserv)
Server.add_user(operserv)
puts("done.")
default_channel = Channel.new(Options.default_channel, Options.admin_nick)
Server.channel_count = 0
Server.add_channel(default_channel)
Server.channel_count += 1
Log.write("Reserved nicknames populated.")
Server.start_timestamp = Time.now.asctime
Server.client_count = 5
Server.oper_count = 5
Server.link_count = 0
Server.visible_count = 5
Server.invisible_count = 0
puts("Starting network and waiting for incoming connections... ")
Network.start()

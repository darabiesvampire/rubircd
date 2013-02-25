# $Id$
# RubIRCd - An IRC server written in Ruby
# Copyright (C) 2013 Lloyd Dilley (see authors.txt for details) 
# http://www.rubircd.org/
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

module Standard
  class Nick
    def initialize()
      @command_name = "nick"
      @command_proc = Proc.new() { |user, args| on_nick(user, args) }
    end

    def plugin_init(caller)
      caller.register_command(@command_name, @command_proc)
    end

    def plugin_finish(caller)
      caller.unregister_command(@command_name)
    end

    def command_name
      @command_name
    end

    # args[0] = new nick
    def on_nick(user, args)
      args = args.join.split
      if args.length < 1
        Network.send(user, Numeric.ERR_NONICKNAMEGIVEN(user.nick))
        return
      end
      if args.length > 1
        Network.send(user, Numeric.ERR_ERRONEOUSNICKNAME(user.nick, args[0..-1].join(" "), "Nicknames cannot contain spaces."))
        return
      end
      if args[0][0] == ':'
        args[0] = args[0][1..-1].strip # remove leading ':' (fix for Pidgin and possibly other clients)
      end
      # We must have exactly 2 tokens so ensure the nick is valid
      if args[0] =~ /\A[a-z_\-\[\]\\^{}|`][a-z0-9_\-\[\]\\^{}|`]*\z/i && args[0].length >=1 && args[0].length <= Limits::NICKLEN
        Server.users.each do |u|
          if u.nick.casecmp(args[0]) == 0 && user != u
            unless user.is_registered
              Network.send(user, Numeric.ERR_NICKNAMEINUSE("*", args[0]))
            else
              Network.send(user, Numeric.ERR_NICKNAMEINUSE(user.nick, args[0]))
            end
            return
          end
        end
        Server.reserved_nicks.each do |n|
          if n.casecmp(args[0]) == 0 && user.nick != n
            unless user.is_registered
              Network.send(user, Numeric.ERR_ERRONEOUSNICKNAME("*", args[0], "Reserved nickname"))
            else
              Network.send(user, Numeric.ERR_ERRONEOUSNICKNAME(user.nick, args[0], "Reserved nickname"))
            end
            return
          end
        end
        if user.is_registered && user.nick != args[0]
          if user.channels.length > 0
            user.channels.each do |c|
              chan = Server.channel_map[c.to_s.upcase]
              chan.users.each do |u|
                if user.nick != u.nick
                  Network.send(u, ":#{user.nick}!#{user.ident}@#{user.hostname} NICK :#{args[0]}")
                end
              end
            end
          end
          Network.send(user, ":#{user.nick}!#{user.ident}@#{user.hostname} NICK :#{args[0]}")
        end
        user.change_nick(args[0])
        return
      else
        Network.send(user, Numeric.ERR_ERRONEOUSNICKNAME(user.nick, args[0], "Nickname contains invalid characters."))
        return
      end
    end
  end
end
Standard::Nick.new
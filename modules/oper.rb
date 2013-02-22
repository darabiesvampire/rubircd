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
  class Oper
    def initialize()
      @command_name = "oper"
      @command_proc = Proc.new() { |user, args| on_oper(user, args) }
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

    # args[0] = nick
    # args[1] = password
    def on_oper(user, args)
      if args.length < 2
        Network.send(user, Numeric.ERR_NEEDMOREPARAMS(user.nick, "OPER"))
        return
      end
      admin_nick = nil
      oper_nick = nil
      Server.admins.each do |admin|
        if admin.nick.casecmp(args[0]) == 0
          admin_nick = admin.nick
        end
      end
      Server.opers.each do |oper|
        if oper.nick.casecmp(args[0]) == 0
          oper_nick = oper.nick
        end
      end
      if admin_nick == nil && oper_nick == nil
        Network.send(user, Numeric.ERR_NOOPERHOST(user.nick))
        return
      end
      hash = Digest::SHA2.new(256) << args[1]
      unless admin_nick == nil
        Server.admins.each do |admin|
          if admin.nick == admin_nick && admin.hash == hash.to_s
            if admin.host == nil || admin.host == "" || admin.host == '*'
              Network.send(user, Numeric.RPL_YOUAREOPER(user.nick))
              user.set_admin()
              return
            end
            hostmask = admin.host.to_s.gsub('\*', '.*?')
            regx = Regexp.new("^#{hostmask}$", Regexp::IGNORECASE)
            if user.hostname =~ regx
              Network.send(user, Numeric.RPL_YOUAREOPER(user.nick))
              user.set_admin()
              return
            else
              Network.send(user, Numeric.ERR_NOOPERHOST(user.nick))
              return
            end
          else
            Network.send(user, Numeric.ERR_NOOPERHOST(user.nick))
            return
          end
        end
      end
      unless oper_nick == nil
        Server.opers.each do |oper|
          if oper.nick == oper_nick && oper.hash == hash.to_s
            if oper.host == nil || oper.host == "" || oper.host == '*'
              Network.send(user, Numeric.RPL_YOUAREOPER(user.nick))
              user.set_operator()
              return
            end
            hostmask = oper.host.to_s.gsub('\*', '.*?')
            regx = Regexp.new("^#{hostmask}$", Regexp::IGNORECASE)
            if user.hostname =~ regx
              Network.send(user, Numeric.RPL_YOUAREOPER(user.nick))
              user.set_operator()
              return
            else
              Network.send(user, Numeric.ERR_NOOPERHOST(user.nick))
              return
            end
          else
            Network.send(user, Numeric.ERR_NOOPERHOST(user.nick))
          end
        end
      end
    end
  end
end
Standard::Oper.new

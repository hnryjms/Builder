#!/usr/bin/ruby -w
#
#  _base.rb
#  Builder
#
#  Created by Hank Brekke on 5/18/2015.
#  Creative Commons Attribution 4.0 (CC-BY-4.0) z43 Studio.
#

require 'shellwords'

module Builder
	class Base
		private
		def _path(command, longName=nil)
			if longName == nil
				longName = command
			end
			longName = longName.upcase

			env_name = "#{longName}_PATH"
			path = nil
			if ENV[env_name]
				path = ENV[env_name]
				if path == 'false'
					path = nil
				end
			else
				path = `which #{command}`
				path.strip!

				if path.length == 0
					path = nil
				end
			end

			return path
		end
		private
		def _describe(event, options)
			optsLength = options.keys.reduce(0) { |max, key|
				length = key.length
				(length > max ? length : max)
			}

			puts ''
			puts "#{event} #{self.scheme} with options"
			options.each{ |name, value|
				paddedKey = name.capitalize.ljust(optsLength)
				puts "> #{paddedKey}  #{value}"
			}
			puts ''
		end
		private
		def _escape(arguments)
			return Shellwords.join(arguments)
		end
		private
		def _run(arguments)
			command = arguments.is_a?(Array) ? Shellwords.join(arguments) : arguments
			raise "Non-zero exit code running \n\n#{command}\n\n" unless system(command)
		end
	end
end

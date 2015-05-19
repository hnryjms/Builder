#!/usr/bin/ruby -w
#
#  Apple.rb
#  Builder
#
#  Created by Hank Brekke on 4/19/2015.
#  Creative Commons Attribution 4.0 (CC-BY-4.0) z43 Studio.
#

require 'fileutils'

require_relative '_base'

module Builder
	class Apple < Base
		attr_accessor :scheme, :location
		attr_accessor :configuration, :sdk
		attr_accessor :cocoapods

		def initialize(location, scheme)
			self.location = location
			self.scheme = scheme

			# Public options
			self.configuration = 'Release'
			self.sdk = 'iphoneos'

			cocoapod_file = File.expand_path(File.dirname(location)) + "/Podfile"
			self.cocoapods = File.exist?(cocoapod_file)

			# Private options
			@xctool_path = _path('xctool')
			@xcodebuild_path = _path('xcodebuild')
			
			if self.cocoapods
				@cocoapods_installed = false
				@cocoapods_directory = File.expand_path(File.dirname(location))

				@cocoapods_path = _path('pod', 'cocoapods')
			end

			@reporters = [ ]
			if (ENV['JENKINS_HOME'] || 
				ENV['bamboo_buildKey'])
				# Use plain reporting on CI Servers (since they aren't printing to a GUI window).
				@reporters.push('plain')
			else
				# Use pretty reporting on manual execution (for debugging build failures, etc).
				@reporters.push('pretty')
				@reporters.push('user-notifications')
			end
		end
		def build
			opts = _options()
			_describe('Building', opts)

			args = _xctool(opts)
			args ||= _xcodebuild(opts)

			args.push('build');

			_podinstall()
			_run(args)
		end
		def test(junit='./Results/junit.xml')
			if junit != nil
				@reporters.push("junit:#{junit}")
			end

			didChangeSDK = false
			if self.sdk == 'iphoneos'
				didChangeSDK = true
				puts 'We are running tests for iOS Simulator because we don\'t currently support testing on physical devices.'

				# we cannot run tests on iphoneos yet (xctool limitation).
				self.sdk = 'iphonesimulator'
			end

			opts = _options()
			_describe('Testing', opts)

			args = _xctool(opts)
			if args == nil
				raise "Testing requires `xctool` to be installed on this computer or server."
			end

			args.push('test');

			_podinstall()
			_run(args)

			if junit != nil
				# remove the reporter from future xctool actions
				@reporters.pop()
			end

			if didChangeSDK
				# revert back to iphoneos for next commands
				self.sdk = 'iphoneos'
			end
		end
		def archive(output="./#{self.scheme}.app", dSYMs=nil)
			opts = _options()
			_describe('Archiving', opts)

			args = _xctool(opts)
			args ||= _xcodebuild(opts)

			args.push('archive');

			exportFormat = output.end_with?('xcarchive') ? 'xcarchive' : File.extname(output)[1..-1]
			archivePath = output
			if exportFormat != 'xcarchive'
				archivePath = "/tmp/#{self.scheme}.xcarchive"
			end

			if File.exist?(archivePath)
				FileUtils.rm_rf(archivePath)
			end
			if File.exist?(output)
				FileUtils.rm_rf(output)
			end
			if dSYMs != nil && File.exist?(dSYMs)
				FileUtils.rm_rf(dSYMs)
			end
			# xcodebuild needs -archivePath AFTER the archive command
			args.push(*['-archivePath', archivePath])

			_podinstall()
			_run(args)

			if exportFormat != 'xcarchive'
				export = [ @xcodebuild_path ]
				export.push('archive');
				export.push('-exportArchive');
				export.push(*['-archivePath', archivePath])
				export.push(*['-exportFormat', exportFormat])
				export.push(*['-exportPath', output])
				export.push('-exportWithOriginalSigningIdentity')

				_run(export)
			end

			if dSYMs != nil
				dSYMs = File.expand_path(dSYMs)

				dSYMsExport = "pushd \"#{archivePath}/dSYMs\" "
				dSYMsExport << '&& '
				dSYMsExport << "zip -r \"#{dSYMs}\" . "
				dSYMsExport << '&& '
				dSYMsExport << 'popd'

				_run(dSYMsExport)
			end
		end

		private
		def _options()
			opts = {}

			if self.location.end_with?("xcworkspace")
				opts['workspace'] = self.location
			else
				opts['project'] = self.location
			end

			opts['scheme'] = self.scheme
			opts['configuration'] = self.configuration
			opts['sdk'] = self.sdk

			return opts
		end
		private
		def _xctool(opts)
			if @xctool_path.length == 0
				return nil
			end

			opts['reporter'] = @reporters

			args = [ @xctool_path ]
			opts.each { |key, value|
				if value.is_a?(Array)
					value.each { |item|
						args.push(*[ "-#{key}", item ])
					}
				else
					args.push(*[ "-#{key}", value ])
				end
				
			}

			return args
		end
		private
		def _xcodebuild(opts)
			args = [ @xcodebuild_path ]
			opts.each { |key, value|
				if value.is_a?(Array)
					value.each { |item|
						args.push(*[ "-#{key}", item ])
					}
				else
					args.push(*[ "-#{key}", value ])
				end
				
			}

			return args
		end
		private
		def _podinstall()
			if self.cocoapods && !@cocoapods_installed
				puts "Installing Cocoapods dependencies"

				args = _escape([ @cocoapods_path, 'install' ])
				args << " --project-directory=\"#{@cocoapods_directory}\""

				_run(args)
				@cocoapods_installed = true
			end
		end
	end
end

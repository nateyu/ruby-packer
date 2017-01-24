# Copyright (c) 2017 Minqi Pan <pmq2001@gmail.com>
# 
# This file is part of Ruby Compiler, distributed under the MIT License
# For full terms see the included LICENSE file

require 'shellwords'
require 'tmpdir'
require 'fileutils'
require 'open3'


class Compiler
  module Utils
    def self.escape(arg)
      if Gem.win_platform?
        if arg.include?('"')
          raise NotImplementedError
        end
        %Q{"#{arg}"}
      else
        Shellwords.escape(arg)
      end
    end

    def self.run(*args)
      STDERR.puts "-> Running #{args}"
      pid = spawn(*args)
      pid, status = Process.wait2(pid)
      raise Error, "Failed running #{args}" unless status.success?
    end

    def self.chdir(path)
      STDERR.puts "-> cd #{path}"
      Dir.chdir(path) { yield }
      STDERR.puts "-> cd #{Dir.pwd}"
    end
    
    def self.cp(x, y)
      STDERR.puts "-> cp #{x.inspect} #{y.inspect}"
      FileUtils.cp(x, y)
    end
    
    def self.cp_r(x, y, options = {})
      STDERR.puts "-> cp -r #{x.inspect} #{y.inspect}"
      FileUtils.cp_r(x, y, options)
    end

    def self.rm(x)
      STDERR.puts "-> rm #{x}"
      FileUtils.rm(x)
    end

    def self.rm_f(x)
      STDERR.puts "-> rm -f #{x}"
      FileUtils.rm_f(x)
    end

    def self.rm_rf(x)
      STDERR.puts "-> rm -rf #{x}"
      FileUtils.rm_rf(x)
    end
    
    def self.mkdir_p(x)
      STDERR.puts "-> mkdir -p #{x}"
      FileUtils.mkdir_p(x)
    end
    
    def self.prepare_tmpdir(tmpdir)
      Utils.mkdir_p(tmpdir)
      Dir[::Compiler::VENDOR_DIR + '/*'].each do |dirpath|
        target = File.join(tmpdir, File.basename(dirpath))
        unless Dir.exist?(target)
          Utils.cp_r(dirpath, target, preserve: true)
        end
      end
      target = File.join(tmpdir, 'ruby')
      Utils.cp_r(File.join(PRJ_ROOT, 'ruby'), target, preserve: true) unless Dir.exist?(target)
    end

    def self.remove_dynamic_libs(path)
      ['dll', 'dylib', 'so'].each do |extname|
        Dir["#{path}/**/*.#{extname}"].each do |x|
          STDERR.puts "-> FileUtils.rm_f #{x}"
          FileUtils.rm_f(x)
        end
      end
    end

    def self.copy_static_libs(path, target)
      ['lib', 'a'].each do |extname|
        Dir["#{path}/*.#{extname}"].each do |x|
          STDERR.puts "-> FileUtils.cp #{x}, #{target}"
          FileUtils.cp(x, target)
        end
      end
    end
  end
end
# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'samovar'
require 'tty/screen'

module Plotty
	class Sequence
		Linear = Struct.new(:min, :max, :step) do
			def each(&block)
				return to_enum unless block_given?
				
				(min..max).step(step, &block)
			end
		end
		
		Scalar = Struct.new(:min, :max, :scale) do
			def each
				return to_enum unless block_given?
				
				i = min
				while i <= max
					yield i
					i *= scale
				end
			end
		end
		
		def self.parse(command)
			case command
			when /^(.*?),(.*?)$/
				command.split(',').map(&:to_i)
			when /^(.*?):\*(.*?):(.*?)$/
				Scalar.new($1.to_i, $3.to_i, $2.to_i)
			when /^(.*?):(.*?):(.*?)$/
				Linear.new($1.to_i, $3.to_i, $2.to_i)
			when /^(.*?):(.*?)$/
				Linear.new($1.to_i, $2.to_i, 1)
			end
		end
	end
	
	Function = Struct.new(:pattern, :command, :title) do
		def self.parse(pattern, command)
			pattern = Regexp.new(pattern, Regexp::MULTILINE)
			
			if command =~ /^(\w+):(.*?)$/
				self.new(pattern, $2, $1)
			else
				self.new(pattern, command, command)
			end
		end
		
		def call(value)
			r, w = IO.pipe
			
			$stderr.puts "Running #{self.command} with x = #{value}..."
			
			pid = Process.spawn({'x' => value.to_s}, self.command, out: w, err: STDERR)
			
			w.close
			
			buffer = r.read
			
			Process.waitpid pid
			
			if match = self.pattern.match(buffer)
				$stderr.puts "\tresult = #{match.inspect}"
				
				if match.captures.empty?
					return [match[0]]
				else
					return match.captures
				end
			end
		end
	end
	
	class Graph
		def initialize(x, y)
			@x = x
			@y = y
		end
		
		def self.parse(x, y, commands)
			self.new(
				Sequence.parse(x),
				commands.collect{|command| Function.parse(y, command)},
			)
		end
		
		def size
			TTY::Screen.size.reverse
		end
		
		def generate_values(name)
			path = name + ".csv"
			values = nil
			
			File.open(path, "w") do |file|
				file.sync = true
				
				@x.each do |x|
					values = @y.collect do |function|
						function.call(x)
					end
					
					file.puts "#{x}, #{values.flatten.join(', ')}"
				end
			end
			
			return values.map(&:count)
		end
		
		def generate_plot(name, offsets, force = false)
			path = name + ".gp"
			
			if !File.exist?(path) or force
				File.open(path, "w") do |file|
					file.puts('set datafile separator ","')
					
					yield file if block_given?
					
					file.write("plot ")
					first = true
					@y.collect.with_index do |function, index|
						if first
							first = false
						else
							file.write ','
						end
						
						file.write "'#{name}.txt' using 1:#{offsets[index]} with lines title #{function.title.dump}"
					end
					
					file.puts
				end
			end
			
			return path
		end
		
		def plot!(script = nil, name = "plot")
			counts = generate_values(name)
			offsets = [2]
			
			counts.each do |count|
				offsets << offsets.last + count
			end
			
			path = generate_plot(name, offsets) do |file|
				file.puts script if script
			end
			
			system("gnuplot", path)
		end
	end
end

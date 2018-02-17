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
			when /^(.*?):\*(.*?):(.*?)$/
				Scalar.new($1.to_i, $3.to_i, $2.to_i)
			when /^(.*?):(.*?):(.*?)$/
				Linear.new($1.to_i, $3.to_i, $2.to_i)
			when /^(.*?):(.*?)$/
				Linear.new($1.to_i, $2.to_i, 1)
			end
		end
	end
	
	class Function
		def initialize(pattern, command)
			@pattern = Regexp.new(pattern)
			@command = command
		end
		
		def title
			@command
		end
		
		def call(value)
			r, w = IO.pipe
			
			puts "Running #{@command} with x = #{value}..."
			
			pid = Process.spawn({'x' => value.to_s}, @command, out: w, err: STDERR)
			
			w.close
			
			buffer = r.read
			
			Process.waitpid pid
			
			if match = @pattern.match(buffer)
				result = match[1] || match[0]
				
				puts "\tresult = #{result}"
				
				return result
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
				commands.collect{|command| Function.new(y, command)},
			)
		end
		
		def size
			TTY::Screen.size.reverse
		end
		
		def plot!(script = nil)
			File.open("data.txt", "w") do |file|
				@x.each do |x|
					values = @y.collect do |function|
						function.call(x)
					end
					
					puts "#{x}: #{values.inspect}"
					file.puts "#{x} #{values.join(' ')}"
				end
			end
			
			plots = @y.collect.with_index{|function, index| "'data.txt' using 1:#{index+2} with lines title #{function.title.dump}"}
			
			system("gnuplot", "-e", "#{script}; plot #{plots.join(', ')}")
		end
	end
end

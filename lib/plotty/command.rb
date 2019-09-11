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

require_relative 'graph'

module Plotty
	module Command
		class Top < Samovar::Command
			self.description = "Render graphs by executing commands."
			
			options do
				option "-n/--name <string>", "The name of the output plot.", default: "plot"
				
				option "-x <axis>", "Specify the x axis explicitly", default: "1:10"
				option "-y <axis>", "Regular expression for the y-axis value."
				
				option "-e/--script <script>", "Prepend this script to the gnuplot command."
				
				option '-h/--help', "Print out help information."
				option '-v/--version', "Print out the application version."
			end
			
			split :command
			
			def plot_graph
				Graph.parse(options[:x], options[:y], @command).plot!(options[:script], options[:name])
			end
			
			def call(program_name: File.basename($0))
				if @options[:version]
					puts "plotty v#{Teapot::VERSION}"
				elsif @options[:help] or @command.nil?
					print_usage(program_name)
				else
					plot_graph
				end
			end
		end
	end
end

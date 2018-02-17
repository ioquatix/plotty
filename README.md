# Plotty

`plotty` is a quick hack to do performance comparisions on the command line. It sweeps the x value and runs commands to compute the y value. The y value is extracted from the stdout of the command using a regular expression. The graphs are drawn using `gnuplot` which you'll need to have installed.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'plotty'
```

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install plotty

## Usage

`plotty` allows you to graph data from commands, e.g.

	plotty -x 1:10 -y '\d+' -- 'echo 1' 'echo $x' 'expr $x \* $x'

This will graph the results xecuting the 3 commands after the split with `$x = 1, 2, 3, ... 10`. The y value is computed by the first match of the given regular expression.

### X Axis

The `-x` argument can take sequences of the following format:

| Value     | Meaning                                                          |
| ----------|------------------------------------------------------------------|
| `1:10`    | Enumerate from 1 to 10.                                          |
| `1:2:10`  | Enumerate from 1 to 10 with steps of size 2.                     |
| `1:*2:64` | Enumerate from 1 to 64 by multiplying the value by 2 each time.  |

### Y Axis

The `-y` argument is a regular expression which is used to extract the y value from the `stdout` of the command. If a capture is specified, the first one is used.

### Use libcaca

Add the following to your `~/.gnuplot`

	set terminal caca driver ncurses

If you are on arch, install [gnuplot-caca](https://aur.archlinux.org/packages/gnuplot-caca).

## Examples

### Trivial Math

```
plotty -x 1:1:20 -y '\d+' -e "set terminal dumb; set key outside" -- 'echo 1' 'echo $x'

20 +------------------------------------------------------+                  
   |     +    +     +    +     +    +     +    +     +### |  echo 1 *******  
18 |-+                                              ##  +-| echo $x #######  
   |                                             ###      |                  
16 |-+                                        ###       +-|                  
   |                                       ###            |                  
14 |-+                                   ##             +-|                  
   |                                  ###                 |                  
12 |-+                             ###                  +-|                  
   |                            ###                       |                  
10 |-+                        ##                        +-|                  
   |                       ###                            |                  
 8 |-+                  ###                             +-|                  
   |                 ###                                  |                  
 6 |-+             ##                                   +-|                  
   |            ###                                       |                  
 4 |-+       ###                                        +-|                  
   |      ###                                             |                  
 2 |-+  ##                                              +-|                  
   |  ##**************************************************|                  
 0 +------------------------------------------------------+                  
   0     2    4     6    8     10   12    14   16    18   20                 
```

```
plotty -x 1:1:100 -y '\d+' -e "set terminal dumb; set key outside" -- 'echo $x' 'expr $x \* $x'

100 +-----------------------------------------------+                        
    |    +     +    +    +     +    +    +     +   #|       echo $x *******  
 90 |-+                                          ##-| expr $x \* $x #######  
    |                                           #   |                        
 80 |-+                                       ##  +-|                        
    |                                       ##      |                        
 70 |-+                                   ##      +-|                        
    |                                    #          |                        
 60 |-+                                ##         +-|                        
    |                                ##             |                        
 50 |-+                             #             +-|                        
    |                             ##                |                        
 40 |-+                         ##                +-|                        
    |                         ##                    |                        
 30 |-+                    ###                    +-|                        
    |                   ###                         |                        
 20 |-+               ##                          +-|                        
    |             ####                              |                        
 10 |-+     ######                     *************|                        
    |  #####***************************  +     +    |                        
  0 +-----------------------------------------------+                        
    1    2     3    4    5     6    7    8     9    10   
```

### Web Server Benchmark

```
                wrk -c $x -t $x -d 1 http://localhost:9292 *******              
               wrk -c $x -t $x -d 1 http://localhost:9293 #######              
  800 +--------------------------------------------------------------------+   
      |           +          +           +          +           +          |   
  700 |-+                         ################################       +-|   
      |                       ####                                         |   
  600 |-+                  ###                                           +-|   
      |                ####                                                |   
      |              ##                                                    |   
  500 |-+          ##                                                    +-|   
      |          ##                                                        |   
  400 |-+       #                                                        +-|   
      |       ##                                                           |   
  300 |-+    #                                                           +-|   
      |     #                                                              |   
  200 |-+   #                                                            +-|   
      |    #                                                               |   
      |  ##*******************************************************         |   
  100 |-#                                                                +-|   
      |#          +          +           +          +           +          |   
    0 +--------------------------------------------------------------------+   
      0           50        100         150        200         250        300  
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2018, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


require_relative "lib/plotty/version"

Gem::Specification.new do |spec|
	spec.name          = "plotty"
	spec.version       = Plotty::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]

	spec.summary       = %q{Draw graphs from data gathered by executing commands}
	spec.homepage      = "https://github.com/ioquatix/plotty"

	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_dependency "samovar"
	spec.add_dependency "tty-screen"

	spec.add_development_dependency "bundler", "~> 1.16"
	spec.add_development_dependency "rake", "~> 10.0"
	spec.add_development_dependency "rspec", "~> 3.0"
end

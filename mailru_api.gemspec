# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mailru_api/version'

Gem::Specification.new do |gem|
  gem.name          = "mailru_api"
  gem.version       = MailruApi::VERSION
  gem.authors       = ["Artyom Keydunov"]
  gem.email         = ["artyom.keydunov@gmail.com"]
  gem.description   = %q{Gem для общения с Mail.ru API}
  gem.summary       = %q{Gem для общения с Mail.ru API}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  s.add_dependency('activesupport')

end

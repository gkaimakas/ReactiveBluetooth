Pod::Spec.new do |s|
s.name             = 'ReactiveBluetooth'
s.version          = '0.0.1'
s.summary          = 'ReactiveSwift bindings for CoreBluetooth.'

s.description      = <<-DESC
..
DESC

s.homepage         = 'https://github.com/gkaimakas/ReactiveBluetooth'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'gkaimakas' => 'gkaimakas@gmail.com' }
s.source           = { :git => 'https://github.com/gkaimakas/ReactiveBluetooth.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'

s.source_files = 'ReactiveBluetooth/Classes/**/*'
s.dependency 'ReactiveSwift'
s.dependency 'ReactiveCocoa'
end


Pod::Spec.new do |s|
    s.name = 'TexturedPopoverBackgroundView'
    s.version = '1.0.0'
    s.summary = 'Customized background for iOS popover with border, texture, etc...'
    s.homepage = 'https://github.com/ladeiko/TexturedPopoverBackgroundView'
    s.license = { :type => 'CUSTOM', :file => 'LICENSE' }
    s.author = { 'Siarhei Ladzeika' => 'sergey.ladeiko@gmail.com' }
    s.platform = :ios, '10.0'
    s.source = { :git => 'https://github.com/ladeiko/TexturedPopoverBackgroundView.git', :tag => "#{s.version}" }
    s.requires_arc = true
    s.swift_versions = '4.0', '4.2', '5.0', '5.1'

    s.source_files = [ 'Sources/**/*.{swift}' ]
    s.frameworks = 'UIKit'

end

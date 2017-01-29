Pod::Spec.new do |s|
  s.name             = 'MRefresh'
  s.version          = '0.1.1'
  s.summary          = 'This pod enables you to add pull-to-refresh mechanism to your scrollviews and tableviews and use svg patterns in your refreshing views layers.'
  s.homepage         = 'https://github.com/strongself/MRefresh'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mikhail Rakhmanov' => 'rakhmanov.m@gmail.com' }
  s.source           = { :git => 'https://github.com/strongself/MRefresh.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'MRefresh/Classes/**/*'
end

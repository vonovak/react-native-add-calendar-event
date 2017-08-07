require 'json'
package_json = JSON.parse(File.read('package.json'))

Pod::Spec.new do |s|
  s.name         = 'react-native-add-calendar-event'
  s.version      = package_json['version']
  s.summary      = package_json['description']
  s.homepage     = 'https://github.com/vonovak/react-native-add-calendar-event'
  s.author       = package_json['author']
  s.license      = package_json['license']
  s.platform     = :ios, '8.0'
  s.source       = {
    :git => 'https://github.com/vonovak/react-native-add-calendar-event.git'
  }
  s.source_files  = '*.{h,m}'

  s.dependency 'React'
end

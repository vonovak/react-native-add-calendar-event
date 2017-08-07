
Pod::Spec.new do |s|
  s.name         = "AddCalendarEvent"
  s.version      = "1.0.0"
  s.summary      = "AddCalendarEvent"
  s.description  = <<-DESC
                  AddCalendarEvent
                   DESC
  s.homepage     = "https://github.com/shrutic/react-native-add-calendar-event"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/vonovak/react-native-add-calendar-event.git", :tag => "master" }
  s.source_files  = "ios/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  

inhibit_all_warnings!

target 'Quick Quips' do
    use_frameworks!
    pod 'RealmSwift'
end
target 'Quick QuipsTests' do
    use_frameworks!
    pod 'Quick'
    pod 'Nimble'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.1'
        end
    end
end

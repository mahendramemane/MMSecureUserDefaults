
target 'MMUserDefaultsSQLite' do
  use_frameworks!
  pod 'SwiftyJSON'
  pod 'FMDB/SQLCipher'

  target 'MMUserDefaultsSQLiteTests' do
    inherit! :search_paths
  end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == "FMDB"
            config_path = target.build_configurations[0].base_configuration_reference.real_path
            File.open(config_path, "a") {|file| file.write("HEADER_SEARCH_PATHS = SQLCipher")}
        end
    end
end

end



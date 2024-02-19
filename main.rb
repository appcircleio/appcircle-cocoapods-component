require 'open3'
require 'pathname'

def env_has_key(key)
  return (ENV[key] != nil && ENV[key] !="") ? ENV[key] : abort("Missing #{key}.")
end

project_path = ENV["AC_PROJECT_PATH"] || abort('Missing project path.')
repository_path = ENV["AC_REPOSITORY_DIR"]

cocoapods_version = (ENV["AC_COCOAPODS_VERSION"] != nil && ENV["AC_COCOAPODS_VERSION"] !="") ? ENV["AC_COCOAPODS_VERSION"] : nil

project_dir_path = repository_path ? (Pathname.new repository_path).join(File.dirname(project_path)) : File.dirname(project_path)
cocoapods_podfile_path = File.join(project_dir_path,"Podfile")
cocoapods_podfilelock_path = File.join(project_dir_path,"Podfile.lock")
#cocoapods_project_path = File.join(project_dir_path,"Pods","Pods.xcodeproj")

unless File.exist?(cocoapods_podfile_path)
    puts "Podfile does not exists."
    exit 0
end

if File.extname(project_path) != ".xcworkspace"
    puts "Project extension must be xcworkspace."
    exit 0
end


# if File.exist?(cocoapods_project_path)
#     puts "Pods already installed."
#     exit 0
# else
#     puts "Pods does not exist. Pod install command is being executed"
# end


def runCommand(command)
    puts "@@[command] #{command}"
    unless system(command)
      exit $?.exitstatus
    end
end

def podInstall(cocoapods_version, project_dir_path)
  cocoapods_cmd_prefix = cocoapods_version ? "pod _#{cocoapods_version}_" : "pod"

  Dir.chdir(project_dir_path) do
    runCommand("#{cocoapods_cmd_prefix} install")
  end
end

if cocoapods_version.nil?
  puts "Using Podfile.lock Cocoapods Version"
  if File.exist?(cocoapods_podfilelock_path)
    versionArray = File.read(cocoapods_podfilelock_path).scan(/(?<=COCOAPODS: )(.*)/)[0]
    if versionArray && versionArray[0]
      cocoapods_version = versionArray[0]
      puts "Podfile.lock version = #{cocoapods_version}"
      system_cocoapods_version, stderr, status = Open3.capture3('pod --version') 
      if cocoapods_version == system_cocoapods_version.strip
        runCommand("pod _#{cocoapods_version}_ repo update")
        podInstall(cocoapods_version, project_dir_path)
      else
        if `which rbenv`.empty?
          runCommand("sudo gem install cocoapods -v #{cocoapods_version} --no-document")
          runCommand("pod _#{cocoapods_version}_ setup")
          podInstall(cocoapods_version, project_dir_path)
        else
          runCommand("gem install cocoapods -v #{cocoapods_version} --no-document")
          runCommand("pod _#{cocoapods_version}_ setup")
          podInstall(cocoapods_version, project_dir_path)
        end
      end
    end
  end
else
    puts "Cocoapods version = #{cocoapods_version}"
    system_cocoapods_version, stderr, status = Open3.capture3('pod --version')
    if cocoapods_version == system_cocoapods_version.strip
        puts "Using System Default Cocoapods Version"
        runCommand("pod _#{cocoapods_version}_ repo update")
        podInstall(cocoapods_version, project_dir_path)
    else
        if `which rbenv`.empty?
          runCommand("sudo gem install cocoapods -v #{cocoapods_version} --no-document")
          runCommand("pod _#{cocoapods_version}_ setup")
          podInstall(cocoapods_version, project_dir_path)
        else
          runCommand("gem install cocoapods -v #{cocoapods_version} --no-document")
          runCommand("pod _#{cocoapods_version}_ setup")
          podInstall(cocoapods_version, project_dir_path)
        end
    end
end
exit 0
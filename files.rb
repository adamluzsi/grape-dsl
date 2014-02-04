### Get Files from dir
begin

  files_to_be_loaded = %w[version.rb]

  SpecFiles= Array.new

  Dir[File.expand_path(File.join(File.dirname(__FILE__),"**","*"))].sort.uniq.each do |one_file_name|
    one_file_name = File.expand_path one_file_name
    file_name = one_file_name[(File.expand_path(File.dirname(__FILE__)).to_s.length+1)..(one_file_name.length-1)]

    if !one_file_name.include?("pkg")
      if !File.directory? file_name
        SpecFiles.push file_name
        STDOUT.puts file_name if $DEBUG
        if files_to_be_loaded.include? one_file_name.split(File::SEPARATOR).last
          load one_file_name
        end
      end
    end

  end

end
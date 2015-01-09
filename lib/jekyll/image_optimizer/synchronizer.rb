class Synchronizer
  def initialize(source_path, target_path)
    @source_path=source_path
    @target_path=target_path
  end

  def create_symlink(name, param)
    target=target_name(@target_path, param)
    if File::symlink? name
      return if File::readlink(name)==File::expand_path(target)
      File::delete name
    else
      raise "File #{name} already exists" if File::exist? name
    end
    puts "creating symlink (#{name}->#{target})"
    File::symlink(File::expand_path(target), name)
  end

  def target_name(path, param)
    path+param
  end

  def synchronize(param)
    target_path=target_name(@target_path, param)
    for source in Dir["#{@source_path}/**/*"]
      target=source.sub(@source_path, target_path)
      synchronize_file(source, target, param) if File::file? source
    end
    delete_targets_without_source(target_path)
  end

  def synchronize_file(source, target, param)
    source_time = File.mtime(source)
    if !File.file?(target) or File.mtime(target) != source_time
      target_dir=File.dirname(target)
      Dir.mkdir(target_dir) unless File.directory? target_dir
      do_synchronize_file(source, target, param)
      File.utime(source_time, source_time, target) if File.file?(target)
    end
  end

  def do_synchronize_file(source, target, param)
    puts "copying #{source} -> #{target}"
    copy_file(source, target)
  end

  def copy_file(src, dest)
    File.open(src, 'rb') { |r|
      File.open(dest, 'wb') { |w|
        while true
          w.syswrite r.sysread(1024)
        end
      }
    }
  rescue IOError
    # ignored
  end

  def delete_targets_without_source(target_path)
    files_and_dirs_by_length=Dir["#{target_path}/**/*"].sort_by { |dir| File.file?(dir) ? ('a'+dir) : ('b'+(1000-dir.size).to_s) }
    for target in files_and_dirs_by_length
      source=target.sub(target_path, @source_path)
      if File.directory? target
        delete_dir(target) unless Dir.exists? source
      else
        delete_file(target) unless File.file? source
      end
    end
  end

  def delete_dir(dir)
    puts "deleting #{dir}"
    Dir.delete(dir)
  end

  def delete_file(file)
    puts "deleting #{file}"
    File.delete(file)
  end
end

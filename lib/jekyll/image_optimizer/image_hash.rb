class ImageHash
  def initialize(use_hash)
    @use_hash=use_hash
  end

  def file_search_pattern(file)
    pos=file.rindex('/')
    self.dir_search_pattern(file[0..pos-1], file[pos+1..-1])
  end

  def dir_search_pattern(dir, file)
    if @use_hash
      pos=file.rindex('.')
      dir+'/'+file[0..pos-1]+'-*'+file[pos..-1]
    else
      dir+'/'+file
    end
  end

  def name_with_hash(file)
    pos=file.rindex('.')
    file[0..pos-1]+'-'+Digest::MD5.file(file).hexdigest+file[pos..-1]
  end

  def with_hash(file)
    return file unless @use_hash
    new_file=self.name_with_hash(file)
    File.rename(file, new_file)
    new_file
  end

  def without_hash(file)
    @use_hash ? file.sub(/-[0-9a-f]{32}\./, '.') : file
  end

  def hash?(file)
    @use_hash ? file.match(/-[0-9a-f]{32}\./)!=nil : true
  end
end
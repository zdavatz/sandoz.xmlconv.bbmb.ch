module TestingDataLoadable

  def load_testing_data(path=nil)
    File.read(testing_data_path(path))
  end

  private

  def testing_data_path(path=nil)
    File.expand_path('../../data' + path, __FILE__)
  end
end

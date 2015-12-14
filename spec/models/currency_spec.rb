describe Currency do
  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:code).case_insensitive }
end

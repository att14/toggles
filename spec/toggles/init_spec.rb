describe Toggles do
  describe "#init" do
    include_context "uses temp dir"

    it "correctly loads configuration" do
      Dir.mkdir("#{temp_dir}/foo")
      Dir.mkdir("#{temp_dir}/bar")

      File.open("#{temp_dir}/foo/users.yml", "w") do |f|
        f.write("{\"id\": {\"in\": [1, 2]}}")
      end

      File.open("#{temp_dir}/bar/users.yml", "w") do |f|
        f.write("{\"id\": {\"in\": [3, 4]}}")
      end

      Toggles.configure do |c|
        c.features_dir = temp_dir
      end

      expect(Feature::Foo::Users.enabled_for?(id: 1)).to eq(true)
      expect(Feature::Bar::Users.enabled_for?(id: 3)).to eq(true)
    end

    it "reloads configuration when #init is called" do
      Dir.mkdir("#{temp_dir}/foo")

      File.open("#{temp_dir}/foo/users.yml", "w") do |f|
        f.write("{\"id\": {\"in\": [1, 2]}}")
      end
      File.open("#{temp_dir}/foo/children.yml", "w") do |f|
        f.write("{\"id\": {\"in\": [1, 2]}}")
      end


      Toggles.configure do |c|
        c.features_dir = temp_dir
      end

      expect(Feature::Foo::Users.enabled_for?(id: 1)).to eq(true)
      expect(Feature::Foo::Children.enabled_for?(id: 1)).to eq(true)

      File.open("#{temp_dir}/foo/users.yml", "w") do |f|
        f.write("{\"id\": {\"in\": [2]}}")
      end

      File.unlink("#{temp_dir}/foo/children.yml")

      Toggles.init

      expect(Feature::Foo::Users.enabled_for?(id: 1)).to eq(false)
      expect { Feature::Bar::Children.enabled_for?(id: 1) }
        .to raise_error(Feature::ConstantLookup::Error, 'Feature::Bar')
      expect { Feature::Foo::Children.enabled_for?(id: 1) }
        .to raise_error(Feature::ConstantLookup::Error, 'Feature::Foo::Children')
    end
  end

  describe "#reinit_if_changed" do
    include_context "uses temp dir"

    it "reloads when the contents have changed" do
      Dir.mkdir("#{temp_dir}/features")

      Toggles.configure do |c|
        c.features_dir = "#{temp_dir}/features"
      end

      # the OS might reuse the inode if we do this in the obvious order
      Dir.mkdir("#{temp_dir}/features2")
      Dir.delete("#{temp_dir}/features")
      File.rename("#{temp_dir}/features2", "#{temp_dir}/features")

      expect(Toggles).to receive("init")
      Toggles.reinit_if_changed
    end

    it "does not reload when the contents have not changed" do
      Dir.mkdir("#{temp_dir}/features")

      Toggles.configure do |c|
        c.features_dir = "#{temp_dir}/features"
      end

      expect(Toggles).not_to receive("init")
      Toggles.reinit_if_changed
    end
  end
end

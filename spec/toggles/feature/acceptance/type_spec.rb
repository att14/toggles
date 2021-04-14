describe "Feature::Type" do
  specify 'deprecated' do
    aggregate_failures do
      expect(Feature::Type.enabled_for?(user_id: 1)).to eq true
      expect(Feature::Type.enabled_for?(user_id: 25)).to eq false
      expect(Feature::Type.enabled_for?(user_id: nil)).to eq false
    end
  end

  specify do
    aggregate_failures do
      expect(Feature.enabled?(:type, user_id: 1)).to eq(true)
      expect(Feature.disabled?(:type, user_id: 1)).to eq(false)
      expect(Feature.enabled?(:type, user_id: 25)).to eq(false)
      expect(Feature.enabled?(:nested_foo, :bar_baz, id: 25)).to eq(false)
      expect(Feature.enabled?(:nested_foo, :bar_baz, id: 1)).to eq(true)
      expect(Feature.disabled?(:type, user_id: 25)).to eq(true)
      expect(Feature.disabled?(:nested_foo, :bar_baz, id: 25)).to eq(true)
      expect(Feature.disabled?(:nested_foo, :bar_baz, id: 1)).to eq(false)
      expect { Feature.disabled?(:nested_foo, :bar_boz, id: 1) }.to raise_error(Feature::Unknown)
    end
  end
end

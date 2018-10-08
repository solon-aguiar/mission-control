RSpec.describe Localization do
  let(:valid_key) { :mission_plan }
  let(:valid_rich_key) { :travel_distance }
  let(:invalid_locale) { :en_BR }
  let(:locale) { :en_US }

  describe 'get_localized_string' do
    context 'when the locale is valid' do
      it 'returns the string based on the locale' do
        localization = described_class.new(locale)

        localized_string = localization.get_localized_string(valid_key)
        expect(localized_string).to eq('Mission plan:')
      end

      it 'returns args applied to string' do
        localization = described_class.new(locale)

        localized_string = localization.get_localized_string(valid_rich_key, "30")
        expect(localized_string).to eq('Travel distance: 30 km')
      end

      it 'returns nil if cannot find key' do
        localization = described_class.new(locale)

        localized_string = localization.get_localized_string('weird_key')
        expect(localized_string).to be(nil)
      end
    end

    context 'when the locale is invalid' do
      it 'returns the string in default locale' do
        localization = described_class.new(locale)
        localization.locale = invalid_locale

        localized_string = localization.get_localized_string(valid_key)
        expect(localized_string).to eq('Mission plan:')
      end

      it 'returns nil if cannot find key' do
        localization = described_class.new(locale)
        localization.locale = invalid_locale

        localized_string = localization.get_localized_string('weird_key')
        expect(localized_string).to be(nil)
      end
    end
  end

  describe 'format_integer' do
    it 'adds \, on thousands' do
      localization = described_class.new(locale)

      expect(localization.format_integer(0)).to eq('0')
      expect(localization.format_integer(10)).to eq('10')
      expect(localization.format_integer(100)).to eq('100')
      expect(localization.format_integer(100)).to eq('100')
      expect(localization.format_integer(1_000)).to eq('1,000')
      expect(localization.format_integer(151_416)).to eq('151,416')
      expect(localization.format_integer(1_350)).to eq('1,350')
      expect(localization.format_integer(1_350_123_123_123_123_123)).to eq('1,350,123,123,123,123,123')
    end
  end

  describe 'format_float' do
    it 'rounds to 2 decimal places' do
      localization = described_class.new(locale)

      expect(localization.format_float(0)).to eq('0.00')
      expect(localization.format_float(0.1)).to eq('0.10')
      expect(localization.format_float(0.12)).to eq('0.12')
      expect(localization.format_float(137.3431)).to eq('137.34')
    end
  end

  describe 'format_time' do
    it 'rounds to 2 decimal places' do
      localization = described_class.new(locale)

      expect(localization.format_time(0)).to eq('0:00:00')
      expect(localization.format_time(1000)).to eq('0:00:01')
      expect(localization.format_time(1_0000)).to eq('0:00:10')
      expect(localization.format_time(60_000)).to eq('0:01:00')
      expect(localization.format_time(600_000)).to eq('0:10:00')
      expect(localization.format_time(3_600_000)).to eq('1:00:00')
      expect(localization.format_time(3_661_000)).to eq('1:01:01')
    end
  end
end
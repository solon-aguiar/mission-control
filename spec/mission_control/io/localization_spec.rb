RSpec.describe Localization do
  let (:valid_key) { :mission_plan }
  let (:valid_rich_key) { :travel_distance }
  let (:invalid_locale) { :en_BR }
  let (:locale) { :en_US }

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
        expect(localized_string).to eq("Travel distance: 30 km")
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
end
RSpec.describe IO::Input do
  let(:choice_message) { 'What is your choice? (blue/red)' }
  let(:question) { 'What is your name?' }
  let(:invalid_prompt) { 'That\'s not a valid value, please try again!' }
  let(:name) { 'Minerva' }
  let(:options) {
    {
      'blue' => :blue,
      'red' => :red
    }
  }

  describe 'get_option' do
    it 'maps valid input to appropriate symbol' do
      allow($stdin).to receive(:gets).once.and_return('blue')
      allow(IO::Output).to receive(:write).once.with("#{choice_message} ")

      option = described_class.get_option(choice_message, options, invalid_prompt)
      expect(option).to be(:blue)
    end

    it 'does not accept invalid options' do
      allow($stdin).to receive(:gets).exactly(3).times.and_return('bl', "\n", 'blue')
      allow(IO::Output).to receive(:write).exactly(3).times.with("#{choice_message} ")
      allow(IO::Output).to receive(:write_line).exactly(2).times.with(invalid_prompt)

      option = described_class.get_option(choice_message, options, invalid_prompt)
      expect(option).to be(:blue)
    end

    it 'ignores whitespaces' do
      allow($stdin).to receive(:gets).once.and_return(' red ')
      allow(IO::Output).to receive(:write).once.with("#{choice_message} ")

      option = described_class.get_option(choice_message, options, invalid_prompt)
      expect(option).to be(:red)
    end

    it 'ignores newlines' do
      allow($stdin).to receive(:gets).once.and_return(" red \n")
      allow(IO::Output).to receive(:write).once.with("#{choice_message} ")

      option = described_class.get_option(choice_message, options, invalid_prompt)
      expect(option).to be(:red)
    end
  end

  describe 'get_string' do
    it 'accepts a non-empty input' do
      allow($stdin).to receive(:gets).once.and_return(name)
      allow(IO::Output).to receive(:write).once.with("#{question} ")

      response = described_class.get_mission_name(question, invalid_prompt)
      expect(response).to eq(name)
    end

    it 'does not accept invalid inputs' do
      allow($stdin).to receive(:gets).exactly(4).times.and_return('', '  ', "\n", name)
      allow(IO::Output).to receive(:write).exactly(4).times.with("#{question} ")
      allow(IO::Output).to receive(:write_line).exactly(3).times.with(invalid_prompt)

      response = described_class.get_mission_name(question, invalid_prompt)
      expect(response).to eq(name)
    end

    it 'does not ignore spaces for valid inputs' do
      padded_name = "  #{name} "
      allow($stdin).to receive(:gets).once.and_return(padded_name)
      allow(IO::Output).to receive(:write).once.with("#{question} ")

      response = described_class.get_mission_name(question, invalid_prompt)
      expect(response).to eq(padded_name)
    end
  end
end
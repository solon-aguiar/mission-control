RSpec.describe IO::Output do
  let (:test_message) { 'test message string' }

  describe 'write' do
    it 'prints to the stdout' do
      expect {
        described_class::write(test_message)
      }.to output(test_message).to_stdout
    end
  end

  describe 'write_line' do
    it 'puts to the stdout' do
      expect {
        described_class::write_line(test_message)
      }.to output("#{test_message}\n").to_stdout
    end
  end
end
RSpec.describe MissionControl do
  it 'runs the test' do
    game = described_class.new
    expect(game.play).to eq('game on!')
  end
end

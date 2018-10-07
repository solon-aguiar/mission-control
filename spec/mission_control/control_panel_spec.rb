RSpec.describe MissionControl::ControlPanel do
  let(:mission_name) { 'Minerva' }

  describe 'create_mission' do
    it 'returns a new mission' do
      control_panel = described_class.new

      mission = control_panel.create_mission(mission_name, 3)
      expect(mission).to be_a(Mission::Mission)
      expect(mission.name).to eq(mission_name)
    end
  end

  describe 'all_summaries' do
    it 'returns the summaries for all missions' do
      control_panel = described_class.new

      control_panel.create_mission(mission_name, 3)
      control_panel.create_mission(mission_name, 4)
      control_panel.create_mission(mission_name, 5)

      summaries = control_panel.all_summaries
      expect(summaries.size).to be(3)
    end
  end
end
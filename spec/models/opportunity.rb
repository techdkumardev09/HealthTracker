require 'rails_helper'

RSpec.describe Opportunity, type: :model do
  describe 'associations' do
    it { should belong_to(:patient).class_name('Member') }
    it { should belong_to(:doctor).class_name('Member') }
  end

  describe 'validations' do
    it { should validate_presence_of(:procedure_name) }
  end

  describe 'scopes' do
    describe '.fuzzy_search' do
      let!(:opportunity) { create(:opportunity, procedure_name: 'Procedure Name') }

      it 'returns opportunities matching the search term' do
        results = Opportunity.fuzzy_search('Procedure')
        expect(results).to include(opportunity)
      end

      it 'ignores case in the search term' do
        results = Opportunity.fuzzy_search('procedure')
        expect(results).to include(opportunity)
      end

      it 'returns opportunities with matching patient or doctor names' do
        patient = create(:member, first_name: 'John', last_name: 'Doe')
        doctor = create(:member, first_name: 'Jane', last_name: 'Smith')
        opportunity.update(patient: patient, doctor: doctor)

        results_patient = Opportunity.fuzzy_search('John')
        results_doctor = Opportunity.fuzzy_search('Jane')

        expect(results_patient).to include(opportunity)
        expect(results_doctor).to include(opportunity)
      end
    end
  end

  describe 'methods' do
    describe '#transition' do
      it 'transitions to the next stage' do
        opportunity = create(:opportunity, stage_history: [{ stage_name: 'lead', timestamp: Time.current }])
        opportunity.transition

        expect(opportunity.current_stage).to eq('qualified')
      end

      it 'does not transition if already in the final stage' do
        opportunity = create(:opportunity, stage_history: [{ stage_name: 'treated', timestamp: Time.current }])
        opportunity.transition

        expect(opportunity.current_stage).to eq('treated')
      end
    end

    describe '#next_stage' do
      it 'returns the next stage based on the current stage' do
        opportunity = create(:opportunity)

        expect(opportunity.next_stage('lead')).to eq('qualified')
        expect(opportunity.next_stage('qualified')).to eq('booked')
        expect(opportunity.next_stage('booked')).to eq('treated')
        expect(opportunity.next_stage('treated')).to eq('treated')
      end
    end

    describe '#current_stage' do
      it 'returns the current stage from the stage history' do
        opportunity = create(:opportunity, stage_history: [{ stage_name: 'qualified', timestamp: Time.current }])

        expect(opportunity.current_stage).to eq('qualified')
      end

      it 'returns nil if there is no stage history' do
        opportunity = create(:opportunity, stage_history: nil)

        expect(opportunity.current_stage).to be_nil
      end
    end
  end
end

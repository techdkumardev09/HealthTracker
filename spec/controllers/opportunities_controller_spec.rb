require 'rails_helper'

RSpec.describe OpportunitiesController, type: :controller do
  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'returns opportunities when search parameter is present' do
      opportunity = create(:opportunity)
      get :index, params: { search: 'Pro' }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to include(JSON.parse(OpportunitySerializer.new(opportunity).to_json))
    end

    it 'returns all opportunities when search parameter is not present' do
      opportunities = create_list(:opportunity, 3)
      get :index
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).count).to eq(opportunities.count)
    end
  end

  describe 'GET #show' do
    let(:opportunity) { create(:opportunity) }

    it 'returns a success response' do
      get :show, params: { id: opportunity.id }
      expect(response).to have_http_status(:success)
    end

    it 'returns the correct opportunity' do
      get :show, params: { id: opportunity.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(JSON.parse(OpportunitySerializer.new(opportunity).to_json))
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) do
        {
          opportunity: {
            procedure_name: 'Procedure Name',
            patient_id: create(:member).id,
            doctor_id: create(:member).id,
            stage_history: [{ stage_name: 'Stage 1', timestamp: Time.current }]
          }
        }
      end

      it 'creates a new opportunity' do
        expect {
          post :create, params: valid_params
        }.to change(Opportunity, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include(JSON.parse(OpportunitySerializer.new(Opportunity.last).to_json))
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          opportunity: {
            procedure_name: '', # Invalid: Procedure name is required
            patient_id: create(:member).id,
            doctor_id: create(:member).id
          }
        }
      end

      it 'does not create a new opportunity' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Opportunity, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    let(:opportunity) { create(:opportunity) }

    context 'with valid params' do
      let(:valid_params) do
        {
          id: opportunity.id,
          opportunity: {
            procedure_name: 'Updated Procedure Name'
          }
        }
      end

      it 'updates the opportunity' do
        put :update, params: valid_params
        expect(response).to have_http_status(:success)
        expect(opportunity.reload.procedure_name).to eq('Updated Procedure Name')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          id: opportunity.id,
          opportunity: {
            procedure_name: '' # Invalid: Procedure name is required
          }
        }
      end

      it 'does not update the opportunity' do
        put :update, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(opportunity.reload.procedure_name).not_to eq('')
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:opportunity) { create(:opportunity) }

    it 'destroys the opportunity' do
      expect {
        delete :destroy, params: { id: opportunity.id }
      }.to change(Opportunity, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'PATCH #update_stage_history' do
    let(:opportunity) { create(:opportunity) }

    context 'with valid params' do
      let(:valid_params) do
        {
          id: opportunity.id,
          opportunity: {
            stage_history: [{ stage_name: 'qualified', timestamp: Time.current }]
          }
        }
      end

      it 'updates the stage history' do
        patch :update_stage_history, params: valid_params
        expect(response).to have_http_status(:success)
        expect(opportunity.reload.stage_history.last['stage_name']).to eq('qualified')
      end
    end
  end
end

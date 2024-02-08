require 'rails_helper'

RSpec.describe "Members", type: :request do
  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) do
        {
          member: {
            first_name: 'John',
            last_name: 'Doe',
            gender: 'male',
            age: 30,
            role: 'doctor'
          }
        }
      end

      let(:expected_response_keys) do
        %w[
          id
          full_name
          gender
          age
          role
          avatar_url
        ]
      end

      it 'creates a new member' do
        expect {
          post '/members', params: valid_params
        }.to change(Member, :count).by(1)

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body).keys).to eq(expected_response_keys)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          member: {
            first_name: '', # Invalid: First name is required
            last_name: 'Doe',
            gender: 'male',
            age: 30,
            role: 'doctor'
          }
        }
      end

      it 'does not create a new member' do
        expect {
          post '/members', params: invalid_params
        }.not_to change(Member, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #doctors' do
    let!(:doctor) { create(:member, role: "doctor") }

    it 'returns a list of doctors' do
      get '/members/doctors'
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to include(JSON.parse(MemberSerializer.new(doctor).to_json))
    end
  end

  describe 'GET #patients' do
    let!(:patient) { create(:member, role: "patient") }

    it 'returns a list of patients' do
      get '/members/patients'
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to include(JSON.parse(MemberSerializer.new(patient).to_json))
    end
  end
end

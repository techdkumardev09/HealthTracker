FactoryBot.define do
  factory :opportunity do
    procedure_name { 'Some Procedure' }
    stage_history { [{stage_name: 'lead', timestamp: Time.now}] }
    association :patient, factory: :member
    association :doctor, factory: :member
  end
end

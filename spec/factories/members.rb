FactoryBot.define do
  factory :member do
    first_name { 'John' }
    last_name { 'Doe' }
    gender { 'male' }
    role { 'doctor' }
    age { 27 }
  end
end

class Opportunity < ApplicationRecord
  belongs_to :patient, class_name: 'Member'
  belongs_to :doctor, class_name: 'Member'
end

class Opportunity < ApplicationRecord

  belongs_to :patient, class_name: 'Member'
  belongs_to :doctor, class_name: 'Member'

  validates :procedure_name, presence: true

  scope :fuzzy_search, ->(term) {
    where("procedure_name ILIKE :term OR "\
          "exists (SELECT 1 FROM members patients WHERE patients.id = opportunities.patient_id AND "\
          "(patients.first_name ILIKE :term OR patients.last_name ILIKE :term)) OR "\
          "exists (SELECT 1 FROM members doctors WHERE doctors.id = opportunities.doctor_id AND "\
          "(doctors.first_name ILIKE :term OR doctors.last_name ILIKE :term))",
          term: "%#{term}%")
  }

  def patient_name
    patient.full_name if patient.present?
  end

  def doctor_name
    doctor.full_name if doctor.present?
  end

  def transition
    next_stage = next_stage(current_stage)
    return true if next_stage == current_stage
    stage_history << { stage_name: next_stage, timestamp: Time.current }
    save
  end

  def next_stage(current_stage_name)
    case current_stage_name
    when 'lead'
      'qualified'
    when 'qualified'
      'booked'
    when 'booked'
      'treated'
    else
      current_stage_name
    end
  end

  def current_stage
    stage_history&.last&.dig("stage_name")
  end
end

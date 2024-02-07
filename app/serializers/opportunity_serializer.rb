class OpportunitySerializer < ActiveModel::Serializer
  attributes :id, :procedure_name, :patient, :doctor, :stage_history, :current_stage

  def patient
    MemberSerializer.new(object.patient).attributes if object.patient
  end

  def doctor
    MemberSerializer.new(object.doctor).attributes if object.doctor
  end

  def current_stage
    object.stage_history&.last&.dig("stage_name")
  end
end

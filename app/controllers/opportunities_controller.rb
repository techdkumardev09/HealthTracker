class OpportunitiesController < ApplicationController
  before_action :set_opportunity, only: [:show, :update, :destroy, :update_stage_history]

  def index
    opportunities = if params[:search].present?
                      Opportunity.fuzzy_search(params[:search])
                    else
                      Opportunity.all
                    end

    render json: opportunities, each_serializer: OpportunitySerializer
  end

  def show
    render json: @opportunity, each_serializer: OpportunitySerializer
  end

  def create
    opportunity = Opportunity.new(opportunity_params)

    if opportunity.save
      render json: opportunity, each_serializer: OpportunitySerializer, status: :created
    else
      render json: { errors: opportunity.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @opportunity.update(opportunity_params)
      render json: @opportunity, each_serializer: OpportunitySerializer
    else
      render json: { errors: @opportunity.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @opportunity.destroy
    head :no_content
  end

  def update_stage_history
    current_stage = @opportunity.stage_history.last&.dig("stage_name")
    new_stage = transition(current_stage)
    return true if new_stage == current_stage
    @opportunity.stage_history << { stage_name: new_stage, timestamp: Time.current }
    if @opportunity.save
      render json: @opportunity, each_serializer: OpportunitySerializer
    else
      render json: { errors: @opportunity.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_opportunity
    @opportunity = Opportunity.find(params[:id])
  end

  def opportunity_params
    params.require(:opportunity).permit(:procedure_name, :patient_id, :doctor_id, stage_history: [])
  end

  def transition(current_stage)
    case current_stage
    when nil
      'lead'
    when 'lead'
      'qualified'
    when 'qualified'
      'booked'
    when 'booked'
      'treated'
    else
      current_stage
    end
  end
end

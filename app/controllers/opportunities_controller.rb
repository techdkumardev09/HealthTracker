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
    if @opportunity.transition
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
    params.require(:opportunity).permit(:procedure_name, :patient_id, :doctor_id, stage_history: [:stage_name, :timestamp]).tap do |processed_params|
      stage_history = processed_params[:stage_history]
  
      stage_history&.each { |history| history[:timestamp] = history[:timestamp].to_datetime if history[:timestamp].present? }
    end
  end
end

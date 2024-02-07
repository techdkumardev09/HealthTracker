class MembersController < ApplicationController
  def create
    member = Member.new(member_params)

    if member.save
      render json: member, serializer: MemberSerializer, status: :created
    else
      render json: { errors: member.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def doctors
    render json: Member.doctor, each_serializer: MemberSerializer, status: :ok
  end

  def patients
    render json: Member.patient, each_serializer: MemberSerializer, status: :ok
  end

  private

  def member_params
    params.require(:member).permit(:first_name, :last_name, :gender, :age, :role, :avatar)
  end
end

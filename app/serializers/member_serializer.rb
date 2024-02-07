class MemberSerializer < ActiveModel::Serializer

  attributes :id, :full_name, :gender, :age, :role, :avatar_url

  def full_name
    "#{object.first_name} #{object.last_name}"
  end

  def avatar_url
    if object.avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_url(object.avatar)
    else
      nil
    end 
  end
end

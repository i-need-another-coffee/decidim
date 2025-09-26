# frozen_string_literal: true

# This class overrides the two methods of the parent class ensuring that the
# user has a previous sms authorization with the same phone number provided in
# the initiative signature workflow. In this way only the sms code received in
# the phone is verified and no previous authorization is necessary.
class DummySmsMobilePhoneValidator < Decidim::Initiatives::ValidateMobilePhone
  # Public: Initializes the command.
  #
  # form - A MobilePhoneForm.
  # user - The user which mobile phone must be validated.
  def initialize(form, user)
    @form = form
    @user = user
  end

  # Executes the command. Broadcasts these events:
  #
  # - :ok when everything is valid. Returns the verification metadata of
  #       the form.
  # - :invalid if the user does not have an authorization for sms in ok
  #            status or the phone number associated with its
  #            authorization does not match the form number.
  def call
    return broadcast(:invalid) unless authorized? && phone_match?

    generate_code

    broadcast(:ok, @verification_metadata)
  end

  private

  def generate_code
    @verification_metadata = @form.verification_metadata
  end

  def authorizer
    return unless authorization

    Decidim::Verifications::Adapter.from_element(authorization_name).authorize(authorization, {}, nil, nil)
  end

  def authorization
    @authorization ||= Verifications::Authorizations.new(organization: @user.organization, user: @user, name: authorization_name).first
  end

  def authorization_name
    "sms"
  end

  def authorized? = true

  def phone_match? = true
end

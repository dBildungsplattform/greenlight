# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

class UserMailer < ApplicationMailer
  before_action :preset, :branding # :preset must be called before :branding.

  # Sends a test email
  def test_email
    mail(to: params[:to], subject: params[:subject])
  end

  def room_deletion_info
    @room_name = params[:room_name]
    mail(to: params[:to], subject: params[:subject])
  end

  def reset_password_email
    @user = params[:user]
    @reset_url = params[:reset_url]

    mail(to: email_address_with_name(@user.email, @user.name), subject: t('email.reset.password_reset'))
  end

  def activate_account_email
    @user = params[:user]
    @activation_url = params[:activation_url]

    mail(to: email_address_with_name(@user.email, @user.name), subject: t('email.activation.account_activation'))
  end

  def invitation_email
    @email = params[:email]
    @name = params[:name]
    @signup_url = params[:signup_url]

    mail(to: @email, subject: t('email.invitation.invitation_to_join'))
  end

  def new_user_signup_email
    @user = params[:user]
    @admin_panel_url = params[:admin_panel_url]
    emails = admin_emails

    return if emails.blank? # Dont send anything if no-one has EmailOnSignup enabled

    mail(to: emails, subject: t('email.new_user_signup.new_user'))
  end

  def inform_admins_blocked_users_inactivity_email
    @user = params[:user]
    Rails.logger.debug { "[UserMailer] Blocked user: #{@user.email}" }
    emails = get_all_admin_emails
    Rails.logger.debug { "[UserMailer] Admin emaild #{emails}" }
    email = mail(to: emails, subject: t('email.blocked.account_blocked'))
    if email.present?
      Rails.logger.debug '[UserMailer] Email has been queued for delivery.'
    else
      Rails.logger.debug '[UserMailer] Failed to queue email for delivery.'
    end
  end

  private

  def preset
    @provider = params[:provider] || 'greenlight'
    @base_url = params[:base_url]
  end

  def branding
    branding_hash = SettingGetter.new(setting_name: %w[PrimaryColor BrandingImage], provider: @provider).call
    @brand_image = ActionController::Base.helpers.image_url(branding_hash['BrandingImage'], host: @base_url)
    @brand_color = branding_hash['PrimaryColor']
  end

  def admin_emails
    # Find all the roles that have EmailOnSignup enabled
    role_ids = Role.joins(role_permissions: :permission).with_provider(@provider).where(role_permissions: { value: 'true' },
                                                                                        permission: { name: 'EmailOnSignup' })
                   .pluck(:id)

    User.where(role_id: role_ids).pluck(:email)
  end

  def get_all_admin_emails
    # Find the role that corresponds to 'Administrator'
    admin_role = Role.find_by(name: 'Administrator')
  
    # Get all users with the 'Administrator' role
    admins = User.where(role: admin_role)
  
    # Return their email addresses
    admin_emails = admins.pluck(:email)
    
    admin_emails
  end
end

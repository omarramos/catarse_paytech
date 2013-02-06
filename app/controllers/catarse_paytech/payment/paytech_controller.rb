require 'catarse_paytech/processors/paytech'

module CatarsePaytech::Payment
  class PaytechController < ApplicationController

    skip_before_filter :verify_authenticity_token, :only => [:notifications]
    skip_before_filter :detect_locale, :only => [:notifications]
    skip_before_filter :set_locale, :only => [:notifications]
    skip_before_filter :force_http

    before_filter :setup_gateway

    SCOPE = "projects.backers.checkout"

    layout :false

    def review
      @credit_card = ActiveMerchant::Billing::CreditCard.new
    end

    def notifications
      backer = Backer.find params[:id]
      response = @@gateway.details_for(backer.payment_token)
      if response.params['transaction_id'] == params['txn_id']
        build_notification(backer, response.params)
        render status: 200, nothing: true
      else
        render status: 404, nothing: true
      end
    rescue Exception => e
      ::Airbrake.notify({ :error_class => "Paytech Notification Error", :error_message => "Paytech Notification Error: #{e.inspect}", :parameters => params}) rescue nil
      render status: 404, nothing: true
    end

    def pay
      backer = current_user.backs.find params[:id]
      begin
        credit_card = build_creditcard

        if credit_card.valid?
          response = @@gateway.purchase(backer.value, credit_card, {
            ip: request.remote_ip,
            description: t('paytech_description', scope: SCOPE, :project_name => backer.project.name, :value => backer.display_value),
            notify_url: payment_notifications_paytech_url(id: backer.id)
          })

          backer.update_attribute :payment_method, 'Paytech'

          unless response.success?
            paytech_flash_error
            return redirect_to main_app.review_project_backers_path(backer_id: backer.id, project_id: backer.project.id, accepted_terms: true)
          end

          build_notification(backer, response.params)
          backer.update_attribute :payment_id, response.authorization

          session[:thank_you_id] = backer.project.id
          paytech_flash_success
          redirect_to main_app.thank_you_path
        else
          flash[:failure] = t('credit_card_invalid', scope: SCOPE)
          return redirect_to main_app.review_project_backers_path(backer_id: backer.id, project_id: backer.project.id, accepted_terms: true)
        end
      rescue Exception => e
        ::Airbrake.notify({ :error_class => "Paytech Error", :error_message => "Paytech Error: #{e.inspect}", :parameters => params}) rescue nil
        Rails.logger.info "-----> #{e.inspect}"
        paytech_flash_error
        return redirect_to main_app.new_project_backer_path(backer.project)
      end
    end

    def cancel
      backer = current_user.backs.find params[:id]
      flash[:failure] = t('paytech_cancel', scope: SCOPE)
      redirect_to main_app.new_project_backer_path(backer.project)
    end

  private

    def build_creditcard
      credit_card = ActiveMerchant::Billing::CreditCard.new(params[:active_merchant_billing_credit_card])
      name_on_card = params[:card][:name_on_card]
      split_name = name_on_card.split(" ")
      credit_card.first_name = split_name.first
      credit_card.last_name = split_name[1] if split_name.length > 1

      credit_card.year = params[:card_expires_on]["card_expires_on(1i)"]
      credit_card.month = params[:card_expires_on]["card_expires_on(2i)"]
      credit_card.type = ActiveMerchant::Billing::CreditCard.type?(credit_card.number)
      credit_card
    end

    def build_notification(backer, data)
      processor = CatarsePaytech::Processors::Paytech.new
      processor.process!(backer, data)
    end

    def paytech_flash_error
      flash[:failure] = t('paytech_error', scope: SCOPE)
    end

    def paytech_flash_success
      flash[:success] = t('success', scope: SCOPE)
    end

    def setup_gateway
      if ::Configuration[:paytech_username] and ::Configuration[:paytech_password]
        @@gateway ||= ActiveMerchant::Billing::PaytechGateway.new({
          :login => ::Configuration[:paytech_username],
          :password => ::Configuration[:paytech_password],
          :company => ::Configuration[:paytech_company]
        })
      else
        puts "[Paytech] username and password required"
      end
    end
  end
end

module CatarsePaytech
  module Processors
    class Paytech

      def process!(backer, data)
        status = data["response_code"].to_i || ActiveMerchant::Billing::PaytechGateway::DECLINED

        notification = backer.payment_notifications.new({
          extra_data: data
        })

        notification.save!

        backer.confirm! if success_payment?(status)
      rescue Exception => e
        ::Airbrake.notify({ :error_class => "Paytech Processor Error", :error_message => "Paytech Processor Error: #{e.inspect}", :parameters => data}) rescue nil
      end

      protected

      def success_payment?(status)
        status == ActiveMerchant::Billing::PaytechGateway::APPROVED
      end

    end
  end
end

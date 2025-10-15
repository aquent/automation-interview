require_relative '../../../utils/spec_helper'
require_relative '../../../utils/db_util'
require_relative '../../../utils/cloudwall/order_util'
require_relative '../../../utils/talent_rtw_util'

module CloudWall
  describe 'Queue Australia Orders to send to Ceridian' do
    include Util
    include DBUtil

    it 'should add order to queue when order is filled', issue: 'BIZ-27391' do
      visit_and_login_as @config.admin_user_name

      order_id = create_new_melbourne_order
      visit OrderViewDetail, order_id
      main_page.edit
      main_page.type_financial_value 90, :regular_pay_rate
      main_page.type_financial_value 180, :regular_bill_rate
      main_page.save_accept_alert

      db = create_db_connection
      query_result = db.exec(@data['au_talent'])
      db.close
      
      talent_id = query_result[0]['person_id']
      
      quick_fill_modal = main_page.open_quick_fill
      quick_fill_modal.talent_id = talent_id
      quick_fill_modal.work_location_type = :report_to
      quick_fill_modal.tax_area = @data['tax_area']
      main_page.accept_alert do
        quick_fill_modal.submit
        check_and_dismiss_auto_rejection_email_modal
      end

      db = create_db_connection
      order_in_queue = db.exec(@data['order_added_to_queue_sql'] % order_id)
      db.close

      expect(order_in_queue.count).to be >= 1
    end
  end
end

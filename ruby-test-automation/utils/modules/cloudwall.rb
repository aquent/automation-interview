require_relative '../../data/cloudwall/common_data'
require_relative '../dsl_util'
require_relative '../mapping_util'
require_relative '../page_util'
require_relative '../search_util'
require_relative '../url_util'
require_relative '../util'

module CloudWall

  AquentDSL.describe self, :cloudwall, {
      server: 'app',
      browser: true,
      frames: true
  }

  module Util
    include ::Util

    CONTEXT_PATH = ''
    SERVLET_PATH = '/webwall'
    SESSION_COOKIE_NAME = 'CWSESSIONID'
    CW_DOMAIN = ENV['SERVER_HOST'].split('.').first

    include UrlUtil[CONTEXT_PATH, SERVLET_PATH]
    include MappingUtil[CONTEXT_PATH, SERVLET_PATH]

    # spec variable name => frame ID/name
    PAGE_MAPPINGS = {
        main_page:                         'mainFrame',
        search_top_page:                   'topFrame',
        results_page:                      'resultsFrame',
        todo_area_list:                    'sal_TalentToDos',
        activity_history_page_talent:      'sal_Talent_ActivityHistory',
        activity_history_page_order:       'sal_Activity',
        activity_history_page_contact:     'sal_Contact_ActivityHistory',
        activity_history_contact_snapshot: 'sal_AHLast2Weeks',
        activity_history_client_snapshot:  'sal_TwoWeekActivityHistory',
        activity_history:                  'sal_ActivityHistory',
        work_history_page:                 'sal_TalentDetail_WorkHistory',
        current_future_jobs_page:          'sal_TalentDetail_CurrentFutureJobs',
        contacts_on_client_detail:         'sal_Contacts',
        filled_orders_area_list:           'sal_filledOrders',
        unfilled_orders_area_list:         'sal_unfilledOrders',
        closed_orders_area_list:           'sal_closedOrders',
        invoices_area_list:                'sal_invoices',
        client_statement_invoice_list:     'sal_Invoices',
        splash_screen_to_do:               'smf_1',
        current_candidates:                'CurrentCandidatesFrame',
        paper_timecards_list:              'UnapprovedPaperTimecardsFrame',
        mac_timecards_list:                'UnapprovedOnlineTimecardsFrame',
        imported_timecards_list:           'UnapprovedVmsTimecardsFrame',
        fees_list:                         'UnapprovedFeeListFrame',
        approved_list:                     'approvedFrame',
        order_search_page:                 'talentOrderSearch',
        destination_order_search:          'destinationOrderSearch',
        possible_candidates:               'PossibleCandidatesFrame',
        order_fees:                        'FeeListFrame',
        contact_detail_page:               'contact-detail',
        aquents_book_page:                 'AquentsBook',
        benefits_activity_history:         'benefits_activity_history'
    }
    include PageUtil[PAGE_MAPPINGS]

    # Visits a URL or page and logs in if needed.
    #
    # @see UrlUtil#visit
    def visit_and_login(page = Frameset, *params)
      page_url = get_url_for_page page, *params
      username = @config.agent_user_name
      restore_cookies username
      visit page_url
      if top_page.is_a? Login
        visit LegacyLogin
        top_page.login
        store_cookies username
      end
      check_google_auth if top_page.is_a? Frameset
    end

    # Visits a URL or page and logs in if needed with the specified credentials.
    #
    # @see UrlUtil#visit
    def visit_and_login_as(username, page = Frameset, *params)
      page_url = get_url_for_page page, *params
      restore_cookies username
      visit page_url
      if top_page.is_a? Login
        visit LegacyLogin
        top_page.login
        visit SwitchUser, {user: username}
        store_cookies username
        if top_page.find('body').text.include? 'HTTP Status 401 – Unauthorized'
          raise "Unauthorized user - #{@driver.current_url.split('=')[1]}"
        end
        visit page_url
      end
      check_google_auth if top_page.is_a? Frameset
    end

    # Visits a URL or page and logs in if needed with the specified credentials (must pass in Expert Interviewer in username).
    #Similar to 'visit_and_login_as' method but expecting a different page upon arrival
    #
    # @see UrlUtil#visit
    def visit_and_login_as_expert_interviewer(username, page = Frameset, *params)
      page_url = get_url_for_page page, *params
      restore_cookies username
      visit page_url
      if top_page.is_a? Login
        visit LegacyLogin
        top_page.login
        visit SwitchUser, {user: username}
        store_cookies username
      end
      expect(top_page).to be_a ExpertInterview
    end

    # Masquerades as a new / different user. Assumes we're already logged in to CloudWall.
    def masquerade_as_new_user(username, page = Frameset, *params)
      page_url = get_url_for_page page, *params
      restore_cookies username
      visit SwitchUser, {user: username}
      store_cookies username
      if top_page.find('body').text.include? 'HTTP Status 401 – Unauthorized'
        raise "Unauthorized user - #{@driver.current_url.split('=')[1]}"
      end
      visit page_url
      check_google_auth if top_page.is_a? Frameset
    end

    def login_and_navigate_talent_detail(talent_data)
      visit_and_login TalentDetail, talent_data['person_id']
      expect(top_page).to be_a Frameset
      expect(main_page).to be_a TalentDetail
    end

    def login_and_navigate_snapshot_edit(talent_data)
      visit_and_login TalentDetail, talent_data['person_id']
      expect(top_page).to be_a Frameset
      expect(main_page).to be_a TalentDetail
      main_page.click_asaba 'AWUIDrawTalentEditPlacementInfo'
      expect(main_page).to be_a TalentEditDetail
    end

    # Restores CloudWall cookies for the specified username
    def restore_cookies(username)
      if defined? $session_cookies and (cookie = $session_cookies[username])
        print_info "Reusing session cookie for #{username} | #{cookie[:name]}=#{cookie[:value]}"
        # Can't add cookies unless we're on the right domain.
        unless @driver.current_url.include? SERVER_HOST
          visit base_url '/html/blank.html'
        end
        @driver.manage.delete_cookie SESSION_COOKIE_NAME
        @driver.manage.add_cookie cookie
        @driver.step_message = "Using stored authentication for #{username}"
      else
        @driver.step_message = "Logging in as #{username}"
      end
    end

    # Stores CloudWall cookies for the specified username
    def store_cookies(username)
      $session_cookies ||= {}
      if (cookie = @driver.manage.cookie_named SESSION_COOKIE_NAME)
        print_info "Storing session cookie for #{username} | #{cookie[:name]}=#{cookie[:value]}"
        $session_cookies[username] = cookie
        # HACK: Selenium 3 does not handle the SameSite attribute correctly, so this manually sets it so Angular apps work
        # TODO: remove this line when upgrading to Selenium 4
        $session_cookies[username]['sameSite'] = 'None'
      end
    end

    # Fixes the Google login URL if needed to include the correct `hd` parameter
    def fix_google_auth
      uri = URI.parse @driver.current_url
      query = UrlUtil.parse_query uri.query
      domain = @config.google_username.split('@')[1]
      if query[:hd] != domain
        query[:hd] = domain
        uri.query = URI.encode_www_form query
        visit uri.to_s
      end
    end

    # Checks CloudWall Google authorization
    # FIXME is this needed anymore?
    def check_google_auth
      if top_page.is_displayed? :email_provider_dialog
        top_page.click :connect_to_google

        # We might already be logged in to Google
        top_page(1).login if top_page(1).is_a? Google::Login
        top_page(1).accept if top_page(1).is_a? Google::Authorize
        top_page(1).continue if top_page(1).is_a? Google::Danger
        top_page(1).accept if top_page(1).is_a? Google::Authorize

        expect(top_page 1).to be_a GoogleConnected
        top_page(1).click :confirm_button

        expect(top_page).to be_a Frameset
        expect(top_page.is_displayed? :email_provider_dialog).to be_false
      end
    end

  end

  module ManageCandidatesUtil
    # Travel to manage candidates for the order with the specified ID.
    #
    # @param [Integer] order_id the ID of the order
    def visit_manage_candidates(order_id)
      visit OrderViewDetail, order_id
      expect(main_page).to be_a OrderViewDetail

      main_page.click_asaba 'AWUIDrawManageCandidates'
      expect(main_page).to be_a ManageCandidates
    end

    def visit_manage_candidates_for_pool(order_id)
      visit OrderViewDetail, order_id
      expect(main_page).to be_a TalentPoolViewActionScreen

      main_page.click_asaba 'AWUIDrawManageCandidates'
      expect(main_page).to be_a ManageCandidates
    end

    def visit_candidate_info
      top_page.open_module :talentboard
      expect(main_page).to be_a RedeployBoardModulePage
    end
  end

  module CandidateStagesUtil
    def popout_framed_candidate_stages
      url = main_page.find(:candidate_stages_frame).attribute('src')
      visit url
      wait_until -> () {top_page.is_a? OrderApp::CandidateStages}
      url
    end

    def switch_to_stages_frame
      stages_frame = main_page.find({id: "CandidateStages"})
      #@driver.pause_auto_switch
      #@driver.pause_frame_updates
      @driver.switch_to.frame stages_frame
    end

    def switch_back_to_default_content
      # Revert to main_frame
      @driver.resume_frame_updates
      @driver.update_frames
      @driver.switch_to.default_content
      #@driver.resume_auto_switch
      @driver.update_frames
    end
  end

  module AquentsBookUtil
    # Visits the Aquent's Book app via the CloudWall module link.
    def visit_aquents_book_module
      top_page.open_module :aquents_book
      expect(main_page).to be_a AquentsBookModulePage
    end

    def visit_redeploy_board_module
      top_page.open_module :talentboard
      expect(main_page).to be_a RedeployBoardModulePage
    end

    # Opens the Aquent's Book using the src url found in app's iframe in CloudWall.
    def popout_framed_aquents_book
      url = main_page.find(:aquents_book_frame).attribute('src')
      # TODO would be better to dive into iframe rather then grab url and redirect
      # TODO However, this isn't possible with javascript frame traversal. We would need to traverse frames with selenium instead.
      visit url
      wait_until -> () {top_page.is_a? AquentsBook::PortfolioSearch}
      url
    end

    # Opens the Redeploy Me using the src url found in app's iframe in CloudWall.
    def popout_framed_redeploy_board_no_cache
      url = main_page.find(:redeploy_board_frame).attribute('src')
      visit url + "?cache=false"
      wait_until -> () {top_page.is_a? AquentsBook::RedeployBoardPage}
    end

    def get_framed_redeploy_board_url
      return main_page.find(:redeploy_board_frame).attribute('src')
    end

    def get_framed_redeploy_board_no_cache_url
      return main_page.find(:redeploy_board_frame).attribute('src') + "?cache=false"
    end

    def popout_framed_redeploy_board
      url = main_page.find(:redeploy_board_frame).attribute('src')
      visit url
      wait_until -> () {top_page.is_a? AquentsBook::RedeployBoardPage}
    end
  end

  # Support class for cross-module tests
  class Support
    include CloudWall::Util

    def initialize(driver, config, window_index = 0)
      @driver = driver
      @config = config
      if window_index
        self.class.include PageUtil[Util::PAGE_MAPPINGS, window_index]
        @driver.switch_to.window @driver.window_handles[window_index]
      end
    end
  end
end

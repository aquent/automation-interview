require_relative '../../../utils/spec_helper'

module CloudWall

  describe 'Creating a new Talent' do
    include Util
    include UploadUtil

    before :each do
      visit_and_login
      expect(top_page).to be_a Frameset
    end

    it 'successfully checks for duplicates' do
      email_address = Time.now.to_i.to_s +  @data['talent_us']['talent']['email_address']
      click_create_new_talent(@data['talent_us']['talent']['basic_resume_doc'], email_address)
      main_page.submit_cancel
    end

    it 'should create a new talent from a doc resume' do
      email_address = Time.now.to_i.to_s +  @data['talent_us']['talent']['email_address']
      resume = @data['talent_us']['talent']['basic_resume_doc']
      click_create_new_talent(resume , email_address)
      validate_and_create_talent(resume, email_address)
    end

    it 'should create a new talent from a pdf resume' do
      email_address = Time.now.to_i.to_s +  @data['talent_us']['talent']['email_address']
      resume = @data['talent_us']['talent']['basic_resume_pdf']
      click_create_new_talent(resume, email_address)
      validate_and_create_talent(resume, email_address)
    end

    it 'and searching for said talent should return the correct results' do
      email_address = Time.now.to_i.to_s + @data['talent_uk']['talent']['email_address']
      resume = @data['talent_uk']['talent']['basic_resume_doc']
      click_create_new_talent(resume, email_address)
      validate_and_create_talent(resume, email_address, 'talent_uk')
      record_navBar = main_page.find(:talent_name).text
      record_navBar = record_navBar.split '-' # personName - personId - status
      top_page.open_module :talent
      main_page.run_quick_search record_navBar[1] # 1 being personId
      row_contents = results_page.get_content_for_row_number 1
      email = row_contents[:email].strip
      expect(email).to eq email_address
    end

    it 'should return duplicate talent if the new talents email matches any email associated with a talent or the username of at talent', issue:'BIZ-29006' do
      email_address = Time.now.to_i.to_s +  @data['talent_us']['talent']['email_address']
      expect(main_page).to be_a ListScreen
      search_top_page.click :go_button
      wait_for_search_complete
      @person_ids = []
      (1..3).each { |i|
        results_page.select_row_number i
        search_top_page.click_asaba_menu_item 'AWUIDrawTalentViewPlacementInfo', 2
        expect(main_page).to be_a TalentEditDetail
        main_page.switch_tab :profile
        case i
        when 1
          nav_bar = main_page.find(:talent_name).text.split(' - ')
          @person_ids.push(nav_bar[1])
          main_page.clear_and_type email_address, :profile, :email
          main_page.submit_save
        when 2
          nav_bar = main_page.find(:talent_name).text.split(' - ')
          @person_ids.push(nav_bar[1])
          main_page.click :fields, :add_email_button
          email_fields = main_page.find_all :profile, :email
          main_page.clear_and_type email_address, email_fields[email_fields.size - 2]
          main_page.submit_save
        when 3
          nav_bar = main_page.find(:talent_name).text.split(' - ')
          @person_ids.push(nav_bar[1])
          main_page.accept_alert do
            main_page.click_asaba 'AWUIDrawTalentRolesAccess'
          end
          expect(main_page).to be_a TalentRolesAccess
          main_page.switch_tab :edit_username_password
          main_page.set_field :mat_access_button_yes, 'click'
          main_page.new_user_name = email_address
          main_page.click :save_button
        end
      }
      click_create_new_talent_with_dupes(@data['talent_us']['talent']['basic_resume_doc'], email_address)
    end

    def click_create_new_talent(resume, email_address)
      create_new_talent(resume, email_address)
      expect(main_page).to be_a TalentEditDetail
    end

    def click_create_new_talent_with_dupes(resume, email_address)
      create_new_talent(resume, email_address)
      expect(main_page.displayed? :duplicate_email_table).to be_true
      row_contains_email_count = 0
      rows = main_page.find_all(:duplicate_talent_row)
      rows.each_with_index { |row, i|
        if row.attribute('innerHTML').include? email_address
          row_contains_email_count += 1
        end
      }
      expect(row_contains_email_count). to eq @person_ids.length

    end

    def create_new_talent (resume, email_address)
      top_page.open_menu :talent
      top_page.click_menu_item 1
      expect(main_page).to be_a TalentCreateNewTalentPage
      main_page.set_field_content :email_address_field, email_address
      main_page.resume = resume
      expect(main_page.find(:talent_resume).file).to end_with resume
      main_page.click_asaba 'checkForDupes'
    end

    def validate_and_create_talent(resume, email_address, yaml_section = nil)
      if yaml_section.nil?
        data = @data['talent_us'] # then use the original US talent
      else
        data = @data[yaml_section] # when bringing in a resume from UK not picking up country
        main_page.select_country data['talent']['country'] # so profile tab is active.
        main_page.switch_tab :summary
      end
      test_timestamp = Time.now.strftime '%Y-%b-%d_%H.%M.%S.%9N%z'
      expect(main_page.find(:summary, :first_name).value).to eq data['talent']['first_name']
      expect(main_page.find(:summary, :last_name).value).to eq data['talent']['last_name']
      main_page.minor_segment = data['talent']['minor_segment_id']
      main_page.set_moats_field_content :moats_min_hourly_field, @data['test_vals']['min_hourly']
      main_page.set_moats_field_content :moats_desired_hourly_field, @data['test_vals']['desired_hourly']
      main_page.set_moats_field_content :moats_min_yearly_salary_field, @data['test_vals']['yearly_salary']
      main_page.set_moats_field_content :moats_desired_yearly_salary_field, @data['test_vals']['desired_yearly_salary']
      main_page.click :summary, :moats_opportunity_contract_to_hire_checkbox
      main_page.click :summary, :moats_availability_active_search_yes
      main_page.click :summary, :moats_availability_type_available_now
      main_page.clear_and_type test_timestamp, :summary, :moats_availability_notes
      main_page.click :summary, :moats_travel_home_location
      main_page.clear_moats_type_ahead_input :moats_travel_home_location_input
      main_page.set_moats_field_content :moats_travel_home_location_input, data['talent']['home_location']
      main_page.wait_for_moats_select2_search_results
      main_page.click :summary, :moats_type_ahead_selection
      moats_travel_notes_content = @data['test_vals']['moats_travel_notes'] + ' ' + test_timestamp
      main_page.clear_and_type moats_travel_notes_content, :summary, :moats_travel_notes
      main_page.click :summary, :moats_skills
      main_page.clear_moats_type_ahead_input :moats_skills_input
      main_page.set_moats_field_content :moats_skills_input, test_timestamp
      main_page.wait_for_moats_select2_search_results
      main_page.click :summary, :moats_type_ahead_selection

      main_page.switch_tab :profile
      expect(main_page.find(:profile, :city).value).to eq data['talent']['city']
      expect(main_page.find(:profile, :state).value).to eq data['talent']['state'] unless data['talent']['state'].nil?
      expect(main_page.find(:profile, :postal_code).value).to eq data['talent']['postal_code']
      expect(main_page.find(:profile, :phone).value).to eq data['talent']['test_phone_number'] # first check from input/resume
      # need to overwrite the default test_phone_number if outside of North America
      main_page.set_field :phone, data['talent']['non_NA_phone'] unless data['talent']['non_NA_phone'].nil?
      expect(main_page.find(:profile, :email).value).to eq email_address
      main_page.professional_title = data['talent']['professional_title']

      main_page.switch_tab :interviews
      main_page.click :business_interviews, :new_button
      main_page.type @data['test_vals']['interview_comment'] + test_timestamp, :business_interviews, :fields, :comments
      main_page.click :business_interviews, :business_interview_disclosed_salary
      main_page.submit_save

      expect(main_page).to be_a TalentDetail
      main_page.switch_tab :talentDetail
      expect(main_page.find(:talentDetail,:talent_full_name).text).to eq data['talent']['full_name']
      expect(main_page.find(:talentDetail,:professional_title).text).to eq data['talent']['professional_title']
      expect(main_page.find(:talentDetail,:primary_phone).text).to eq data['talent']['test_phone_number_saved']
      expect(main_page.find(:talentDetail,:primary_email).text).to eq email_address
      expect(main_page.find(:talentDetail,:resume).text).to eq resume

      main_page.switch_tab :snapshot
      expect(main_page.find(:snapshot,:moats_min_hourly_rate).text).to eq data['talent']['min_hourly_value']
      expect(main_page.find(:snapshot,:moats_desired_hourly_rate).text).to eq data['talent']['desired_hourly_value']
      expect(main_page.find(:snapshot,:moats_min_yearly_salary).text).to eq data['talent']['yearly_salary_value']
      expect(main_page.find(:snapshot,:moats_desired_yearly_salary).text).to eq data['talent']['desired_yearly_salary_value']
      expect(main_page.find(:snapshot,:moats_opportunity_contract_to_hire_choice).text).to eq @data['test_vals']['opportunity']
      expect(main_page.find(:snapshot,:moats_availability_choice).text).to eq @data['test_vals']['available_now']
      expect(main_page.find(:snapshot,:moats_availability_notes).text).to eq test_timestamp
      expect(main_page.find(:snapshot, :moats_travel_home_location).text).to eq(data['talent']['home_location'])
      expect(main_page.find(:snapshot, :moats_travel_home_market).text).to eq(data['talent']['home_market'])
      expect(main_page.find(:snapshot, :moats_travel_notes).text).to eq(moats_travel_notes_content)
      expect(main_page.find(:snapshot, :moats_skills).text).to eq test_timestamp
      if data['talent']['use_segment_r19'].nil? # segment field is on row 18 or row 19, depending on talent
        expect(main_page.find(:snapshot, :segment).text).to eq data['talent']['minor_segment']
      else
        expect(main_page.find(:snapshot, :segment_r19).text).to eq data['talent']['minor_segment']
      end

      main_page.switch_tab :interviews
      view_content = main_page.get_business_interview_content 1
      view_content.each do |name, value|
        if name == 'comments'
          expect(value).to eq @data['test_vals']['interview_comment'] + test_timestamp
        elsif name == 'talent_provided_salary'
          expect(value).to eq @data['test_vals']['order_submit_to_client_spec.rb']
        end
      end
    end
  end
end

require_relative '../action_screen'
require_relative '../../../utils/cloudwall/tagging'

module CloudWall
  class TalentDetail < ActionScreen

    include Tagging

    PATH = /\/talent\/[0-9]+/
    OPEN_PATH = '/talent/%d'

    TAB_IDS = {
        talentDetail: 'talent-detail',
        snapshot: 'snapshot',
        profile: 'profile',
        portfolio: 'portfolio',
        public_profile: 'public-profile',
        interviews: 'interviews',
        assessments: 'assessments',
        attachments: 'attachments',
        references: 'references',
        work_history: 'work-history',
        referral_history: 'referral-history',
        activity_history: 'activity-history',
        review_history: 'review-history',
        talent_insights: 'talent-insights'
    }

    LOCATORS = {
        talent_insights: {
          first_review_header: {class: 'position-title'},
          first_review_client: {class: 'client-name'},
          first_review_text: {class: 'answers-container'}
        },
        activity_history: {
            correspondence_tab_button: {css: 'a[href="#correspondence-history-tab"]'},
            correspondence_table: {
                body: {css: '#correspondence-history-tab table tbody'},
                rows: {css: '#correspondence-history-tab table tbody tr'},
                show_email_column: {css: '#correspondence-history-tab table tbody tr td[class="sanitize"]'},
                show_email_column_button: {css: '#correspondence-history-tab table tbody tr td[class="sanitize"] a'},
                email_modal_body: {css: '#activityEmailModal div[class="modal-body"] div[class="content"] div'}
            },
            text_history_tab_button: {css: 'a[href="#text-history-tab"]'},
            text_history_frame: {id: 'text-history-tab-content'},
            activity_history_range: {id: 'activityHistoryRange'},
            table: {id: 'sal_Talent_ActivityHistory'},
        },
        talent_name: {css: '#recordNavBar .name'},
        showcase_button: {id: 'showcase-button'},
        content: {id: 'content'},
        coding_challenges: {
            section: {class: 'mettl-assessment-section'},
            header: {css: '#mettl-assessment-accordion .ui-accordion-header'},
            entry: {css: '#mettl-assessment-accordion > div'},
            header_fields: {
                name: {class: 'mettl-assessment-heading-name'},
                heading_status: {class: 'mettl-assessment-heading-status'}
            },
            entry_fields: {
                status: {class: 'mettl-assessment-status'},
                create_date: {class: 'mettl-assessment-create-date'}
            }
        },
        business_interviews: {
          header: {css: '#business-interview-accordion .ui-accordion-header'},
          entry: {css: '#business-interview-accordion > div'},
          fields: {
            comments: {class: 'comments-content'},
            interview_transcript_link: {id: 'interview-attachment'},
            talent_provided_salary: {xpath: '//*[@id="ui-id-2"]/div/div/div/span'}
          }
        },
        independent_assessment: {
            header: {css: '#expert-interview-accordion .ui-accordion-header'},
            fields: {
              summary_content: {class: 'summary-content'},
              recommended_position: {xpath: '//*[@id="ui-id-22"]/div/div[1]/div[3]/blockquote'},
              next_steps: {xpath: '//*[@id="ui-id-22"]/div/div[1]/div[4]/blockquote'},
              additional_info: {xpath: '//*[@id="ui-id-22"]/div/div[1]/div[5]/blockquote'}
            }
        },
        skill_assessments: {
            columns: {
                description: {css: 'td.type-column'},
                grade: {css: 'td.grade-column'},
                comments: {css: 'td.comments-column'}
            },
            default_message: {id: 'skill-assessment-default-message'},
            row: {css: '#skill-assessment-body tr'}
        },
        talentDetail: {
            #MOATS Money
            desired_hourly_rate: {xpath: '//div[contains(@ng-bind, "moats.M.desiredHourlyRate")]'},
            minimum_hourly_rate: {xpath: '//div[contains(@ng-bind, "moats.M.minimumHourlyRate")]'},
            desired_yearly_salary: {xpath: '//div[contains(@ng-bind, "moats.M.desiredYearlySalary")]'},
            minimum_yearly_salary: {xpath: '//div[contains(@ng-bind, "moats.M.minimumYearlySalary")]'},

            # MOATS Opportunity
            opportunity: {class: 'opportunity-content'},
            opportunity_selected: {class: 'fa'},
            temporary_selected: {css: '[ng-model="contractSelected"]'},
            temp_to_perm_selected: {css: '[ng-model="contractToHireSelected"]'},
            permanent_selected: {css: '[ng-model="permanentSelected"]'},
            part_time_selected: {css: '[ng-model="partTimeSelected"]'},
            full_time_selected: {css: '[ng-model="fullTimeSelected"]'},
            on_site_selected: {css: '[ng-model="onSiteSelected"]'},
            off_site_selected: {css: '[ng-model="offSiteSelected"]'},

            # MOATS Availability
            moats_availability_info:{xpath: '//div[@ng-bind="moats.A | availabilityFilter: availabilityTypes"]'},
            moats_last_updated:{xpath: '//div[contains(@class, "availability-content")]//em[contains(text(), "Last updated")]'},
            moats_availability_check_in_date:{xpath: '//div[contains(text(), "Check in and resume gather date")]'},
            moats_availability_edit_button: {id: 'availability_edit_button'},
            moats_availability_save_button: {id: 'availability_save_button'},
            moats_availability_notes_input: {id: 'availability_notes'},
            moats_availability_notes_display: {id: 'availability_notes_display'},
            moats_availability_active_search_yes: {id: 'talent_detail_'},
            moats_availability_active_search_no: {xpath: '//div[contains(@class, "value-option") and text() = "No:"]/following::input[contains(@class,"value-toggle")]'},
            moats_availability_preauth_submittal_yes_display: {id: 'moats_availability_preAuthorizedSubmittal_yes'},
            mmoats_availability_preauth_submittal_include_pi_yes_display: {id: 'moats_availability_preAuthorizedSubmittal_include_pi_yes'},
            moats_availability_preauth_submittal_no_display: {id: 'moats_availability_preAuthorizedSubmittal_no'},
            mmoats_availability_preauth_submittal_include_pi_no_display: {id: 'moats_availability_preAuthorizedSubmittal_include_pi_no'},
            moats_availability_preauth_submittal_yes_button: {id: 'preAuthorizedSubmittal'},
            moats_availability_preauth_submittal_include_pi_yes_button: {id: 'preAuthorizedSubmittalIncludePI'},
            moats_availability_is_preauth_submittal_yes_check: {id: 'isPreauthorizedSubmittal'},
            moats_availability_is_preauth_submittal_no_x: {id: 'isNotPreauthorizedSubmittal'},
            moats_availability_is_preauth_submittal_include_pi_yes_check: {id: 'includePersonalInfo'},
            moats_availability_is_preauth_submittal_include_pi_no_x: {id: 'isNotIncludePersonalInfo'},
            moats_availability_last_four_truth: {id: 'taxIdSSN_PEI'},
            moats_availability_birth_month_truth: {id: 'birthMonthFromSourceOfTruth'},
            moats_availability_birth_day_truth: {id: 'birthDayFromSourceOfTruth'},
            moats_availability_last_four_submittal: {id: 'taxIdSSN_Submital'},
            moats_availability_birth_month_submittal: {id: 'birthMonthFromSubmittalPiInfo'},
            moats_availability_birth_day_submittal: {id: 'birthDayFromSubmittalPiInfo'},

            # MOATS Travel
            moats_travel_edit_button: {id: 'travel_edit_button'},
            moats_travel_save_button: {id: 'travel_save_button'},
            moats_travel_home_market_id: {id: 'homeMarketId'},
            moats_travel_willing_to_relocate: {id: 'willingToRelocate'},
            moats_travel_relocation_market: {id: 'relocationMarkets-selectized'},
            moats_travel_relocation_market_option: {css: '#relocationDiv > div:nth-child(2) > div > div.selectize-dropdown.multi.markets.ng-pristine.ng-untouched.ng-valid.ng-isolate-scope > div > div.option.active'},
            moats_travel_relocation_market_text: {id: 'relocationMarketText'},
            moats_travel_is_willing_to_relocate: {id: 'isWillingToRelocate'},
            moats_travel_is_not_willing_to_relocate: {id: 'isNotWillingToRelocate'},
            moats_travel_home_market: {xpath: '//div[contains(text(), "Home Market:")]/following-sibling::div'},
            moats_travel_home_location_xpath: {xpath: '//div[contains(text(), "Home Location")]/following-sibling::div'},

            show_pi: {id: 'preAuthShow'},
            agent_summary_edit_button: {id: 'agent_summary_edit_button'},
            agent_summary_save_button: {id: 'agent_summary_save_button'},
            agent_summary_input: {id: 'agent_summary-edit'},
            agent_summary_display: {id: 'agent_summary-display'},
            talent_comments_edit_button: {id: 'talent_comments_edit_button'},
            talent_comments_save_button: {id: 'talent_comments_save_button'},
            talent_comments_input: {id: 'talent-comments-edit'},
            talent_comments_display: {id: 'talent-comments-display'},
            left_pane: {id: 'left-pane'},
            pinboard_pin_button: {id: 'pinboard-pin-button'},
            total_average_score: {id: 'talentDetailOverallRating'},
            qcc_history_link: {id: 'qcc-history-link'},
            talent_alert: {xpath: '//*[@id="right-pane"]/div[1]/div/span[2]/span'},
            talent_alert_box: {class: 'talent-alert'},
            talent_full_name: {xpath: '//*[@id="left-pane"]/h3'},
            professional_title: {xpath: '//*[@id="left-pane"]/h4'},
            full_address: {xpath: '//*[@id="left-pane"]/div[2]'},
            full_address_with_gather_response: {xpath: '//*[@id="left-pane"]/div[3]'},
            primary_phone: {id: 'primaryPhone'},
            primary_email: {id: 'primaryEmail'},
            secondary_email: {id: 'secondaryEmail'},
            resume: {id: 'talentResume'},
            agent_resume: {xpath: '//*[@id="left-pane"]/div[8]/a'},
            resumes: {css: '.attachment a'},
            segment: {xpath: '//*[@id="moats-pane"]/div[6]/div/div/div[3]/div[1]/span'},
            availability_to_start_immediately: {xpath: '//*[@id="moats-pane"]/div[4]/div/pane-edit-values/div[2]/div[2]/div[1]/input'},
            preferred_talent_name: {css: '#left-pane > h3:nth-child(2)'},
            time_zone: {id: 'time-zone'},
            authorized_to_work_us: {id: 'authorizedToWorkInUs'},
            requires_sponsorship: {id: 'requiresSponsorship'},
            phone_text_icon: {class: 'phone-text'},
            talent_first_url: {xpath: '//*[@id="left-pane"]/div[@id="talent-urls-container"]/div[@id="links"]/div[1]/a'},
            talent_second_url: {xpath: '//*[@id="left-pane"]/div[@id="talent-urls-container"]/div[@id="links"]/div[2]/a'},
            currently_working_at_link: {css: '#right-pane div.talent-alert a'},
            pending_reviews_link: {id: 'pending-reviews-link'},
            gather_response_rate: {class: 'gatherResponseRatePercentage'},
            preferred_pronouns: {id: 'preferredPronouns'}
        },

        snapshot: {
            industry_experience_text: {id: 'industry_experience_display_text'},
            coding_challenges: {css: '#snapshot .coding-challenges-entries'},
            skill_assessments: {css: '#snapshot .skill-assessments-entries'},
            manage_email_subscription_link: {id: 'manage-email-subscription-link'},
            moats: {id: 'moats-box'},
            moats_min_hourly_rate: {id: 'moats_min_hourly_rate'},
            moats_desired_hourly_rate: {id: 'moats_desired_hourly_rate'},
            moats_min_yearly_salary: {id: 'moats_min_yearly_salary'},
            moats_desired_yearly_salary: {id: 'moats_desired_yearly_salary'},
            moats_min_day_rate: {id: 'moats_min_day_rate'},
            moats_desired_day_rate: {id: 'moats_desired_day_rate'},
            moats_min_hourly_abbreviation: {id: 'moats_min_hourly_abbrev'},
            moats_desired_hourly_abbreviation: {id: 'moats_desired_hourly_abbrev'},
            moats_opportunity_contract_choice: {id: 'moats_opp_contract'},
            moats_opportunity_contract_to_hire_choice: {id: 'moats_opp_contract_to_hire'},
            moats_opportunity_part_time_choice: {id: 'moats_opp_part_time'},
            moats_opportunity_full_time_choice: {id: 'moats_opp_full_time'},
            moats_availability_who_updated_label: {id: 'moats_avail_who_updated_label'},
            moats_availability_choice: {id: 'moats_avail_option'},
            moats_availability_check_in_date: {id: 'moats_check_in_date'},
            moats_availability_notes: {id: 'moats_availability_notes'},
            moats_availability_preauth: {id: 'pre-auth-submittal'},
            moats_availability_submit_pi: {id: 'pre-auth-submittal-pi'},
            moats_availability_pi_SSN: {id: 'moats_availability_preAuthorizedSubmittal_SNN'},
            moats_availability_pi_birthday: {id: 'moats_availability_preAuthorizedSubmittal_birthday'},
            moats_availability_display_pi_button: {id: 'moats_availability_hide_SNN_toggle'},
            moats_travel_interested_in_remote_ops: {id: 'interested_in_remote_opportunities_snapshot'},
            moats_travel_home_location_descriptor: {id: 'moats_travel_home_location_descriptor'},
            moats_travel_home_location: {id: 'moats_home_location_snapshot'},
            moats_travel_home_market: {id: 'moats_home_market_snapshot'},
            moats_travel_notes: {id: 'moats_travel_notes'},
            moats_skills: {id: 'moats_skills_snapshot'},
            action: {xpath: '//*[@id="tableNode"]/tbody/tr[1]/td[1]/a'},
            todo_table: {id: 'unlockedTableDiv'},
            disable_automated_checkin: {id: 'disable-automated-checkin'},
            left_column:    {
                class: 'left-column',
                locators: {
                    key: {css: '.field-container > div > span:first-of-type'},
                    value: {css: '.field-container > div > span:last-of-type'},
                }
            },
            snapshot_name:  {css: 'div.left-column > div.field-container > div'},
            right_column:   {css: '#snapshot .right-column'},
            open_roles:     {css: 'div.left-column > div > div:nth-child(4) > span:nth-child(2)'},
            segment:        {xpath: '//*[@id="moats_v2_content"]/table/tbody/tr[18]/td[2]/div/span'},
            segment_r19:    {xpath: '//*[@id="moats_v2_content"]/table/tbody/tr[19]/td[2]/div/span'},
            brief:          {css: '#resume-links > span:nth-child(1) > span:nth-child(5) > a'},
            personal_email: {xpath: '//*[@id="snapshot"]/div[2]/div/div[8]/span[2]/span'},
            time_zone: {id: 'snapshot-time-zone'},
            how_heard: {id: 'howHeard'},
            how_heard_other: {id: 'howHeardOther'},
            referred_by_talent: {id: 'referredByTalent'},
            non_talent_referrer_name: {id: 'nonTalentReferrerName'},
            non_talent_referrer_email: {id: 'nonTalentReferrerEmail'},
            double_opt_in_status: {id: 'doubleOptInStatus'}
        },
        profile: {
            agent_summary: {css: '.agent-summary .content'},
            talent_summary: {css: '.talent-summary .content'},
            profile_name: {css: 'div.right-column > h2 > div'},
            preferred_talent_name: {css: '.right-column > h2 > div:nth-child(2)'},
            agent_headline: {css: '.agent-summary > h4'},
            talent_headline: {css: '.talent-summary > h4'},
            profile_urls: {css: 'div.right-column > div'}
        },
        portfolio: {
            portfolio_sample_label: {id:'portfolio-label'}
        },
        references: {
            reference_section: {css: '.field-container'},
            no_references_found: {id:'noReferencesFound'},
            first_reference_name_label: {id:'referenceNameLabel0'}
        },
        work_history: {
            end_date: {xpath: '//*[@id="tableNode"]tbody/tr[1]/td[5]'}
        },
        referral_history: {
            talent_referrals_tab: {id:'talentReferralsTab'},
            available_points: {xpath: '//*[@id="referral-history"]/div/blockquote/span[1]'}
        },
        review_history: {
            reason_radio: {css:'.reasonRadio'},
            flag_review: {id: 'qcc-dialog-save'},
            average_qcc_num: {id: 'averageNum'},
            average_total_num: {id: 'averageOverallRatingNum'},
            pending_card: {class: 'pendingCard'},
            outside_review_card: {class: 'outsideReviews'},
            card_header: {class: 'cardHeader'},
            pending_color: {class: 'pendingColor'},
            completed_reviews: {class: 'reviewHeader'},
            completed_reviews_span: {css: 'div.reviewHeader > span'},
            average_outside_rev_num: {id: 'averageOutsideReviewNum'},
            total_outside_rev: {id: 'totalOrCount'},
            reviews_awaiting_response: {xpath: '//span[b[contains(text(), "Reviews Awaiting Response:")]]'},
            card_info: {
                heading: {css: 'div.cardHeader'},
                reviewer: {css: 'div.cardHeader > span'},
                job_title: {class: 'reviewJobTitle'},
                relationship: {css: 'div#workingRelationship span.outsideReviewData'},
                timeline: {css: 'div#workingTimeline span.outsideReviewData'},
                unique_strength: {css: '#uniqueStrength .outsideReviewData'},
                rating: {css: '.ratingDiv .rating'},
                feedback: {class: 'feedback'},
                reviewed_by: {class: 'reviewedByDiv'},
                submitted: {xpath: './/span[contains(text(), "Submitted")]/following-sibling::span'},
                completed: {xpath: './/span[contains(text(), "Completed")]/following-sibling::span'},
                order_id: {xpath: './/span[contains(text(), "Order")]/following-sibling::a'},
                email_sent: {xpath: './/span[contains(text(), "Email Sent")]/following-sibling::span'},
                type: {xpath: './/span[contains(text(), "Type")]/following-sibling::span'},
                status: {xpath: './/span[contains(text(), "Status")]/following-sibling::span'}
            }
        },
        fields: {
            show: {id: 'show'}
        },
        talent_profile_url: {css: 'div.right-column > div.field-container > div > span > a'},
        talent_profile_url_frame: {id: 'ad_frame'},
        submittal_history: {
          row: {css: '#work-history table tbody tr'},
          columns: {
              # TODO create BaseAreaList-like class for bootstrap tables
              date: {css: 'td:nth-child(1)'},
              client: {css: 'td:nth-child(2)'},
              title: {css: 'td:nth-child(3)'},
              submitter: {css: 'td:nth-child(4)'},
              pay_rate: {css: 'td:nth-child(5)'},
              bill_rate: {css: 'td:nth-child(6)'},
              temp_to_perm_salary: {css: 'td:nth-child(7)'},
              candidate_status: {css: 'td:nth-child(8)'},
              profile: {css: 'td:nth-child(9)'},
              details: {css: 'td:nth-child(10)'},
              show_details: {css: 'td:nth-child(10) .btn'}
          },
          details_modal: {
              submittal_notes: {
                  modal_dialog: {id: 'submittalNotesModal'},
                  content: {css: '#submittalNotesModal .modal-body .content'}
              }
          },
          email_modal: {
              content: {css: '#submittalEmailModal .modal-body .content'},
              view_complete_profiles: {xpath: '//a[contains(text(), "View Complete Profiles")]'}
          }
        },
        attachments: {
            table: {id: 'attachments-table'},
            type: {
                chequed_reference: {xpath: '//*[@id="attachments-table"]/tbody/tr/td[contains(text(), "ChequedReference")]'}
            },
            first_attachment_link: {xpath: '//*[@id="attachments-table"]/tbody/tr[1]/td[1]/a'},
            first_attachment_type: {xpath: '//*[@id="attachments-table"]/tbody/tr[1]/td[3]'}
        },
        cwicklist: {add: '#cwicklist-add'},
        talent_stars: {
            self_availability_star: {id: 'selfAvailabilityStar'},
            order_star: {id: 'orderStar'},
            talent_star: {id: 'talentStar'},
            talent_star_full: {xpath: "//span[contains(concat(' ',normalize-space(@class),' '),' talentStar agentFullStar ')]"},
            talent_star_empty: {xpath: "//span[contains(concat(' ',normalize-space(@class),' '),' talentStar emptyStar ')]"}
        },
        preferences_link: {id: 'applicationBar"]/div[2]/a[4]'},
        profile_percentage_div: {class: 'profilePercentageDiv'},
        primary_phone_text_button: {id: 'primaryPhone-text'},
        segments: {css: '.segments-column div span'},
        send_to_ceridian_button: {id: 'send_to_ceridian'}
    }

    SELECTORS = {
        moats_edit_section_button: 'div[data-name=%s] div.pane-action-edit',
        business_interviews: {
            header: LOCATORS[:business_interviews][:header][:css] + ':nth-of-type(%d)',
            entry: LOCATORS[:business_interviews][:entry][:css] + ':nth-of-type(%d)'
        },
        coding_challenges: {
            header: LOCATORS[:coding_challenges][:header][:css] + ':nth-of-type(%d)',
            entry: LOCATORS[:coding_challenges][:entry][:css] + ':nth-of-type(%d)'
        },
        skill_assessment: LOCATORS[:skill_assessments][:row][:css] + ':nth-of-type(%d)',
        field: '#%s-field-container span:nth-child(2)',
        select_review_by_name: '//div[contains(@class, "qccCard")][.//span[contains(text(), "%s")]]',
        independent_assessment_scores: '//*[@id="ui-id-22"]/div/div[2]/div[2]/blockquote/div[contains(text(),"%s")]'
    }

    FIELDS = {
        gender: 'gender',
        dob: 'dob',
        age: 'age',
        japan_webwall_id: 'japan-webwall-id',
        train_stations: 'train-stations',
        visa_required: 'visa-required',
        visa_type: 'visa-type',
        visa_expiry: 'visa-expiry',
        show: {type: :select},
    }

    attr_accessor :show

    def initialize(driver, config)
      super
      expect(find :content).to be_displayed
      # Disable accordion animations
      [:interviews, :assessments].each { |tab|
        execute_script "tabLoadCallbacks.add('#{TAB_IDS[tab]}', function () {
                          jQuery(this).find('.ui-accordion').accordion({ animate: false });
                        });"
      }
    end

    CC_SECTION_PATTERN = /([^:]+): ([0-9.]+) out of ([0-9.]+)/

    # Gets the content for the specified skill assessment.
    # Requires the assessments tab to be active.
    #
    # @param [Integer] n the index of the skill assessment (1-indexed)
    # @return [Hash<Symbol, String>] the skill assessment content
    def get_skill_assessment_content(n)
      row = find selector(:skill_assessment) % n
      content = {}
      locator(:skill_assessments, :columns).each_key { |column|
        elem = row.find_element locator(:skill_assessments, :columns, column)
        content[column] = elem.text.strip
      }
      content
    end

    # Returns the skill assessment default message shown when no skill assessments are present.
    #
    # @return [String] The skill assessment default message.
    def get_skill_assessment_default_message
      find(:skill_assessments, :default_message).text
    end

    # Gets the ratings from the INDEPENDENT ASSESSMENT section of the INTERVIEWS TAB
    # the categories depend on the type of expert interview submitted
    #
    # @param [Hash] categories from which to collect scores
    # @return [Hash<String, String>] the category key passed in with numeric string score value
    def get_independent_assessment_scores(categories)
      categories.each do |category, field_name|
        score = find(xpath: SELECTORS[:independent_assessment_scores] % field_name).text[-1]
        categories[category] = score
      end
      categories
    end

    # Gets the content for the specified business interview, expanding it if needed.
    # Requires the interviews tab to be active.
    #
    # @param [Integer] n the index of the interview (1-indexed)
    # @return [Hash<Symbol, String>] the interview content
    def get_business_interview_content(n)
      header = find selector(:business_interviews, :header) % n
      header.click unless header.classes.include? 'ui-accordion-header-active'

      entry = find selector(:business_interviews, :entry) % n
      content = hmap locator :business_interviews, :fields do |loc|
        entry.find(loc).text.strip if entry.exists?(loc)
      end

      content.compact
    end

    # Clicks the transcript link for the specified business interview, expanding it if needed.
    # Requires the interviews tab to be active.
    #
    # @param [Integer] n the index of the interview (1-indexed)
    def click_transcript_link(n)
      header = find selector(:business_interviews, :header) % n
      header.click unless header.classes.include? 'ui-accordion-header-active'

      entry = find selector(:business_interviews, :entry) % n
      entry.click(:business_interviews, :fields, :interview_transcript_link)
    end

    # Gets the contents of the interview transcript for the specified business interview
    #
    # @param [Integer] n the index of the interview (1-indexed)
    # @return [String] interview transcript contents
    def get_transcript_contents(n)
      click_transcript_link(n)
      @driver.pause_auto_switch
      @driver.switch_to.window @driver.window_handles[1]
      transcript_contents = @driver.find_element(css: 'body').text
      @driver.close
      @driver.switch_to.window @driver.window_handles[0]
      @driver.resume_auto_switch
      transcript_contents
    end

    # Gets the contents of the business interview transcript summary for the specified business interview
    #
    # @param [Integer] n the index of the interview (1-indexed)
    # @return [String] business interview transcript summary contents
    def get_business_interview_transcript_summary(n)
      header = find selector(:business_interviews, :header) % n
      header.click unless header.classes.include? 'ui-accordion-header-active'

      entry = find selector(:business_interviews, :entry) % n
      entry.find(class: 'transcript-summary-container').text
    end

    # Gets the number of business interviews on the current talent record.
    #
    # @return [Integer] the number of business interviews
    def business_interview_count
      find_all(:business_interviews, :header).length
    end

    # Gets the view-only data about a specified coding challenge.
    #
    # @param n [Integer, String] the index or name of the coding challenge
    # @return [Hash<Symbol, String>] the content
    def get_coding_challenge_content(n)
      if n.is_a? String
        header, entry = nil, nil
        find_all(:coding_challenges, :header_fields, :name).each_with_index do |elem, i|
          if elem.text.include? n
            header = find selector(:coding_challenges, :header) % (i + 1)
            entry = find selector(:coding_challenges, :entry) % (i + 1)
          end
        end
        return false unless header && entry
      else
        header = find selector(:coding_challenges, :header) % n
        entry = find selector(:coding_challenges, :entry) % n
      end

      header.click unless header.classes.include? 'ui-accordion-header-active'

      content = {}
      locator(:coding_challenges, :header_fields).each_key do |field|
        elem = header.find_element locator :coding_challenges, :header_fields, field
        content[field] = elem.text.strip
      end
      locator(:coding_challenges, :entry_fields).each_key do |field|
        elem = entry.find_element locator :coding_challenges, :entry_fields, field
        content[field] = elem.text.strip
      end

      content[:sections] = {}
      entry.find_elements(locator :coding_challenges, :section).each do |section|
        text = section.text
        if text.nil?
          section.click # Scroll to
          text = section.text
        end
        name, first, last = text.strip.scan(CC_SECTION_PATTERN).flatten
        content[:sections][name] = [first, last]
      end
      content
    end

    # Returns the number of skill assessments
    #
    # @return [Integer] the number of skill assessments
    def skill_assessment_count
      find_all(:skill_assessments, :row).length
    end

    # Returns the coding challenge information contained in the snapshot tab.
    #
    # @return [Array<String>] the array of coding challenge information
    def get_coding_challenge_snapshots
      find(:snapshot, :coding_challenges).text.split ', '
    end

    # Returns the skill assessments information contained in the snapshot tab.
    #
    # @return [Array<String>] the array of skill assessment information
    def get_skill_assessment_snapshots
      find(:snapshot, :skill_assessments).text.split ', '
    end

    # Gets the specified field.
    #
    # @param [Symbol] field the field symbol (@see #FIELDS)
    # @return [Selenium::WebDriver::Element] the field
    def get_field(field)
      find(selector(:field) % FIELDS[field])
    end

    # Gets the specified field content.
    #
    # @param [Symbol] field the field symbol (@see #FIELDS)
    # @return [String] the field content
    def get_field_content(field)
      get_field(field).text
    end

    def get_checkin_date_displayed
      Date.strptime(main_page.find(:snapshot, :moats_availability_check_in_date).text, '%b %d, %Y')
    end

    def set_moats_field_content(field, content)
      clear_and_type content, :talentDetail, field
    end

    def wait_for_talent_detail
      wait_for do
        displayed? :talentDetail, :moats_availability_edit_button
      end
    end

    def wait_for_segment
      wait_until -> () {find( :segments)}
    end

    # Wait until the div with class 'reviewHeader' is displayed. On one occasion a test failed due to
    # reading it before the page displayed it.
    def wait_for_completed_reviews
      wait_for do
        displayed? :review_history, :completed_reviews
      end
    end

    def edit_preauth_submittal
      wait_for do
        displayed? :talentDetail, :moats_availability_preauth_submittal_yes_button
      end
    end

    def edit_preauth_submittal_include_pi
      wait_for do
        displayed? :talentDetail, :moats_availability_preauth_submittal_include_pi_yes_button
      end
    end

    def check_moats_preauth_submittal
      unless checked? :talentDetail, :moats_availability_preauth_submittal_yes_button
        click :talentDetail, :moats_availability_preauth_submittal_yes_button
      end
    end

    def check_moats_preauth_submittal_include_pi
      unless checked? :talentDetail, :moats_availability_preauth_submittal_include_pi_yes_button
        click :talentDetail, :moats_availability_preauth_submittal_include_pi_yes_button
      end
    end

    def preauth_submittal_yes_check_displayed
      wait_for do
        displayed? :talentDetail, :moats_availability_is_preauth_submittal_yes_check
      end
    end

    def preauth_submittal_no_x_displayed
      wait_for do
        displayed? :talentDetail, :moats_availability_is_preauth_submittal_no_x
      end
    end

    def preauth_submittal_include_pi_yes_check_displayed
      wait_for do
        displayed? :talentDetail, :moats_availability_is_preauth_submittal_include_pi_yes_check
      end
    end

    def preauth_submittal_include_pi_no_x_displayed
      wait_for do
        displayed? :talentDetail, :moats_availability_is_preauth_submittal_include_pi_no_x
      end
    end

    def edit_availability_notes
      wait_for do
        is_displayed? :talentDetail, :moats_availability_edit_button
      end
      main_page.click :talentDetail, :moats_availability_edit_button
      wait_for do
        displayed? :talentDetail, :moats_availability_notes_input
      end
    end

    def edit_agent_summary
      wait_for do
        is_displayed? :talentDetail, :agent_summary_edit_button
      end
      click :talentDetail, :agent_summary_edit_button
      wait_for do
        displayed? :talentDetail, :agent_summary_input
      end
    end

    def edit_talent_comments
      wait_for do
        is_displayed? :talentDetail, :talent_comments_edit_button
      end
      main_page.click :talentDetail, :talent_comments_edit_button
      wait_for do
        displayed? :talentDetail, :talent_comments_input
      end
    end

    def edit_travel
      wait_for do
        is_displayed? :talentDetail, :moats_travel_edit_button
      end
      main_page.click :talentDetail, :moats_travel_edit_button
      wait_for do
        displayed? :talentDetail, :moats_travel_home_market_id
      end
    end

    # @return [Int] the ID of the talent
    def get_talent_id
      find(:talent_stars, :talent_star).attr('data-id')
    end

    # @return [String] the First and last name of the talent separated by a space
    def get_talent_name
      find(:talent_name).text.partition(' -').first
    end

    # Finds & returns the first Talent Alert element that contains an order title
    #
    # #param [String] order_title the title of the order the talent is filled on for which you want the alert
    # #return [Element] The first talent alert element that contained the order_title
    def find_talent_alert_containing order_title
      find_all(:talentDetail, :talent_alert_box).select do |box|
        box.text.include? order_title
      end.first
    end

    def get_name_of_agent_resume_file
      find_last(:talentDetail, :resumes).text
    end

    # @return [Hash<String,Selenium::WebDriver::Element] the key is the label text (no ':') and the value is the elem
    # Example:
    #   how_heard = main_page.get_left_column_content['How Heard'].text
    def get_left_column_content
      left_column = find :snapshot, :left_column
      keys = left_column.find_all(:key).map {|k| k.text.sub(':', '').strip}
      values = left_column.find_all :value
      keys.zip(values).to_h
    end

    # click the edit icon on the corresponding MOATS section
    # @param [Symbol] section name of the section to edit
    #   options are :money, :opportunity, :availability, :travel, :skills
    def edit_moats_section(section)
      click SELECTORS[:moats_edit_section_button] % section.to_s
    end

    def expand_independent_assessment_section_header
      click :independent_assessment, :header
    end

    # creates a hash containing all the info found in a review history card
    # @param card_element: can be a String or html element
    #   when string, will select the review history card that contains the string in the `Reviewed By` heading
    # @return [Hash] info object keys:
    #   :reviewer, :job_title, :relationship, :timeline, :unique_strength,
    #   :rating, :feedback, :submitted, :completed, :type, :status
    # todo split this (along with corresponding locators) into it's own element class
    def get_review_history_card_info(card_element)
      card_element = find(xpath: SELECTORS[:select_review_by_name] % card_element) if card_element.is_a? String

      info = {}
      field_list = LOCATORS[:review_history][:card_info]

      field_list.each do |field_name, locator|
        info[field_name] =
            if card_element.exists? locator
              card_element.find(locator).text
            else
              nil
            end
      end

      info
    end

    # Get the number of reviews completed and the average rating stars given for those reviews.
    #
    # @return [Hash{Symbol => Integer|Float}] - :num_reviews => [Integer] number of reviews for the candidate
    #                                           :cumulative_rating => [Float] Average of rating stars from
    #                                                                 reviews of candidate
    def get_review_data
      review_data = Hash.new

      # parse the numeric value from the string and convert to Integer

      review_data[:num_reviews] =
        find(:review_history, :completed_reviews_span).text.tr('^[0-9]', '').to_i

      # Grab the string, which is only the number and convert to Float

      review_data[:cumulative_rating] = find(:review_history, :average_total_num).text.to_f
      review_data
    end

    # Get both the Agent Summary professional headline and the Talent Summary professional headline from the
    # Profile tab.
    #
    # @return [Hash{Symbol => String}] - :agent_headline => The professional headline under Agent Summary
    #                                    :talent_headline => The professional headline under Talent Summary
    def get_pro_headlines
      headlines = Hash.new
      headlines[:agent_headline] = find(:profile, :agent_headline).text
      headlines[:talent_headline] = find(:profile, :talent_headline).text
      headlines
    end
  end

  Util.add_mapping TalentDetail
end

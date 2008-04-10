class MeetingController < ApplicationController

  permit "rubyists and wanna_be_rubyists", :except => :public_page

  def public_page
    render :text => "We're all in Chicago"
  end

  def secret_info
    permit "(matz or dhh) and interested in Answers" do
      render :text => "The Answer = 42"
    end
  end

  def find_apprentice
    @founder = User.find_by_name('matz')
    permit "'inner circle' of :founder" do
      if request.post?
        apprentice = User.find_by_skillset(params[:uber_hacker])
        ruby_community = Group.find_by_name('Ruby')
        ruby_community.accepts_role 'yarv_builder', apprentice
      end
    end
  end

  def rails_conf
    @meeting = Meeting.find_by_name('RailsConf')
    permit "attendees of :meeting or swedish_mensa_supermodels" do
      venue = Hotel.find_by_name("Wyndham O'Hare")
      current_user.is_traveller_to venue
      if permit? "traveller to :venue and not speaker"
        Partay.all_night_long
        @misdeeds = current_user.is_participant_in_what
      end
    end
  end

end

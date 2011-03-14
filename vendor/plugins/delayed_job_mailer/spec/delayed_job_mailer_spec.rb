# coding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

require 'rubygems'
gem     'actionmailer', '>= 1.0.0'
require 'action_mailer'

ActionMailer::Base.delivery_method = :test

class AsynchTestMailer < ActionMailer::Base
  include Delayed::Mailer
  
  def test_mail(from, to)
    @subject    = 'subject'
    @body       = 'mail body'
    @recipients = to
    @from       = from
    @sent_on    = Time.now
    @headers    = {}
  end
end

describe AsynchTestMailer do
  before do
    # We need a default environment...
    Object.const_set 'RAILS_ENV', 'test' unless defined?(::RAILS_ENV)
  end
  
  describe 'deliver_test_mail' do
    before(:each) do
      @emails = ActionMailer::Base.deliveries
      @emails.clear
      @params = 'noreply@autoki.de', 'joe@doe.com'
      AsynchTestMailer.stub(:send_later)
    end
    
    it 'should not deliver the email at this moment' do
      AsynchTestMailer.deliver_test_mail *@params
      @emails.size.should == 0
    end
    
    it 'should send deliver action to delayed job list' do
      AsynchTestMailer.should_receive(:send_later).with('deliver_test_mail!', *@params)
      AsynchTestMailer.deliver_test_mail *@params
    end
    
    it 'should not send deliver action to delayed job list for environments where delayed job mailer is disabled' do
      excluded_environments = [:cucumber, :foo, 'bar']
      ::Delayed::Mailer.excluded_environments = excluded_environments
      
      excluded_environments.each do |env|
        Object.send :remove_const, 'RAILS_ENV'
        Object.const_set 'RAILS_ENV', env.to_s
        
        AsynchTestMailer.should_not_receive(:send_later).with('deliver_test_mail!', *@params)
        AsynchTestMailer.deliver_test_mail *@params
      end
    end
  end
  
  describe 'deliver_test_mail!' do
    it 'should deliver the mail' do
      emails = ActionMailer::Base.deliveries
      emails.clear
      AsynchTestMailer.deliver_test_mail! 'noreply@autoki.de', 'joe@doe.com'
      emails.size.should == 1
    end
  end
end

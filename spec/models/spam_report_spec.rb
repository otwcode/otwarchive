require 'spec_helper'

describe SpamReport do
  let (:first_spam) { create(:work, spam: true, posted: true) }
  let (:second_spam) { create(:work, spam: true, posted: true, authors: first_spam.authors) }
  let (:third_spam) { create(:work, spam: true, posted: true, authors: second_spam.authors) }

  before(:example) do
    ArchiveConfig.SPAM_THRESHOLD = 10
    firs_work = create(:work, spam: false, posted: true)
  end

  it 'has a recent date after the new date' do
    spam_report = SpamReport.new
    expect(spam_report.new_date).to be > spam_report.recent_date
  end

  it 'sends no email if there is no significant spam' do
    third_spam
    ArchiveConfig.SPAM_THRESHOLD = 70
    expect(AdminMailer).not_to receive(:send_spam_alert)
    SpamReport.run
  end

  it 'sends email if there is significant spam' do
    expect(AdminMailer).to receive(:send_spam_alert).with({
        third_spam.pseuds.first.user_id => { score: 13, \
                                             work_ids: [first_spam.id, second_spam.id, third_spam.id]}
      }).and_return(double("AdminMailer", deliver: true))
    SpamReport.run
  end

  it 'Using more than one ip address increases the score' do
    third_spam.ip_address = "192.168.11.1"
    third_spam.save
    expect(AdminMailer).to receive(:send_spam_alert).with({
        third_spam.pseuds.first.user_id => { score: 14, \
                                             work_ids: [first_spam.id, second_spam.id, third_spam.id]}
      }).and_return(double("AdminMailer", deliver: true))
     SpamReport.run
  end

  it 'Posting in the past decreases the score' do
    second_work = create(:work, spam: false, posted: true, authors: second_spam.authors, created_at: 3.days.ago)
    expect(AdminMailer).to receive(:send_spam_alert).with({
        third_spam.pseuds.first.user_id => { score: 11, \
                                             work_ids: [first_spam.id, second_spam.id, third_spam.id]}
      }).and_return(double("AdminMailer", deliver: true))
    SpamReport.run
  end

end

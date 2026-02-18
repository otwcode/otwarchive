require "spec_helper"

describe ArchiveFaq do
  let(:faq) { I18n.with_locale("en") { create(:archive_faq, title: "hello") } }

  it "is valid with the default locale" do
    I18n.locale = I18n.default_locale
    expect(faq).to be_valid
    expect(faq.title).to eq("hello")
  end

  it "is invalid with a non-existent locale" do
    I18n.locale = "sjn"
    faq.title = "suilad"
    expect(Locale.exists?(iso: I18n.locale)).to be_falsey
    expect(faq.save).to be_falsey
    expect(faq.errors.full_messages).to include("The locale sjn does not exist.")
  end

  it "uses the title from the default locale for non-translated locales" do
    I18n.locale = "sjn"
    expect(faq.title).to eq("hello")
  end

  it "cannot have questions with a non-existent locale" do
    I18n.locale = "sjn"
    question = faq.questions.build(attributes: { question: "it's a question?", content: "it's an answer", anchor: "identity" })
    expect(question.save).to be_falsey
    expect(question.errors.full_messages).to include("The locale sjn does not exist.")
  end

  describe "FAQ menu settings" do
    it "uses the configured display name when present" do
      faq = create(:archive_faq, include_in_faq_menu: true, faq_menu_display_name: "Account")
      expect(faq.faq_menu_name).to eq("Account")
    end

    it "falls back to the category name when display name is blank" do
      faq = create(:archive_faq, include_in_faq_menu: true, faq_menu_display_name: "")
      expect(faq.faq_menu_name).to eq(faq.title)
    end

    it "enforces the selection limit" do
      allow(ArchiveConfig).to receive(:FAQ_MENU_SELECTION_LIMIT).and_return(1)
      create(:archive_faq, include_in_faq_menu: true)
      limited_faq = build(:archive_faq, include_in_faq_menu: true)

      expect(limited_faq).not_to be_valid
      expect(limited_faq.errors.full_messages).to include("Include in faq menu can't be selected because the maximum of 1 FAQ categories is already in the menu.")
    end

    it "returns only selected FAQ menu items in menu order" do
      faq1 = create(:archive_faq, include_in_faq_menu: true, faq_menu_display_name: "First FAQ", faq_menu_position: 2, position: 2)
      faq2 = create(:archive_faq, include_in_faq_menu: false, position: 1)
      faq3 = create(:archive_faq, include_in_faq_menu: true, faq_menu_position: 3, position: 3)

      expect(ArchiveFaq.faq_menu_items).to eq(
        [
          { slug: faq1.slug, menu_name: "First FAQ" },
          { slug: faq3.slug, menu_name: faq3.title }
        ]
      )
      expect(ArchiveFaq.in_faq_menu_order.pluck(:slug)).not_to include(faq2.slug)
    end

    it "assigns faq menu positions for newly included categories" do
      faq1 = create(:archive_faq, include_in_faq_menu: true)
      faq2 = create(:archive_faq, include_in_faq_menu: true)

      expect(faq1.reload.faq_menu_position).to eq(1)
      expect(faq2.reload.faq_menu_position).to eq(2)
    end

    it "moves a category up and down in FAQ menu order" do
      faq1 = create(:archive_faq, include_in_faq_menu: true)
      faq2 = create(:archive_faq, include_in_faq_menu: true)
      faq3 = create(:archive_faq, include_in_faq_menu: true)

      faq2.move_in_faq_menu!("up")
      expect(ArchiveFaq.in_faq_menu_order.pluck(:id)).to eq([faq2.id, faq1.id, faq3.id])

      faq2.move_in_faq_menu!("down")
      expect(ArchiveFaq.in_faq_menu_order.pluck(:id)).to eq([faq1.id, faq2.id, faq3.id])
    end
  end
end

require "spec_helper"

describe AdminSetting do
  # Create the default skin record to ensure it can be cached.
  describe ".current", default_skin: true do
    context "when settings are cached" do
      before { AdminSetting.current }

      it "doesn't perform any database queries on further reads" do
        expect(ActiveRecord::Base.connection).not_to receive(:exec_query)
        expect(ActiveRecord::Base.connection).not_to receive(:exec_update)
        expect(ActiveRecord::Base.connection).not_to receive(:exec_delete)
        expect(AdminSetting.current.updated_at).to be_present
      end

      context "when settings are updated" do
        before do
          travel(1.second)
          AdminSetting.first.update_attribute(:disable_support_form, true)
        end

        it "re-caches updated settings" do
          expect(ActiveRecord::Base.connection).not_to receive(:exec_query)
          expect(ActiveRecord::Base.connection).not_to receive(:exec_update)
          expect(ActiveRecord::Base.connection).not_to receive(:exec_delete)
          expect(AdminSetting.current.disable_support_form).to eq(true)
          expect(AdminSetting.current.updated_at).to eq(Time.current)
        end
      end
    end
  end
end

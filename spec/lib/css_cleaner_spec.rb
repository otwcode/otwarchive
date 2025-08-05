require "spec_helper"

describe CssCleaner do
  include CssCleaner

  describe ".clean_css_code" do
    context "when cleaning Skin CSS" do
      context "when defining custom property" do
        it "allows custom property name with letters" do
          skin = build(:skin, css: ":root { --white: #fff; }")
          expect(skin.save).to be_truthy
          expect(skin.reload.css).to eq(":root {\n  --white: #fff;\n}\n\n")
        end

        it "allows custom property name with numbers" do
          skin = build(:skin, css: ":root { --100: 100%; }")
          expect(skin.save).to be_truthy
          expect(skin.reload.css).to eq(":root {\n  --100: 100%;\n}\n\n")
        end

        it "allows custom property name with dashes" do
          skin = build(:skin, css: ":root { ---: transparent; }")
          expect(skin.save).to be_truthy
          expect(skin.reload.css).to eq(":root {\n  ---: transparent;\n}\n\n")
        end

        it "allows custom property name with underscores" do
          skin = build(:skin, css: ":root { --__: rgba(255, 255, 255, 0); }")
          expect(skin.save).to be_truthy
          expect(skin.reload.css).to eq(":root {\n  --__: rgba(255, 255, 255, 0);\n}\n\n")
        end

        it "strips custom property and returns error when value uses url() function" do
          skin = build(:skin, css: ":root { --art: url(\"https://example.com/img.png\"); }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("--art in :root cannot have the value url(\"https://example.com/img.png\"), sorry!")
        end

        it "strips custom property and retruns error when value uses quotation marks" do
          skin = build(:skin, css: ":root { --serif: \"Times New Roman\" };")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("--serif in :root cannot have the value \"Times New Roman\", sorry!")
        end

        it "allows shorthand-style values" do
          skin = build(:skin, css: ":root { --heading: small-caps 1.125rem Georgia, Times New Roman, serif; }")
          expect(skin.save).to be_truthy
          expect(skin.reload.css).to eq(":root {\n  --heading: small-caps 1.125rem Georgia, Times New Roman, serif;\n}\n\n")
        end

        it "strips custom property and returns error when shorthand-style value includes url() function" do
          skin = build(:skin, css: ":root { --background: #900 url(\"https://example.com/img.png\"); }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("--background in :root cannot have the value #900 url(\"https://example.com/img.png\"), sorry!")
        end

        it "strips custom property and returns error when shorthand-style value includes quotation marks" do
          skin = build(:skin, css: ":root { --heading: small-caps 1.125rem Georgia, \"Times New Roman\", serif; }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("--heading in :root cannot have the value small-caps 1.125rem Georgia, \"Times New Roman\", serif, sorry!")
        end

        it "strips custom property with disallowed characters and returns error" do
          skin = build(:skin, css: "#footer, #header { --#hash: absolute; }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("The --#hash custom property in #footer, #header has an invalid name. Names can only contain any combination of letters in the English alphabet in both uppercase (A-Z) and lowercase (a-z), numerals zero to nine (0-9), and underscores (_).")
        end

        it "strips invalid property and returns error when property contains text resembling custom property name" do
          skin = build(:skin, css: ":root { color--heading: absolute; }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("We don't currently allow the CSS property color--heading -- please notify support if you think this is an error.")
        end

        # Using a property from SUPPORTED_CSS_SHORTHAND_PROPERTIES allows anything, e.g., font-salmon, awkwardpause, background_witches
        it "allows invalid variation of shorthand property when property contains text resembling custom property name" do
          skin = build(:skin, css: ":root { background--heading: absolute; }")
          expect(skin.save).to be_truthy
          expect(skin.css).to eq(":root {\n  background--heading: absolute;\n}\n\n")
        end
      end

      context "when using var() function as value" do
        it "allows simple var() functions for regular property" do
          skin = build(:skin, css: "div { color: var(--black) }")
          expect(skin.save).to be_truthy
          expect(skin.css).to eq("div {\n  color: var(--black);\n}\n\n")
        end

        it "allows simple var() functions for shorthand property" do
          skin = build(:skin, css: "div { font: var(--black) }")
          expect(skin.save).to be_truthy
          expect(skin.css).to eq("div {\n  font: var(--black);\n}\n\n")
        end

        it "strips var() function from content property and returns error" do
          skin = build(:skin, css: "p:before { content: var(--text) }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("content in p:before cannot have the value var(--text), sorry!")
        end

        it "strips var() function from font-family property and returns error" do
          skin = build(:skin, css: ".heading { font-family: var(--serif) }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("font-family in .heading cannot have the value var(--serif), sorry!")
        end

        it "strips var() function with fallbacks and returns error" do
          skin = build(:skin, css: "p { color: var(--blue, #fff) }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("color in p cannot have the value var(--blue, #fff), sorry!")
        end

        it "strips var() function with unclosed parentheses and returns error" do
          skin = build(:skin, css: "p { color: var(--blue }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("There don't seem to be any rules for p")
        end
      end
    end

    context "when cleaning WorkSkin CSS" do
      it "strips custom properties and returns error" do
        skin = build(:work_skin, css: "#workskin { --background: #fff; }")
        expect(skin.save).to be_falsey
        expect(skin.css).to eq("")
        expect(skin.errors[:base]).to include("Variables are not allowed in work skins.")
      end

      it "strips variable functions and returns error" do
        skin = build(:work_skin, css: "p { color: var(--yellow) }")
        expect(skin.save).to be_falsey
        expect(skin.css).to eq("")
        expect(skin.errors[:base]).to include("Variables are not allowed in work skins.")
      end

      context "with position property" do
        it "strips value fixed" do
          skin = build(:work_skin, css: "div { position: fixed; }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("The position property in div cannot have the value fixed in Work skins, sorry!")
        end

        it "allows other values" do
          skin = build(:work_skin, css: "div { position: absolute; }")
          expect(skin.save).to be_truthy
          expect(skin.reload.css).to eq("#workskin div {\n  position: absolute;\n}\n\n")
        end
      end

      it "prefixes selectors with #workskin" do
        skin = create(:work_skin, css: "p { color: red; }")
        expect(skin.reload.css).to include("#workskin p")
      end
    end
  end
end
